/*

    The top module of TFE

*/

module TFE_top (
    input                                               rst,
    input                                               clk,

    
    input   [103:0]                                     ip_tuple,
    input   [255:0]                                     i_raw_feature,
    input                                               ip_valid,
    
    output                                              first_pkt,
    output                                              large_flow,
    output  [15:0]                                      o_hash,
    output                                              o_hash_valid,
    output  [255:0]                                     o_feature
);



// calculating hash
wire    [15:0]                                          hash_gener2judge;
wire                                                    hash_valid_gener2judge;
TFE_Hash_Gener tfe_hash_gener (
    .clk                                                (clk),
    .rst                                                (rst),
    .d                                                  (ip_tuple),
    .d_valid                                            (ip_valid),
    .crc_out                                            (hash_gener2judge),
    .hash_valid                                         (hash_valid_gener2judge)
);



// quant raw bytes into fix format
wire    [255:0]                                         fix8_feature;
wire                                                    fix8_feature_valid;
TFE_Preprocess tfe_preprocess (
    .clk                                                (clk),
    .rst                                                (rst),
    .i_feature                                          (i_raw_feature),
    .i_feature_valid                                    (ip_valid),
    .o_feature                                          (fix8_feature),
    .o_feature_valid                                    (fix8_feature_valid)
);




TFE_Hash_Judging tfe_hash_judge (
    .clk                                                (clk),
    .rst                                                (rst),
    .i_hash                                             (hash_gener2judge),
    .i_hash_valid                                       (hash_valid_gener2judge),
    .first_pkt                                          (first_pkt),
    .large_flow                                         (large_flow),
    .o_hash                                             (o_hash),
    .o_hash_valid                                       (o_hash_valid)
);


reg     [255:0]                                         feature_r0;
reg     [255:0]                                         feature_r1;
reg     [255:0]                                         feature_r2;
reg     [255:0]                                         feature_r3;
reg     [255:0]                                         feature_r4;
reg     [255:0]                                         feature_r5;
assign  o_feature                               =       feature_r2;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        feature_r0                              <=      256'd0;
        feature_r1                              <=      256'd0;
        feature_r2                              <=      256'd0;
        feature_r3                              <=      256'd0;
        feature_r4                              <=      256'd0;
        feature_r5                              <=      256'd0;
    end
    else begin
        feature_r0                              <=      fix8_feature;
        feature_r1                              <=      feature_r0;
        feature_r2                              <=      feature_r1;
        feature_r3                              <=      feature_r2;
        feature_r4                              <=      feature_r3;
        feature_r5                              <=      feature_r4;
    end
end






endmodule