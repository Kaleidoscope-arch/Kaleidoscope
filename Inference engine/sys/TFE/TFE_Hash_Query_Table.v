/*

    The interface of TFE hash query table

*/



module TFE_Hash_Query_Table (
    input                                               rst,
    input                                               clk,
    
    // read port
    input       [15:0]                                  raddr,
    input                                               read,
    output      [4:0]                                   pkt_cnt,
    output      [33:0]                                  last_time,
    output                                              word_valid,
    output                                              rdata_valid,

    // write port
    input       [15:0]                                  waddr,
    input                                               wea,
    input       [39:0]                                  wdata
);


wire        [39:0]                                      rdata;
assign      pkt_cnt                         =           rdata[39:35];
assign      last_time                       =           rdata[34:1];
assign      word_valid                      =           rdata[0];


reg                                                     rdata_valid_reg;
reg                                                     read_reg0;
reg                                                     read_reg1;
assign      rdata_valid                     =           rdata_valid_reg;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        rdata_valid_reg                     <=          1'b0;
        read_reg0                           <=          1'b0;
        read_reg1                           <=          1'b0;
    end
    else begin
        read_reg0                           <=          read;
        read_reg1                           <=          read_reg0;
        rdata_valid_reg                     <=          read_reg1;
    end
end

Hash_Table hash_query_block(
    // write port
    .addra                                              (waddr),
    .clka                                               (clk),
    .dina                                               (wdata),
    .wea                                                (wea),

    // read port
    .addrb                                              (raddr),
    .clkb                                               (clk),
    .doutb                                              (rdata),
    .enb                                                (read)
);





endmodule