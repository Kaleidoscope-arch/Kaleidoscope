/*

    A timer for 64 seconds

*/


module TFE_Timer(
    input                                               rst,
    input                                               clk,
    output      [33:0]                                  o_time
);



reg             [33:0]                                  time_reg;
wire            [33:0]                                  time_wire;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        time_reg                            <=          33'd0;        
    end
    else begin
        time_reg                            <=          time_wire;
    end
end


assign          o_time                       =           time_reg;


Time_Cnter time_cnter_inst(
    .A(time_reg),
    .CLK(clk),
    .CE(1'b1),
    .S(time_wire)
);





endmodule