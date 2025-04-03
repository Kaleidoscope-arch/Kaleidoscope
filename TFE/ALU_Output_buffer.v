/*  
    This module is the output buffer of alu cluster, used for align
    cycles of all sub-ALU.
    
*/

module ALU_Output_buffer (
    input   wire                                clk,
    input   wire                                rst_n,

    // min or max value data
    input   wire    [7:0]                       max_pkt_size,
    input   wire    [7:0]                       min_pkt_size,
    input   wire    [7:0]                       max_pkt_arit,
    input   wire    [7:0]                       min_pkt_arit,
    input   wire                                extreme_data_v,

    // average value feature
    input   wire    [7:0]                       avg_pkt_size,
    input   wire    [7:0]                       avg_pkt_arit,
    input   wire    [7:0]                       avg_pkt_pps,
    input   wire    [7:0]                       avg_pkt_bps,
    input   wire                                avg_val_v,

    // vector feature
    input   wire    [159:0]                     i_pkt_size_vec,
    input   wire    [159:0]                     i_pkt_arit_vec,
    // 00: non-work, 01: pkt_size only, 10: pkt_arit only, 
    // 11: high-80bit for pkt_size_vec, low-80bit for pkt_arit_vec
    input   wire    [1:0]                       vec_mode, 

    // 1 stage feature
    input   wire    [7:0]                       n_pkt,
    input   wire    [7:0]                       flow_durt,
    input   wire    [7:0]                       flow_size,
    input   wire    [7:0]                       pkt_arit,
    input   wire                                size_arit_v,

    input   wire    [31:0]                      i_hash,
    input   wire    [127:0]                     i_meta,


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


assign  wea_cache           =                   extreme_data_v;
assign  wcache_addr         =                   i_hash_r0;
assign  wcache_data         =                   {
        o_vec_feature,
        max_pkt_size,
        min_pkt_size,
        max_pkt_arit,
        min_pkt_arit };



assign  wea_mem             =                   avg_val_v_r0;
assign  wmem_addr           =                   i_hash_r5;
assign  wmem_data           =                   {
        o_vec_feature_r4,
        max_pkt_size_r4,
        min_pkt_size_r4,
        max_pkt_arit_r4,
        min_pkt_arit_r4,
        avg_pkt_size_r0,
        avg_pkt_arit_r0,
        avg_pkt_pps_r0,
        avg_pkt_bps_r0,
        n_pkt_r5,
        flow_durt_r5,
        flow_size_r5,
        pkt_arit_r5,
        i_meta_r5
        };


// caching 1-stage feature
reg   [7:0]                n_pkt_r0;
reg   [7:0]                n_pkt_r1;
reg   [7:0]                n_pkt_r2;
reg   [7:0]                n_pkt_r3;
reg   [7:0]                n_pkt_r4;
reg   [7:0]                n_pkt_r5;
reg   [7:0]                flow_durt_r0;
reg   [7:0]                flow_durt_r1;
reg   [7:0]                flow_durt_r2;
reg   [7:0]                flow_durt_r3;
reg   [7:0]                flow_durt_r4;
reg   [7:0]                flow_durt_r5;
reg   [7:0]                flow_size_r0;
reg   [7:0]                flow_size_r1;
reg   [7:0]                flow_size_r2;
reg   [7:0]                flow_size_r3;
reg   [7:0]                flow_size_r4;
reg   [7:0]                flow_size_r5;
reg   [7:0]                pkt_arit_r0;
reg   [7:0]                pkt_arit_r1;
reg   [7:0]                pkt_arit_r2;
reg   [7:0]                pkt_arit_r3;
reg   [7:0]                pkt_arit_r4;
reg   [7:0]                pkt_arit_r5;
reg                       size_arit_v_r0;
reg                       size_arit_v_r1;
reg                       size_arit_v_r2;
reg                       size_arit_v_r3;
reg                       size_arit_v_r4;
reg                       size_arit_v_r5;
always @ (posedge clk or negedge rst_n) begin
   if(~rst_n) begin
        n_pkt_r0             <=      'd0;
        n_pkt_r1             <=      'd0;
        n_pkt_r2             <=      'd0;
        n_pkt_r3             <=      'd0;
        n_pkt_r4             <=      'd0;
        n_pkt_r5             <=      'd0;

        flow_durt_r0             <=      'd0;
        flow_durt_r1             <=      'd0;
        flow_durt_r2             <=      'd0;
        flow_durt_r3             <=      'd0;
        flow_durt_r4             <=      'd0;
        flow_durt_r5             <=      'd0;

        flow_size_r0             <=      'd0;
        flow_size_r1             <=      'd0;
        flow_size_r2             <=      'd0;
        flow_size_r3             <=      'd0;
        flow_size_r4             <=      'd0;
        flow_size_r5             <=      'd0;

        pkt_arit_r0             <=      'd0;
        pkt_arit_r1             <=      'd0;
        pkt_arit_r2             <=      'd0;
        pkt_arit_r3             <=      'd0;
        pkt_arit_r4             <=      'd0;
        pkt_arit_r5             <=      'd0;

        size_arit_v_r0             <=      'd0;
        size_arit_v_r1             <=      'd0;
        size_arit_v_r2             <=      'd0;
        size_arit_v_r3             <=      'd0;
        size_arit_v_r4             <=      'd0;
        size_arit_v_r5             <=      'd0;
   end
   else begin
        n_pkt_r0              <=      n_pkt;
        n_pkt_r1              <=      n_pkt_r0;
        n_pkt_r2              <=      n_pkt_r1;
        n_pkt_r3              <=      n_pkt_r2;
        n_pkt_r4              <=      n_pkt_r3;
        n_pkt_r5              <=      n_pkt_r4;

        flow_durt_r0              <=      flow_durt;
        flow_durt_r1              <=      flow_durt_r0;
        flow_durt_r2              <=      flow_durt_r1;
        flow_durt_r3              <=      flow_durt_r2;
        flow_durt_r4              <=      flow_durt_r3;
        flow_durt_r5              <=      flow_durt_r4;

        flow_size_r0              <=      flow_size;
        flow_size_r1              <=      flow_size_r0;
        flow_size_r2              <=      flow_size_r1;
        flow_size_r3              <=      flow_size_r2;
        flow_size_r4              <=      flow_size_r3;
        flow_size_r5              <=      flow_size_r4;

        pkt_arit_r0              <=      pkt_arit;
        pkt_arit_r1              <=      pkt_arit_r0;
        pkt_arit_r2              <=      pkt_arit_r1;
        pkt_arit_r3              <=      pkt_arit_r2;
        pkt_arit_r4              <=      pkt_arit_r3;
        pkt_arit_r5              <=      pkt_arit_r4;

        size_arit_v_r0              <=      size_arit_v;
        size_arit_v_r1              <=      size_arit_v_r0;
        size_arit_v_r2              <=      size_arit_v_r1;
        size_arit_v_r3              <=      size_arit_v_r2;
        size_arit_v_r4              <=      size_arit_v_r3;
        size_arit_v_r5              <=      size_arit_v_r4;
   end
end


// caching extreme data feature
reg   [7:0]                max_pkt_size_r0;
reg   [7:0]                max_pkt_size_r1;
reg   [7:0]                max_pkt_size_r2;
reg   [7:0]                max_pkt_size_r3;
reg   [7:0]                max_pkt_size_r4;

reg   [7:0]                min_pkt_size_r0;
reg   [7:0]                min_pkt_size_r1;
reg   [7:0]                min_pkt_size_r2;
reg   [7:0]                min_pkt_size_r3;
reg   [7:0]                min_pkt_size_r4;

reg   [7:0]                max_pkt_arit_r0;
reg   [7:0]                max_pkt_arit_r1;
reg   [7:0]                max_pkt_arit_r2;
reg   [7:0]                max_pkt_arit_r3;
reg   [7:0]                max_pkt_arit_r4;

reg   [7:0]                min_pkt_arit_r0;
reg   [7:0]                min_pkt_arit_r1;
reg   [7:0]                min_pkt_arit_r2;
reg   [7:0]                min_pkt_arit_r3;
reg   [7:0]                min_pkt_arit_r4;

reg                       extreme_data_v_r0;
reg                       extreme_data_v_r1;
reg                       extreme_data_v_r2;
reg                       extreme_data_v_r3;
reg                       extreme_data_v_r4;
always @ (posedge clk or negedge rst_n) begin
   if(~rst_n) begin
        max_pkt_size_r0             <=      'd0;
        max_pkt_size_r1             <=      'd0;
        max_pkt_size_r2             <=      'd0;
        max_pkt_size_r3             <=      'd0;
        max_pkt_size_r4             <=      'd0;

        min_pkt_size_r0             <=      'd0;
        min_pkt_size_r1             <=      'd0;
        min_pkt_size_r2             <=      'd0;
        min_pkt_size_r3             <=      'd0;
        min_pkt_size_r4             <=      'd0;

        max_pkt_arit_r0             <=      'd0;
        max_pkt_arit_r1             <=      'd0;
        max_pkt_arit_r2             <=      'd0;
        max_pkt_arit_r3             <=      'd0;
        max_pkt_arit_r4             <=      'd0;

        min_pkt_arit_r0             <=      'd0;
        min_pkt_arit_r1             <=      'd0;
        min_pkt_arit_r2             <=      'd0;
        min_pkt_arit_r3             <=      'd0;
        min_pkt_arit_r4             <=      'd0;

        extreme_data_v_r0             <=      'd0;
        extreme_data_v_r1             <=      'd0;
        extreme_data_v_r2             <=      'd0;
        extreme_data_v_r3             <=      'd0;
        extreme_data_v_r4             <=      'd0;
   end
   else begin
        max_pkt_size_r0              <=      max_pkt_size;
        max_pkt_size_r1              <=      max_pkt_size_r0;
        max_pkt_size_r2              <=      max_pkt_size_r1;
        max_pkt_size_r3              <=      max_pkt_size_r2;
        max_pkt_size_r4              <=      max_pkt_size_r3;

        min_pkt_size_r0              <=      min_pkt_size;
        min_pkt_size_r1              <=      min_pkt_size_r0;
        min_pkt_size_r2              <=      min_pkt_size_r1;
        min_pkt_size_r3              <=      min_pkt_size_r2;
        min_pkt_size_r4              <=      min_pkt_size_r3;

        max_pkt_arit_r0              <=      max_pkt_arit;
        max_pkt_arit_r1              <=      max_pkt_arit_r0;
        max_pkt_arit_r2              <=      max_pkt_arit_r1;
        max_pkt_arit_r3              <=      max_pkt_arit_r2;
        max_pkt_arit_r4              <=      max_pkt_arit_r3;

        min_pkt_arit_r0              <=      min_pkt_arit;
        min_pkt_arit_r1              <=      min_pkt_arit_r0;
        min_pkt_arit_r2              <=      min_pkt_arit_r1;
        min_pkt_arit_r3              <=      min_pkt_arit_r2;
        min_pkt_arit_r4              <=      min_pkt_arit_r3;

        extreme_data_v_r0              <=      extreme_data_v;
        extreme_data_v_r1              <=      extreme_data_v_r0;
        extreme_data_v_r2              <=      extreme_data_v_r1;
        extreme_data_v_r3              <=      extreme_data_v_r2;
        extreme_data_v_r4              <=      extreme_data_v_r3;
   end
end


// caching average value feature
reg   [7:0]                avg_pkt_size_r0;
reg   [7:0]                avg_pkt_arit_r0;
reg   [7:0]                avg_pkt_pps_r0;
reg   [7:0]                avg_pkt_bps_r0;
reg                       avg_val_v_r0;
always @ (posedge clk or negedge rst_n) begin
   if(~rst_n) begin
        avg_pkt_size_r0             <=      'd0;
        avg_pkt_arit_r0             <=      'd0;
        avg_pkt_pps_r0              <=      'd0;
        avg_pkt_bps_r0              <=      'd0;
        avg_val_v_r0                <=      'd0;
   end
   else begin
        avg_pkt_size_r0              <=      avg_pkt_size;
        avg_pkt_arit_r0              <=      avg_pkt_arit;
        avg_pkt_pps_r0               <=      avg_pkt_pps;
        avg_pkt_bps_r0               <=      avg_pkt_bps;
        avg_val_v_r0                 <=      avg_val_v;
   end
end


// caching meta feature and hash value
reg   [31:0]                i_hash_r0;
reg   [31:0]                i_hash_r1;
reg   [31:0]                i_hash_r2;
reg   [31:0]                i_hash_r3;
reg   [31:0]                i_hash_r4;
reg   [31:0]                i_hash_r5;

reg   [127:0]                i_meta_r0;
reg   [127:0]                i_meta_r1;
reg   [127:0]                i_meta_r2;
reg   [127:0]                i_meta_r3;
reg   [127:0]                i_meta_r4;
reg   [127:0]                i_meta_r5;
always @ (posedge clk or negedge rst_n) begin
   if(~rst_n) begin
        i_hash_r0             <=      'd0;
        i_hash_r1             <=      'd0;
        i_hash_r2             <=      'd0;
        i_hash_r3             <=      'd0;
        i_hash_r4             <=      'd0;
        i_hash_r5             <=      'd0;

        i_meta_r0             <=      'd0;
        i_meta_r1             <=      'd0;
        i_meta_r2             <=      'd0;
        i_meta_r3             <=      'd0;
        i_meta_r4             <=      'd0;
        i_meta_r5             <=      'd0;
   end
   else begin
        i_hash_r0              <=      i_hash;
        i_hash_r1              <=      i_hash_r0;
        i_hash_r2              <=      i_hash_r1;
        i_hash_r3              <=      i_hash_r2;
        i_hash_r4              <=      i_hash_r3;
        i_hash_r5              <=      i_hash_r4;

        i_meta_r0              <=      i_meta;
        i_meta_r1              <=      i_meta_r0;
        i_meta_r2              <=      i_meta_r1;
        i_meta_r3              <=      i_meta_r2;
        i_meta_r4              <=      i_meta_r3;
        i_meta_r5              <=      i_meta_r4;
   end
end


reg     [159:0]                            o_vec_feature;
always @ * begin
    case (vec_mode)
    2'b00:  o_vec_feature   =   160'd0;
    2'b01:  o_vec_feature   =   i_pkt_size_vec;
    2'b10:  o_vec_feature   =   i_pkt_arit_vec;
    2'b11:  o_vec_feature   =   {i_pkt_size_vec[79:0], i_pkt_arit_vec[79:0]};
    endcase
end

reg   [159:0]                o_vec_feature_r0;
reg   [159:0]                o_vec_feature_r1;
reg   [159:0]                o_vec_feature_r2;
reg   [159:0]                o_vec_feature_r3;
reg   [159:0]                o_vec_feature_r4;
reg   [159:0]                o_vec_feature_r5;
always @ (posedge clk or negedge rst_n) begin
   if(~rst_n) begin
        o_vec_feature_r0             <=      'd0;
        o_vec_feature_r1             <=      'd0;
        o_vec_feature_r2             <=      'd0;
        o_vec_feature_r3             <=      'd0;
        o_vec_feature_r4             <=      'd0;
        o_vec_feature_r5             <=      'd0;
   end
   else begin
        o_vec_feature_r0              <=      o_vec_feature;
        o_vec_feature_r1              <=      o_vec_feature_r0;
        o_vec_feature_r2              <=      o_vec_feature_r1;
        o_vec_feature_r3              <=      o_vec_feature_r2;
        o_vec_feature_r4              <=      o_vec_feature_r3;
        o_vec_feature_r5              <=      o_vec_feature_r4;
   end
end

endmodule