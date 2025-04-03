/* 
    This module is data buffer to ALUs, it receives meta-feature from tracker
    and history feature data from main_feature_mem.

    There exists two conditions:
    a. current hash hit. History feature data and meta-feature will be send to 
    ALUs together;
    b. current hash non-hit. Only meta-data will be sent to ALUs.

    This module will control related data valid signals.

 */

`define     META_LEN    168

module Buffer2alu (
    input   wire                                clk,
    input   wire                                rst_n,
    input   wire                                hit,
    // meta feature 
    input   wire    [`META_LEN-1:0]             i_meta_fea,
    input   wire                                i_meta_fea_v,


    // input 1-stage feature
    input    wire    [7:0]                        i_pkt_size,
    input    wire    [7:0]                        i_pkt_arit,
    input    wire    [7:0]                        i_n_pkt,
    input    wire                                 i_size_arit_v,
    input    wire    [31:0]                       i_hash,
    input    wire    [31:0]                       i_r_hash,
    input    wire    [7:0]                        i_flow_durt,
    input    wire    [7:0]                        i_flow_size,
    input    wire                                 i_reach_thrh,

    // input cache data
    input   wire                                i_cache_data_v,
    input   wire   [7:0]                        i_max_pkt_size,
    input   wire   [7:0]                        i_min_pkt_size,
    input   wire   [7:0]                        i_max_pkt_arit,
    input   wire   [7:0]                        i_min_pkt_arit,
    input   wire   [159:0]                      i_vec_feature,


    // output 1-stage feature
    output    wire    [7:0]                     o_pkt_size,
    output    wire    [7:0]                     o_pkt_arit,
    output    wire    [7:0]                     o_n_pkt,
    output    wire                              o_size_arit_v,
    output    wire    [31:0]                    o_hash,
    output    wire    [31:0]                    o_r_hash,
    output    wire    [7:0]                     o_flow_durt,
    output    wire    [7:0]                     o_flow_size,
    output    wire                              o_reach_thrh,
    // output meta feature
    output    wire    [`META_LEN-1:0]             o_meta_fea,
    output    wire                                o_meta_fea_v,

    // output cache feature
    output  wire    [7:0]                       o_max_pkt_size,
    output  wire    [7:0]                       o_min_pkt_size,
    output  wire    [7:0]                       o_max_pkt_arit,
    output  wire    [7:0]                       o_min_pkt_arit,
    output  wire    [159:0]                     o_vec_feature,
    output    wire                              o_cache_data_v,

    output    wire    [7:0]                        o_threshold
);


assign        o_meta_fea                           =            meta_fea_reg1;
assign        o_meta_fea_v                         =            meta_fea_v_reg1;

assign        o_pkt_size                           =            pkt_size_r1;
assign        o_pkt_arit                           =            pkt_arit_r1;
assign        o_n_pkt                              =            n_pkt_r1;
assign        o_size_arit_v                        =            size_arit_v_r1;
assign        o_hash                               =            hash_r1;
assign        o_r_hash                             =            r_hash_r1;
assign        o_flow_durt                          =            flow_durt_r1;
assign        o_flow_size                          =            flow_size_r1;
assign        o_reach_thrh                         =            reach_thrh_r1;



assign          o_cache_data_v                      =               i_cache_data_v;
assign          o_max_pkt_size                      =               i_max_pkt_size;
assign          o_min_pkt_size                      =               i_min_pkt_size;
assign          o_max_pkt_arit                      =               i_max_pkt_arit;
assign          o_min_pkt_arit                      =               i_min_pkt_arit;
assign          o_vec_feature                       =               i_vec_feature;
assign          o_cache_data_v                      =               i_cache_data_v;






reg                                             hit_reg0;
reg                                             hit_reg1;
reg                                             hit_reg2;
reg                                             hit_reg3;


reg     [`META_LEN-1:0]                            meta_fea_reg0;
reg     [`META_LEN-1:0]                            meta_fea_reg1;
reg     [`META_LEN-1:0]                            meta_fea_reg2;
reg     [`META_LEN-1:0]                            meta_fea_reg3;
reg                                                meta_fea_v_reg0;
reg                                                meta_fea_v_reg1;
reg                                                meta_fea_v_reg2;
reg                                                meta_fea_v_reg3;



always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        hit_reg0                        <=              1'd0;
        hit_reg1                        <=              1'd0;
        hit_reg2                        <=              1'd0;
        hit_reg3                        <=              1'd0;
    end
    else begin
        hit_reg0                        <=              hit;
        hit_reg1                        <=              hit_reg0;
        hit_reg2                        <=              hit_reg1;
        hit_reg3                        <=              hit_reg2;
    end
end


always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        meta_fea_v_reg0                    <=                1'd0;
        meta_fea_v_reg1                    <=                1'd0;
        meta_fea_v_reg2                    <=                1'd0;
        meta_fea_v_reg3                    <=                1'd0;
        meta_fea_reg0                    <=                `META_LEN'd0;
        meta_fea_reg1                    <=                `META_LEN'd0;
        meta_fea_reg2                    <=                `META_LEN'd0;
        meta_fea_reg3                    <=                `META_LEN'd0;
    end
    else begin
        meta_fea_v_reg0                    <=                i_meta_fea_v;
        meta_fea_v_reg1                    <=                meta_fea_v_reg0;
        meta_fea_v_reg2                    <=                meta_fea_v_reg1;
        meta_fea_v_reg3                    <=                meta_fea_v_reg2;
        meta_fea_reg0                    <=                i_meta_fea;
        meta_fea_reg1                    <=                meta_fea_reg0;
        meta_fea_reg2                    <=                meta_fea_reg1;
        meta_fea_reg3                    <=                meta_fea_reg2;
    end
end



reg        [7:0]                                            pkt_size_r0;
reg        [7:0]                                            pkt_arit_r0;
reg        [7:0]                                            n_pkt_r0;
reg                                                        size_arit_v_r0;
reg        [31:0]                                            hash_r0;
reg        [31:0]                                            r_hash_r0;
reg        [7:0]                                            flow_durt_r0;
reg        [7:0]                                            flow_size_r0;
reg                                                        reach_thrh_r0;

reg        [7:0]                                            pkt_size_r1;
reg        [7:0]                                            pkt_arit_r1;
reg        [7:0]                                            n_pkt_r1;
reg                                                        size_arit_v_r1;
reg        [31:0]                                            hash_r1;
reg        [31:0]                                            r_hash_r1;
reg        [7:0]                                            flow_durt_r1;
reg        [7:0]                                            flow_size_r1;
reg                                                        reach_thrh_r1;

reg        [7:0]                                            pkt_size_r2;
reg        [7:0]                                            pkt_arit_r2;
reg        [7:0]                                            n_pkt_r2;
reg                                                        size_arit_v_r2;
reg        [31:0]                                            hash_r2;
reg        [7:0]                                            flow_durt_r2;
reg        [7:0]                                            flow_size_r2;
reg                                                        reach_thrh_r2;

reg        [7:0]                                            pkt_size_r3;
reg        [7:0]                                            pkt_arit_r3;
reg        [7:0]                                            n_pkt_r3;
reg                                                        size_arit_v_r3;
reg        [31:0]                                            hash_r3;
reg        [7:0]                                            flow_durt_r3;
reg        [7:0]                                            flow_size_r3;
reg                                                        reach_thrh_r3;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        pkt_size_r0                        <=                'd0;
        pkt_arit_r0                        <=                'd0;
        n_pkt_r0                        <=                'd0;
        size_arit_v_r0                    <=                'd0;
        hash_r0                            <=                'd0;
        flow_durt_r0                    <=                'd0;
        flow_size_r0                    <=                'd0;
        reach_thrh_r0                    <=                'd0;

        pkt_size_r1                        <=                'd0;
        pkt_arit_r1                        <=                'd0;
        n_pkt_r1                        <=                'd0;
        size_arit_v_r1                    <=                'd0;
        hash_r1                            <=                'd0;
        flow_durt_r1                    <=                'd0;
        flow_size_r1                    <=                'd0;
        reach_thrh_r1                    <=                'd0;

        pkt_size_r2                        <=                'd0;
        pkt_arit_r2                        <=                'd0;
        n_pkt_r2                        <=                'd0;
        size_arit_v_r2                    <=                'd0;
        hash_r2                            <=                'd0;
        flow_durt_r2                    <=                'd0;
        flow_size_r2                    <=                'd0;
        reach_thrh_r2                    <=                'd0;

        pkt_size_r3                        <=                'd0;
        pkt_arit_r3                        <=                'd0;
        n_pkt_r3                        <=                'd0;
        size_arit_v_r3                    <=                'd0;
        hash_r3                            <=                'd0;
        flow_durt_r3                    <=                'd0;
        flow_size_r3                    <=                'd0;
        reach_thrh_r3                    <=                'd0;
    end
    else begin
        pkt_size_r0                     <=                  i_pkt_size;
        pkt_arit_r0                     <=                  i_pkt_arit;
        n_pkt_r0                        <=                  i_n_pkt;
        size_arit_v_r0                  <=                  i_size_arit_v;
        hash_r0                         <=                  i_hash;
        r_hash_r0                       <=                  i_r_hash;
        flow_durt_r0                    <=                  i_flow_durt;
        flow_size_r0                    <=                  i_flow_size;
        reach_thrh_r0                   <=                  i_reach_thrh;

        pkt_size_r1                        <=                pkt_size_r0;
        pkt_arit_r1                        <=                pkt_arit_r0;
        n_pkt_r1                        <=                n_pkt_r0;
        size_arit_v_r1                    <=                size_arit_v_r0;
        hash_r1                            <=                hash_r0;
        r_hash_r1                            <=                r_hash_r0;
        flow_durt_r1                    <=                flow_durt_r0;
        flow_size_r1                    <=                flow_size_r0;
        reach_thrh_r1                    <=                reach_thrh_r0;

        pkt_size_r2                        <=                pkt_size_r1;
        pkt_arit_r2                        <=                pkt_arit_r1;
        n_pkt_r2                        <=                n_pkt_r1;
        size_arit_v_r2                    <=                size_arit_v_r1;
        hash_r2                            <=                hash_r1;
        flow_durt_r2                    <=                flow_durt_r1;
        flow_size_r2                    <=                flow_size_r1;
        reach_thrh_r2                    <=                reach_thrh_r1;

        pkt_size_r3                        <=                pkt_size_r2;
        pkt_arit_r3                        <=                pkt_arit_r2;
        n_pkt_r3                        <=                n_pkt_r2;
        size_arit_v_r3                    <=                size_arit_v_r2;
        hash_r3                            <=                hash_r2;
        flow_durt_r3                    <=                flow_durt_r2;
        flow_size_r3                    <=                flow_size_r2;
        reach_thrh_r3                    <=                reach_thrh_r2;

    end
end


endmodule