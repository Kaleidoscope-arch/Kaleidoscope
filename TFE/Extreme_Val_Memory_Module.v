/*  
    This module is extreme value memory module, which 
    stores history max/min feature of a flow.

*/

module Main_Feature_Cache_Module (
    input   wire                                clk,
    input   wire                                rst_n,
    
    input   wire                                rd_mem,
    input   wire    [11:0]                      rd_addr,

    input   wire    [11:0]                      wr_addr,
    input   wire    [191:0]                     wr_data,
    input   wire                                wea,
    
    output  wire    [7:0]                       o_max_pkt_size,
    output  wire    [7:0]                       o_min_pkt_size,
    output  wire    [7:0]                       o_max_pkt_arit,
    output  wire    [7:0]                       o_min_pkt_arit,
    output  wire    [159:0]                     o_vec_feature,
    output  wire                                rd_data_v

);


reg     [2:0]                               rd_state;
wire    [191:0]                             rd_data;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_state                            <=          3'd0;
    end
    else begin
        rd_state                            <=          {rd_state[1:0], 1'b0} + rd_mem;
    end
end

Extreme_Val_Memory main_feature_cache(
    // rd port
    .addrb                          (rd_addr),
    .clkb                           (clk),
    .doutb                          (rd_data),
    
    // wr port
    .addra                          (wr_addr),
    .clka                           (clk),
    .dina                           (wr_data),
    // .ena                            (1'd1),
    .wea                            (wea)
);


reg     [191:0]                             rd_data_r0;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data_r0                          <=          192'd0;
    end
    else begin
        rd_data_r0                          <=          rd_data;
    end
end

assign  rd_data_v                           =           rd_state[1];
assign  o_max_pkt_size                      =           rd_data_r0[31:24];
assign  o_min_pkt_size                      =           rd_data_r0[23:16];
assign  o_max_pkt_arit                      =           rd_data_r0[15:8];
assign  o_min_pkt_arit                      =           rd_data_r0[7:0];
assign  o_vec_feature                       =           rd_data_r0[191:32];

// Extreme_Val_Memory main_feature_cache(
//     // ports bonded with TFE
//     .addra                          (wr_addr),
//     .clka                           (clk),
//     .dina                           (wr_data),
//     .ena                            (1'd1),
//     .wea                            (wea)
// );

endmodule