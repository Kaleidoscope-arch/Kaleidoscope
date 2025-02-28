/* 

This file is the input pre-reg for Vector SIMD unit. It achieves
32Byte data from vector regfile and reorder them for SIMD to co-
mpute.

*/

module SIMD_in_Reg(
    input                                                   clk,
    input                                                   rst,

    input   [255:0]                                         i_data,
    input                                                   i_data_v,
    input   [4:0]                                           i_rf_idx,
    input   [1:0]                                           i_rf_mux,
    input                                                   i_en_simd,
    input                                                   i_en_vadd,
    input                                                   i_en_relu,

    output  reg [255:0]                                     o_data,
    output  reg                                             o_data_v,
    output  reg [4:0]                                       o_rf_idx,
    output  reg [1:0]                                       o_rf_mux,
    output  reg                                             o_en_simd,
    output  reg                                             o_en_vadd,
    output  reg                                             o_en_relu
);




always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_data_v                                    <=      1'b0;
        o_en_simd                                   <=      1'b0;
        o_en_vadd                                   <=      1'b0;
        o_en_relu                                   <=      1'b0;
    end
    else begin
        o_data_v                                    <=      i_data_v;
        o_rf_idx                                    <=      i_rf_idx;
        o_rf_mux                                    <=      i_rf_mux;
        o_en_simd                                   <=      i_en_simd;
        o_en_vadd                                   <=      i_en_vadd;
        o_en_relu                                   <=      i_en_relu;
        if(i_data_v)
            o_data                                  <=      i_data;
    end
end

endmodule