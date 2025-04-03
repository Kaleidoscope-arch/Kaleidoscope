/*  This module is used for tracking a flow with two directions.
    
    This module will track and keep information for master direction, 
    slave direction and global flow. 
    It is defined that the direction of first packet is the master d-
    irection. 

    Three tracker are in this module: master_tracker, slave_tracker a-
    nd global_tracker.

 */

`define META_LEN 136

module flow_tracker(
    input   wire                                clk,
    input   wire                                rst_n,

    input   wire    [31:0]                      hash, // hash value of packet
    input   wire    [31:0]                      r_hash, // hash value of reverse direction
    input   wire                                hash_v,
    input   wire    [15:0]                      i_pkt_size,
    input   wire    [103:0]                     tuple,
    input   wire    [15:0]                      pkt_arvt,

    output  wire                                hit_w,
    output  wire                                rd_main_cache,
    output  wire    [11:0]                      rd_main_cache_addr_w,

    // threshold and 1-stage feature output to buffer/alu
    input   wire    [7:0]                       threshold,
    // used by vector feature
    output  wire    [7:0]                       o_pkt_size,
    output  wire    [7:0]                       pkt_arit,
    output  wire    [7:0]                       n_pkt,
    output  wire                                size_arit_v,
    output  wire    [31:0]                      o_hash,
    output  wire    [31:0]                      o_r_hash,
    // flow feature controlled by threshold
    output  wire    [7:0]                       flow_durt,
    output  wire    [7:0]                       flow_size,
    output  wire                                reach_thrh,

    // free addr signal
    input   wire                                free_addr_v,
    input   wire    [11:0]                      free_addr,
    input   wire    [11:0]                      free_r_addr,

    // meta feature
    output  wire    [`META_LEN-1:0]             meta_fea_w,
    output  wire                                meta_fea_v_w
);


assign        meta_fea_v_w                    =            meta_fea_v_reg3;
assign        meta_fea_w                        =            meta_fea_reg3;

reg     [`META_LEN-1: 0]                        meta_fea_reg0;
reg     [`META_LEN-1: 0]                        meta_fea_reg1;
reg     [`META_LEN-1: 0]                        meta_fea_reg2;
reg     [`META_LEN-1: 0]                        meta_fea_reg3;
reg                                             meta_fea_v_reg0;
reg                                             meta_fea_v_reg1;
reg                                             meta_fea_v_reg2;
reg                                             meta_fea_v_reg3;



// cacheing meta feature outside the tracker
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        meta_fea_v_reg0                            <=            'd0;
        meta_fea_v_reg1                            <=            'd0;
        meta_fea_v_reg2                            <=            'd0;
        meta_fea_v_reg3                            <=            'd0;
        meta_fea_reg0                           <=            'd0;  
        meta_fea_reg1                           <=            'd0;  
        meta_fea_reg2                           <=            'd0;  
        meta_fea_reg3                           <=            'd0;  
    end
    else begin
        meta_fea_reg0                           <=            {i_pkt_size, tuple, pkt_arvt};
        meta_fea_reg1                           <=            meta_fea_reg0;
        meta_fea_reg2                           <=            meta_fea_reg1;
        meta_fea_reg3                           <=            meta_fea_reg2;
        meta_fea_v_reg0                            <=            hash_v;
        meta_fea_v_reg1                            <=            meta_fea_v_reg0;
        meta_fea_v_reg2                            <=            meta_fea_v_reg1;
        meta_fea_v_reg3                            <=            meta_fea_v_reg2;
    end
end




// wire                                        hit_master;
// wire                                        master_master;


Tracker tracker(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .hash                                   (hash),
    .r_hash                                 (r_hash),
    .hash_v                                 (hash_v),
    .pkt_arvt                               (pkt_arvt),
    .i_pkt_size                             (i_pkt_size),
    .hit_w                                  (hit_w),
    .rd_main_cache                          (rd_main_cache),
    .rd_main_cache_addr_w                   (rd_main_cache_addr_w),
    .threshold                              (threshold),
    .o_pkt_size                             (o_pkt_size),
    .o_pkt_arit                             (pkt_arit),
    .o_n_pkt                                (n_pkt),
    .o_size_arit_v                          (size_arit_v),
    .o_hash                                 (o_hash),
    .o_r_hash                               (o_r_hash),
    .o_flow_durt                            (flow_durt),
    .o_flow_size                            (flow_size),
    .o_reach_thrh                           (reach_thrh),
    .free_addr                              (free_addr),
    .free_r_addr                            (free_r_addr),
    .free_addr_v                            (free_addr_v)
);




endmodule