/*  
    This module is alu cluster for extracting 2-stage features.
    
    It contains four max/min sub-alu, 4 averaging sub-alu and t-
    wo vector sub-alu, which extracts max_pkt_size, min_pkt_size, 
    max_pkt_arit, min_pkt_arit, average_pkt_size, average_pkt_ar-
    it, pkt_per_second, bytes_per_second, pkt_size_vec, pkt_arit-
    _vec.
    
 */

module ALU_Cluster (
    input   wire                                clk,
    input   wire                                rst_n,

    // input max/min feature value
    input   wire    [7:0]                       hist_max_pkt_size,
    input   wire    [7:0]                       hist_min_pkt_size,
    input   wire    [7:0]                       hist_max_pkt_arit,
    input   wire    [7:0]                       hist_min_pkt_arit,
    input   wire                                hist_data_v,
    
    // input vector feature value
    input   wire    [1:0]                       vec_mode, // choosing vector format
    input   wire    [159:0]                     i_vec_feature,


    input   wire    [7:0]                       pkt_size,
    input   wire    [7:0]                       pkt_arit,
    input   wire    [7:0]                       n_pkt,
    input   wire    [31:0]                      i_hash,
    input   wire                                size_arit_v,
    input   wire    [7:0]                       flow_durt,
    input   wire    [7:0]                       flow_size,
    input   wire    [7:0]                       threshold, // used by vec_feature_v
    input   wire                                reach_thrh,

    input   wire    [127:0]                     i_meta,
    input   wire                                i_meta_v,

    // write back to feature cache
    output  wire    [31:0]                      wcache_addr,
    output  wire                                wea_cache,
    output  wire    [191:0]                     wcache_data,

    // write back to main feature memory
    output  wire    [31:0]                      wmem_addr,
    output  wire                                wea_mem,
    output  wire    [255:0]                     wmem_data,


    input   wire                                useless
);

wire    [7:0]                                   max_pkt_size;
wire    [7:0]                                   min_pkt_size;
wire    [7:0]                                   max_pkt_arit;
wire    [7:0]                                   min_pkt_arit;
wire                                            max_pkt_size_v;

Max_Min_Alu max_pkt_size_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .hist_data                                  (hist_max_pkt_size),
    .hist_data_v                                (hist_data_v),
    .cur_data                                   (pkt_size),
    .cur_data_v                                 (size_arit_v),
    .func                                       (1'd1),
    .o_extreme_data                             (max_pkt_size),
    .o_extreme_data_v                           (max_pkt_size_v)
);

Max_Min_Alu min_pkt_size_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .hist_data                                  (hist_min_pkt_size),
    .hist_data_v                                (hist_data_v),
    .cur_data                                   (pkt_size),
    .cur_data_v                                 (size_arit_v),
    .func                                       (1'd0),
    .o_extreme_data                             (min_pkt_size),
    .o_extreme_data_v                           ()
);

Max_Min_Alu max_pkt_arit_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .hist_data                                  (hist_max_pkt_arit),
    .hist_data_v                                (hist_data_v),
    .cur_data                                   (pkt_arit),
    .cur_data_v                                 (size_arit_v),
    .func                                       (1'd1),
    .o_extreme_data                             (max_pkt_arit),
    .o_extreme_data_v                           ()
);

Max_Min_Alu min_pkt_arit_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .hist_data                                  (hist_min_pkt_arit),
    .hist_data_v                                (hist_data_v),
    .cur_data                                   (pkt_arit),
    .cur_data_v                                 (size_arit_v),
    .func                                       (1'd0),
    .o_extreme_data                             (min_pkt_arit),
    .o_extreme_data_v                           ()
);


wire    [7:0]                                   avg_pkt_size;
wire    [7:0]                                   avg_pkt_arit;
wire    [7:0]                                   avg_pps;
wire    [7:0]                                   avg_bps;
wire                                            avg_val_v;

Average_Val_Unit average_pkt_size_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .a                                          (flow_size),
    .b                                          (n_pkt),
    .vld                                        (reach_thrh),
    .quo                                        (avg_pkt_size),
    .rem                                        (),
    .ack                                        (avg_val_v)
);

Average_Val_Unit average_pkt_arit_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .a                                          (flow_durt),
    .b                                          (n_pkt),
    .vld                                        (reach_thrh),
    .quo                                        (avg_pkt_arit),
    .rem                                        (),
    .ack                                        ()
);

Average_Val_Unit average_packet_ps_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .a                                          (n_pkt),
    .b                                          (flow_durt),
    .vld                                        (reach_thrh),
    .quo                                        (avg_pps),
    .rem                                        (),
    .ack                                        ()
);

Average_Val_Unit average_byte_ps_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .a                                          (flow_size),
    .b                                          (flow_durt),
    .vld                                        (reach_thrh),
    .quo                                        (avg_bps),
    .rem                                        (),
    .ack                                        ()
);


wire    [159:0]                                 pkt_size_vec;
wire    [159:0]                                 pkt_arit_vec;
wire                                            pkt_size_vec_v;

Vec_Feature_Unit    pkt_size_vec_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .n_pkt                                      (n_pkt),
    .cur_data                                   (pkt_size),
    .cur_data_v                                 (size_arit_v),
    .vec_feature                                (pkt_size_vec),
    .vec_feature_v_w                            (pkt_size_vec_v),
    .reach_thrh                                 (reach_thrh),
    .hist_vec                                   (i_vec_feature),
    .vec_func                                   (2'b01),
    .vec_mode                                   (vec_mode)
);

Vec_Feature_Unit    pkt_arit_vec_pe(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .n_pkt                                      (n_pkt),
    .cur_data                                   (pkt_arit),
    .cur_data_v                                 (size_arit_v),
    .vec_feature                                (pkt_arit_vec),
    .vec_feature_v_w                            (),
    .reach_thrh                                 (reach_thrh),
    .hist_vec                                   (i_vec_feature),
    .vec_func                                   (2'b10),
    .vec_mode                                   (vec_mode)
);


ALU_Output_buffer  alu_out_buf(
   .clk                                         (clk),
   .rst_n                                       (rst_n),
   .max_pkt_size                                (max_pkt_size),
   .min_pkt_size                                (min_pkt_size),
   .max_pkt_arit                                (max_pkt_arit),
   .min_pkt_arit                                (min_pkt_arit),
   .extreme_data_v                              (max_pkt_size_v),
   .avg_pkt_size                                (avg_pkt_size),
   .avg_pkt_arit                                (avg_pkt_arit),
   .avg_pkt_pps                                 (avg_pps),
   .avg_pkt_bps                                 (avg_bps),
   .avg_val_v                                   (avg_val_v),
   .n_pkt                                       (n_pkt),
   .flow_durt                                   (flow_durt),
   .flow_size                                   (flow_size),
   .pkt_arit                                    (pkt_arit),
   .size_arit_v                                 (size_arit_v),
   .i_hash                                      (i_hash),
   .i_meta                                      (i_meta),
   .wcache_addr                                 (wcache_addr),
   .wea_cache                                   (wea_cache),
   .wcache_data                                 (wcache_data),
   .i_pkt_size_vec                              (pkt_size_vec),
   .i_pkt_arit_vec                              (pkt_arit_vec),
   .vec_mode                                    (vec_mode)
);


endmodule