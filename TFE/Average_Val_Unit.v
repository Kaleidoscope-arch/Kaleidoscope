/* 
    This module is for calculate feature with averaging operations, 
    like packet-per-second, byte-per-second, average packet size a-
    nd average packet arit.

    A 8-bit unsigned integer divider is implement in this module.

*/


module Average_Val_Unit (
    input              clk,
    input              rst_n,

    input   wire  [7:0]       a,
    input   wire  [7:0]       b,
    input   wire              vld,


    output   wire [7:0]       quo,
    output   wire [7:0]       rem,
    output   wire             ack
);


divfunc_bak div(
    .clk                            (clk),
    .rst_n                          (rst_n),
    .a                  (a),
    .b                  (b),
    .vld                (vld),
    .quo                (quo),
    .rem                (rem),
    .ack                (ack)
);



endmodule