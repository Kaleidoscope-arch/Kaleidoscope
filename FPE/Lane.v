/* 

This file is the Lane in VPE, which contains eight Dot_PE.
Lane is the basic unit of SIMD structure.

*/

module SIMD_LANE (
    input                                                   clk,
    input                                                   rst,
    input   [63:0]                                          i_data,
    input                                                   i_data_v,
    input   [511:0]                                         i_weight,
    output  [63:0]                                          o_data,
    output                                                  o_data_v
);

wire    [7:0]                                               o_data_v_w;
wire    [63:0]                                              o_data_w;

assign  o_data                                      =       o_data_w;
assign  o_data_v                                    =       o_data_v_w[0];

genvar i;
generate
    for (i=0; i<8; i=i+1) begin: dot_loop
        Dot_PE dot_pe(
            .clk                                            (clk),
            .rst                                            (rst),
            .i_data                                         (i_data),
            .i_data_v                                       (i_data_v),
            .i_weight                                       (i_weight[i*64+63:i*64]),
            .o_data                                         (o_data_w[i*8+7:i*8]),
            .o_data_v                                       (o_data_v_w[i])
        );

    end

endgenerate



endmodule