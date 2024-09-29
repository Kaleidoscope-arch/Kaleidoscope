/* 

This module is the bias storage of VPE.

*/


module VPE_Bias_ROM(
    input                                                   clk,
    input                                                   rst,
    
    // reading ports
    input                                                   rd_valid,
    input   [7:0]                                           raddr,
    output  [63:0]                                          o_data,
    output                                                  o_data_valid
);


assign  o_data = bias_bram_r;
wire    [63:0]                              bias_bram_w;
reg     [63:0]                              bias_bram_r;
always @ (posedge clk) begin
    bias_bram_r                     <=      bias_bram_w;
end




Bias_ROM bram_0 (
    .clka                                   (clk),
    .addra                                  (raddr),
    .wea                                    (1'b0),
    .dina                                   (64'b0),
    .douta                                  (bias_bram_w)
);




endmodule