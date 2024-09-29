/*

    Function: preprocess input feature, turning integer into
    fix number: 1bit sign, 2bit interge, 5 bit decimal.

*/

module TFE_Preprocess (
    input                                               rst,
    input                                               clk,

    input   [255:0]                                     i_feature,
    input                                               i_feature_valid,
    output  [255:0]                                     o_feature,
    output                                              o_feature_valid
);

reg     [255:0]                                         o_feature_reg;
assign  o_feature                               =       o_feature_reg;

genvar i;
generate
for (i=0; i<32; i=i+1) begin
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            o_feature_reg[i*8+7:i*8]            <=      8'b0;
        end
        else begin
            o_feature_reg[i*8+7:i*8]            <=      {3'b0, i_feature[i*8+7:i*8+3]};
        end
    end
end
endgenerate



reg                                                     o_feature_valid_reg;
assign  o_feature_valid                         =       o_feature_valid_reg;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_feature_valid_reg                     <=      1'b0;
    end
    else begin
        o_feature_valid_reg                     <=      i_feature_valid;
    end
end


endmodule