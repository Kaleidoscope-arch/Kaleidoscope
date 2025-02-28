/* 

This file is the relu module of VPE.

*/

module VPE_ReLU (
    input                                                   clk,
    input                                                   rst,

    input   [63:0]                                          i_data,
    input                                                   i_data_v,
    input                                                   en_relu,
    input   [4:0]                                           i_rf_idx,
    input   [1:0]                                           i_rf_mux,


    output  [63:0]                                          o_data,
    output                                                  o_data_v,
    output  reg [4:0]                                       o_rf_idx,
    output  reg [1:0]                                       o_rf_mux
);


reg     [63:0]                                              o_data_r;
reg                                                         o_data_v_r;

assign  o_data                                      =       o_data_r;
assign  o_data_v                                    =       o_data_v_r;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_data_v_r                                  <=      1'b0;
    end
    else begin
        o_data_v_r                                  <=      i_data_v;
        o_rf_idx                                    <=      i_rf_idx;
        o_rf_mux                                    <=      i_rf_mux;
    end
end

genvar i;
generate
    for (i=0; i<8; i=i+1) begin: relu_loop
        always @ (posedge clk) begin
            if(en_relu) begin
                if (~i_data[i*8+7]) begin
                    o_data_r[i*8+7:i*8]         <=      i_data[i*8+7:i*8];
                end
                else begin
                    o_data_r[i*8+7:i*8]         <=      'd0;
                end
            end
            else begin
                o_data_r[i*8+7:i*8]             <=      i_data[i*8+7:i*8];
            end
        end
    end
endgenerate


endmodule