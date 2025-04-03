/*  
    This file is the top file of kernel processing of TFE, which includes
    flow-tracking, 1-stage and 2-stage feature extracting, pushing ready
    feature to DL engine/RV core, receiving complete signal from exteral
    modules and free space.
    
    The main module in this top as listed:
    * flow_tracker: establish and free the tracking to a flow;
    * Main_Feature_Cache: storing 1-stage feature and temporate feature;
    * Buffer2alu: clk-align the data from main_feature_cache and flow_-
    tracker;
    * ALU_Cluster: processing 2-stage feature;
    * Interface_TFE2Ext: Preparing ready feature and its address to out-
    side memory and external processing elements (RV core and DL engine);
    * Inflight_Flow_Addr: Keeping the hash and r_hash of inflight flow,
    receving free signal from external PE and relasing free signal to fl-
    ow_tracker.
*/

`define META_LEN 168


module  TFE_Kernel (
    input   wire                                clk,
    input   wire                                rst_n,

    // interface to DL engine or RV core
    input   wire                                clk_ext,
    input   wire                                fetch_addr_en,
    output  wire    [11:0]                      o_fea_addr,
    output  wire                                o_fea_addr_v,
    output  wire                                o_fea_empty,
    input   wire                                free_one_flow,

    // ports for tb
    input   wire    [31:0]                      hash, // hash value of packet
    input   wire    [31:0]                      r_hash, // hash value of reverse direction
    input   wire                                hash_v,
    input   wire    [103:0]                     tuple,
    input   wire    [15:0]                      pkt_arvt,
    input    wire    [15:0]                     pkt_size,
    input    wire    [7:0]                      threshold, // the thrhold of packet number

    // TFE config signal
    input   wire    [1:0]                       vec_feature_mode,

    // ports for tb: initial the value of main feature mem
    // input   wire                                wr_main_mem_sim,
    // input    wire    [11:0]                        wr_main_mem_addr_sim,
    // input    wire    [191:0]                        wr_main_mem_data_sim
    input   wire                                useless

);


wire                                            rd_main_cache;
wire    [11:0]                                  rd_main_cache_addr_w;
wire    [31:0]                                     hist_mem2buffer;
wire                                            hist_mem_v2buffer;


wire                                            hit2buffer;
wire    [`META_LEN-1:0]                         meta2buffer;
wire                                            meta_v2buffer;
wire    [7:0]                                   o_pkt_size2buffer;
wire    [7:0]                                   pkt_arit2buffer;
wire    [7:0]                                   n_pkt2buffer;
wire    [7:0]                                   size_arit_v2buffer;
wire    [31:0]                                  o_hash2buffer;
wire    [7:0]                                   flow_durt2buffer;
wire    [7:0]                                   flow_size2buffer;
wire                                            reach_thrh2buffer;
wire                                            free_addr_v_inflight2track;
wire    [11:0]                                  free_addr_inflightf2track;
wire    [11:0]                                  free_r_addr_inflightf2track;
wire    [31:0]                                  o_r_hash_track2buf;

(* dont_touch = "yes" *) flow_tracker    Flow_tracker(
    .clk                            (clk),
    .rst_n                            (rst_n),
    .hash                            (hash),
    .r_hash                            (r_hash),
    .hash_v                            (hash_v),
    .tuple                            (tuple),
    .pkt_arvt                        (pkt_arvt),
    .i_pkt_size                        (pkt_size),
    .threshold                        (threshold),
    
    // output to buffer
    .hit_w                          (hit2buffer),
    .meta_fea_w                     (meta2buffer),
    .meta_fea_v_w                   (meta_v2buffer),
    // 1-stage feature to buffer
    .o_pkt_size                       (o_pkt_size2buffer),
    .pkt_arit                         (pkt_arit2buffer),
    .n_pkt                            (n_pkt2buffer),
    .size_arit_v                      (size_arit_v2buffer),
    .o_hash                           (o_hash2buffer),
    .o_r_hash                         (o_r_hash_track2buf),
    // flow feature controlled by threshold
    .flow_durt                        (flow_durt2buffer),
    .flow_size                        (flow_size2buffer),
    .reach_thrh                       (reach_thrh2buffer),

    // output to main feature mem
    .rd_main_cache                    (rd_main_cache),
    .rd_main_cache_addr_w             (rd_main_cache_addr_w),
    
    .free_addr                        (free_addr_inflightf2track),
    .free_r_addr                      (free_r_addr_inflightf2track),
    .free_addr_v                      (free_addr_v_inflight2track)
);



