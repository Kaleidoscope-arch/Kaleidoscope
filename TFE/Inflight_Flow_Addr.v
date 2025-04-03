/*  

    This module stores the inflight flow feature address, which are 
    features fetched by RV core / DL engine, being processed and w-
    aiting for final results. When externel module release free sig-
    nal, it will control track to free the address.

*/


module Inflight_Flow_Addr (
    input   wire                                clk,
    input   wire                                rst_n,

    
    // input signal from external module
    input   wire                                clk_ext,
    input   wire                                free_one_addr,

    // input signal from interface
    input   wire                                reach_thrh,
    input   wire    [11:0]                      i_fea_addr,
    input   wire    [11:0]                      i_r_fea_addr,


    // output signal to external module
    output  wire    [11:0]                      free_fea_addr,
    output  wire    [11:0]                      free_r_fea_addr,
    output  wire                                free_fea_addr_v,

    // // output to tracker
    // output  wire    [11:0]                      free_addr,
    // output  wire                                free_addr_v,

    input   wire                                useless
);


assign          free_fea_addr                   =       fea_addr_r1;
assign          free_r_fea_addr                 =       fea_r_addr_r1;
assign          free_fea_addr_v                 =       free_fea_addr_v_r2;



wire    [11:0]                                  free_addr_w;
wire    [11:0]                                  free_r_addr_w;

Interface_Addr_FIFO_Independend_clk     fifo(
    .wr_clk                                     (clk),
    .rd_clk                                     (clk),
    // .rst                                        (rst_n),
    .din                                        (i_fea_addr),
    .wr_en                                      (reach_thrh),
    .dout                                       (free_addr_w),
    .rd_en                                      (free_one_addr)
);

Interface_Addr_FIFO_Independend_clk     r_fifo(
    .wr_clk                                     (clk),
    .rd_clk                                     (clk),
    // .rst                                        (rst_n),
    .din                                        (i_r_fea_addr),
    .wr_en                                      (reach_thrh),
    .dout                                       (free_r_addr_w),
    .rd_en                                      (free_one_addr)
);


reg                                             free_fea_addr_v_r0;
reg                                             free_fea_addr_v_r1;
reg                                             free_fea_addr_v_r2;
reg                                             free_fea_addr_v_r3;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        free_fea_addr_v_r0                          <=          'd0;
        free_fea_addr_v_r1                          <=          'd0;
        free_fea_addr_v_r2                          <=          'd0;
        free_fea_addr_v_r3                          <=          'd0;
    end
    else begin
        free_fea_addr_v_r0                          <=          free_one_addr;
        free_fea_addr_v_r1                          <=          free_fea_addr_v_r0;
        free_fea_addr_v_r2                          <=          free_fea_addr_v_r1;
        free_fea_addr_v_r3                          <=          free_fea_addr_v_r2;
    end
end



reg     [11:0]                                  fea_addr_r0;
reg     [11:0]                                  fea_addr_r1;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        fea_addr_r0                                 <=          12'd0;
        fea_addr_r1                                 <=          12'd0;
    end
    else begin
        fea_addr_r0                                 <=          free_addr_w;
        fea_addr_r1                                 <=          fea_addr_r0;
    end
end


reg     [11:0]                                  fea_r_addr_r0;
reg     [11:0]                                  fea_r_addr_r1;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        fea_r_addr_r0                                 <=          12'd0;
        fea_r_addr_r1                                 <=          12'd0;
    end
    else begin
        fea_r_addr_r0                                 <=          free_r_addr_w;
        fea_r_addr_r1                                 <=          fea_r_addr_r0;
    end
end



endmodule