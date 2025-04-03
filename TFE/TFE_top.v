/*  
    This file is the top file of Traffic Feature Extracting (TFE) proj, 
    which includes CRC module and TFE kernels.

*/

module TFE_top (
    input   wire                                clk,
    input   wire                                rst_n,
    input   wire    [511:0]                     i_packet,
    input   wire                                i_packet_v,

    // pre-ctrl signal
    input   wire    [7:0]                       threshold,

    // interface to DL engine or RV core
    input   wire                                clk_ext,
    input   wire                                fetch_addr_en,
    output  wire    [11:0]                      o_fea_addr,
    output  wire                                o_fea_addr_v,
    output  wire                                o_fea_empty,
    input   wire                                free_one_flow

);


wire    [103:0]                                 ip_wd2hash;
wire    [103:0]                                 r_ip_wd2hash;
wire    [15:0]                                  pkt_size_wd2meta;
wire    [7:0]                                   tcp_flag_wd2meta;
wire    [15:0]                                  tcp_wind_size_wd2meta;

(* dont_touch = "yes" *) Wine_Dispenser wine_dispenser(
    .i_packet                                   (i_packet),
    .ip_tuple                                   (ip_wd2hash),
    .r_ip_tuple                                 (r_ip_wd2hash),
    .pkt_size                                   (pkt_size_wd2meta),
    .tcp_flag                                   (tcp_flag_wd2meta),
    // .paylaod                                    (),
    .tcp_wind_size                              (tcp_wind_size_wd2meta)
);


wire    [31:0]                                  hash_hash2kernel;
wire    [31:0]                                  r_hash_hash2kernel;
wire                                            hash_v_hash2kernel;

(* dont_touch = "yes"*) Hashing hash_module(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .ip_tuple                                   (ip_wd2hash),
    .r_ip_tuple                                 (r_ip_wd2hash),
    .ip_tuple_v                                 (i_packet_v),
    .hash                                       (hash_hash2kernel),
    .r_hash                                     (r_hash_hash2kernel),
    .hash_v                                     (hash_v_hash2kernel)
);


wire    [143:0]                                 meta_meta2kernel;
wire    [15:0]                                  pkt_arvt_meta2kernel;
wire                                            pkt_size_meta2kernel;
(* dont_touch = "yes"*) Meta_Gen meta_gen(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .ip_tuple                                   (ip_wd2hash),
    .i_pkt_size                                 (pkt_size_wd2meta),
    .pkt_flag                                   (tcp_flag_wd2meta),
    .wind_size                                  (tcp_wind_size_wd2meta),
    .pkt_v                                      (i_packet_v),
    .pkt_arvt_w                                 (pkt_arvt_meta2kernel),
    .meta_w                                     (meta_meta2kernel),
    .o_pkt_size                                 (pkt_size_meta2kernel)
);



wire    [103:0]                                 tuple_2kernel;
wire    [15:0]                                  pkt_arvt_2kernel;
wire    [15:0]                                  pkt_size_2kernel;

assign  tuple_2kernel           =               meta_meta2kernel[143:40];

(* dont_touch = "yes"*) TFE_Kernel    tfe_kernel(
    .clk                            (clk),
    .rst_n                          (rst_n),
    .hash                           (hash_hash2kernel),
    .r_hash                         (r_hash_hash2kernel),
    .hash_v                         (hash_v_hash2kernel),
    .tuple                          (tuple_2kernel),
    .pkt_arvt                       (pkt_arvt_meta2kernel),
    .pkt_size                       (pkt_size_meta2kernel),
    .threshold                      (threshold),
    .vec_feature_mode               (2'b11),

    .clk_ext                        (clk_ext),
    .o_fea_empty                    (feature_empty),
    .fetch_addr_en                  (engine_rd_addr_en),
    .free_one_flow                  (free_one_flow)
);


endmodule