wire    [7:0]                       max_pkt_size_cache2buf;
wire    [7:0]                       min_pkt_size_cache2buf;
wire    [7:0]                       max_pkt_arit_cache2buf;
wire    [7:0]                       min_pkt_arit_cache2buf;
wire    [191:0]                     vec_feature_cache2buf;
wire                                rdata_v_cache2buf;
wire    [191:0]                         wcache_data_alu2cache;
wire                                    wea_cache_alu2cache;
wire    [11:0]                          wcache_addr_alu2cache;

(* dont_touch = "yes" *) Main_Feature_Cache_Module  main_feature_cache(
   .clk                             (clk),
   .rst_n                           (rst_n),
   .rd_mem                          (rd_main_cache),
   .rd_addr                         (rd_main_cache_addr_w),
    
    // wr signals from ALU cluster
   .wr_addr                         (wcache_addr_alu2cache),
   .wr_data                         (wcache_data_alu2cache),
   .wea                             (wea_cache_alu2cache),
   
    // rd signals to buffer
   .o_max_pkt_size                  (max_pkt_size_cache2buf),
   .o_min_pkt_size                  (min_pkt_size_cache2buf),
   .o_max_pkt_arit                  (max_pkt_arit_cache2buf),
   .o_min_pkt_arit                  (min_pkt_arit_cache2buf),
   .o_vec_feature                   (vec_feature_cache2buf),
   .rd_data_v                       (rdata_v_cache2buf)
);






