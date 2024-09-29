/* 

This module is the weights storage of VPE.

*/

module VPE_Weights_ROM(
    input                                                   clk,
    input                                                   rst,
    
    // reading ports
    input                                                   rd_valid,
    input   [7:0]                                           raddr,
    output  [2047:0]                                        o_data,
    output                                                  o_data_valid
);


assign  o_data = {weight_bram_1, weight_bram_2, weight_bram_3, weight_bram_4};
wire    [511:0]                             weight_bram_1;
wire    [511:0]                             weight_bram_2;
wire    [511:0]                             weight_bram_3;
wire    [511:0]                             weight_bram_4;



reg                                         wea_bram_1;
reg                                         wea_bram_2;
reg                                         wea_bram_3;
reg                                         wea_bram_4;





Weight_chunk_1 chunk_1 (
    .clka                                   (clk),
    .addra                                  (raddr),
    .wea                                    (1'b0),
    .dina                                   (512'b0),
    .douta                                  (weight_bram_1)
);



Weight_chunk_2 chunk_2 (
    .clka                                   (clk),
    .addra                                  (raddr),
    .wea                                    (1'b0),
    .dina                                   (512'b0),
    .douta                                  (weight_bram_2)
);



Weight_chunk_3 chunk_3 (
    .clka                                   (clk),
    .addra                                  (raddr),
    .wea                                    (1'b0),
    .dina                                   (512'b0),
    .douta                                  (weight_bram_3)
);



Weight_chunk_4 chunk_4 (
    .clka                                   (clk),
    .addra                                  (raddr),
    .wea                                    (1'b0),
    .dina                                   (512'b0),
    .douta                                  (weight_bram_4)
);

endmodule