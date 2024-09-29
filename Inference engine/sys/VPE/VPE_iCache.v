module VPE_iCache (
    input                                                   clk,
    input                                                   rst,


    // rd prots
    input                                                   i_rd_valid,
    input   [7:0]                                           i_rd_addr,
    output  [35:0]                                          o_inst
);




VPE_iCache_Distmem icache (
    .clk                                                    (clk),
    .we                                                     (1'b0),
    .a                                                      (i_rd_addr),
    .d                                                      (35'b0),
    .spo                                                    (o_inst)
);


endmodule