wire    [`META_LEN-1:0]                         meta2alu;
wire                                            meta_v2alu;
wire    [127:0]                                 hist_mem2alu;
wire                                            hist_mem_v2alu;
wire    [7:0]                                    o_pkt_size2alu;
wire    [7:0]                                    o_pkt_arit2alu;
wire    [7:0]                                    o_n_pkt2alu;
wire    [7:0]                                    o_size_arit_v2alu;
wire    [31:0]                                    o_hash2alu;
wire    [31:0]                                    o_r_hash2alu;
wire    [7:0]                                    o_flow_durt2alu;
wire    [7:0]                                    o_flow_size2alu;
wire                                            o_reach_thrh2alu;
wire    [7:0]                                    o_threshold2alu;
wire    [7:0]                       max_pkt_size_buf2alu;
wire    [7:0]                       min_pkt_size_buf2alu;
wire    [7:0]                       max_pkt_arit_buf2alu;
wire    [7:0]                       min_pkt_arit_buf2alu;
wire    [191:0]                     vec_feature_buf2alu;
wire                                cache_data_v_buf2alu;

(* dont_touch = "yes" *) Buffer2alu      buffer2alu(
    .clk                            (clk),
    .rst_n                            (rst_n),
    .hit                            (hit2buffer),

    // input data from tracker
    .i_meta_fea                         (meta2buffer),
    .i_meta_fea_v                       (meta_v2buffer),
    .i_pkt_size                         (o_pkt_size2buffer),
    .i_pkt_arit                         (pkt_arit2buffer),
    .i_n_pkt                            (n_pkt2buffer),
    .i_size_arit_v                      (size_arit_v2buffer),
    .i_hash                             (o_hash2buffer),
    .i_r_hash                           (o_r_hash_track2buf),
    .i_flow_durt                        (flow_durt2buffer),
    .i_flow_size                        (flow_size2buffer),
    .i_reach_thrh                       (reach_thrh2buffer),
    
    
    // input data from feature cache
    .i_max_pkt_size                  (max_pkt_size_cache2buf),
    .i_min_pkt_size                  (min_pkt_size_cache2buf),
    .i_max_pkt_arit                  (max_pkt_arit_cache2buf),
    .i_min_pkt_arit                  (min_pkt_arit_cache2buf),
    .i_vec_feature                   (vec_feature_cache2buf),
    .i_cache_data_v                  (rdata_v_cache2buf),
    

    // output cache data to alu cluster
    .o_max_pkt_size                  (max_pkt_size_buf2alu),
    .o_min_pkt_size                  (min_pkt_size_buf2alu),
    .o_max_pkt_arit                  (max_pkt_arit_buf2alu),
    .o_min_pkt_arit                  (min_pkt_arit_buf2alu),
    .o_vec_feature                   (vec_feature_buf2alu),
    .o_cache_data_v                  (cache_data_v_buf2alu),
    
    .o_meta_fea                      (meta2alu),
    .o_meta_fea_v                    (meta_v2alu),
    .o_pkt_size                      (o_pkt_size2alu),
    .o_pkt_arit                      (o_pkt_arit2alu),
    .o_n_pkt                         (o_n_pkt2alu),
    .o_size_arit_v                   (o_size_arit_v2alu),
    .o_hash                          (o_hash2alu),
    .o_r_hash                        (o_r_hash2alu),
    .o_flow_durt                     (o_flow_durt2alu),
    .o_flow_size                     (o_flow_size2alu),
    .o_reach_thrh                    (o_reach_thrh2alu),
    .o_threshold                     (o_threshold2alu)
);




(* dont_touch = "yes" *) ALU_Cluster  alu_cluster(
   .clk                                 (clk),
   .rst_n                               (rst_n),
   .hist_max_pkt_size                   (max_pkt_size_buf2alu),
   .hist_min_pkt_size                   (min_pkt_size_buf2alu),
   .hist_max_pkt_arit                   (max_pkt_arit_buf2alu),
   .hist_min_pkt_arit                   (min_pkt_arit_buf2alu),
   .hist_data_v                         (cache_data_v_buf2alu),
   .pkt_size                            (o_pkt_size2alu),
   .pkt_arit                            (o_pkt_arit2alu),
   .n_pkt                               (o_n_pkt2alu),
   .i_hash                              (o_hash2alu),
   .size_arit_v                         (o_size_arit_v2alu),
   .flow_durt                           (o_flow_durt2alu),
   .flow_size                           (o_flow_size2alu),
   .threshold                           (),
   .reach_thrh                          (o_reach_thrh2alu),
   .i_meta                              (meta2alu),
   .i_meta_v                            (meta_v2alu),
   .wcache_addr                         (wcache_addr_alu2cache),
   .wea_cache                           (wea_cache_alu2cache),
   .wcache_data                         (wcache_data_alu2cache),
   .vec_mode                            (vec_feature_mode),
   .i_vec_feature                       (vec_feature_buf2alu)
);



(* dont_touch = "yes" *) Interface_TFE2Ext  interface(
    .clk                                         (clk),
    .rst_n                                       (rst_n),
    .clk_ext                                     (clk_ext),
    
    .reach_thrh                                  (o_reach_thrh2alu),
    .i_fea_addr                                  (o_hash2alu),
   
    .rd_fifo                                     (fetch_addr_en),
    .o_fea_addr                                  (o_fea_addr),
    .o_fea_addr_v                                (o_fea_addr_v),
    .fifo_empty                                  (o_fea_empty)
);



(* dont_touch = "yes" *) Inflight_Flow_Addr  inflight_flow_addr(
    .clk                                        (clk),
    .rst_n                                      (rst_n),
    .clk_ext                                    (clk_ext),
    .free_one_addr                              (free_one_flow),
    .reach_thrh                                 (o_reach_thrh2alu),
    .i_fea_addr                                 (o_hash2alu),
    .i_r_fea_addr                               (o_r_hash2alu),
    .free_fea_addr                              (free_addr_inflightf2track),
    .free_r_fea_addr                            (free_r_addr_inflightf2track),
    .free_fea_addr_v                            (free_addr_v_inflight2track)
);


endmodule