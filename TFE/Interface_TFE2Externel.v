/*  
    This module is the interface between TFE and externel module, wh-
    can be RV CPU or DL engines. 

    The feature address of ready flow is collected in the fifo of this
    module, externel moduel fetch the addr.  This interface will send 
    fetched feature address to the inflight_fifo as well.
    
*/

module Interface_TFE2Ext (
    input   wire                                clk,
    input   wire                                rst_n,

    input   wire                                clk_ext,

    // input signal from TFE
    input   wire                                reach_thrh,
    input   wire    [11:0]                      i_fea_addr,

    // input signal from external module
    input   wire                                rd_fifo,

    // output signal to external module
    output  wire    [11:0]                      o_fea_addr,
    output  wire                                o_fea_addr_v,
    output  wire                                fifo_empty,

    // // output to tracker
    // output  wire    [11:0]                      free_addr,
    // output  wire                                free_addr_v,

    input   wire                                useless
);


assign          o_fea_addr_v                    =       o_fea_addr_v_r1;
assign          o_fea_addr                      =       o_fea_addr_r0;


// assign          free_addr                       =       o_fea_addr;
// assign          free_addr_v                     =       o_fea_addr_v_r1;


reg                                             o_fea_addr_v_r0;
reg                                             o_fea_addr_v_r1;
reg                                             o_fea_addr_v_r2;
reg                                             o_fea_addr_v_r3;
reg     [11:0]                                  o_fea_addr_r0;



wire    [11:0]                                  fea_addr_w;

Interface_Addr_FIFO_Independend_clk     fifo(
    .wr_clk                                     (clk),
    .rd_clk                                     (clk_ext),
    // .rst                                        (rst_n),
    .full                                       (),
    .din                                        (i_fea_addr),
    .wr_en                                      (reach_thrh),
    .empty                                      (fifo_empty),
    .dout                                       (fea_addr_w),
    .rd_en                                      (rd_fifo)
);


always @ (posedge clk_ext or negedge rst_n) begin
    if(~rst_n) begin
        o_fea_addr_v_r0                          <=          'd0;
        o_fea_addr_v_r1                          <=          'd0;
        o_fea_addr_v_r2                          <=          'd0;
        o_fea_addr_v_r3                          <=          'd0;
    end
    else begin
        o_fea_addr_v_r0                          <=          rd_fifo;
        o_fea_addr_v_r1                          <=          o_fea_addr_v_r0;
        o_fea_addr_v_r2                          <=          o_fea_addr_v_r1;
        o_fea_addr_v_r3                          <=          o_fea_addr_v_r2;
    end
end


always @ (posedge clk_ext or negedge rst_n) begin
    if(~rst_n) begin
        o_fea_addr_r0                            <=          12'd0;
    end
    else begin
        o_fea_addr_r0                            <=          fea_addr_w;
    end
end

endmodule