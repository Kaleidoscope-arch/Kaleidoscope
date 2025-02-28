/* 

This file is the data fetcher of traffic feature, it receives feature address from TFE and 
access data in main feature memory at these addresses.

*/


module VPE_TF_Fetcher(
    input                                                   clk,
    input                                                   rst_n,

    // TFE clk domain
    input                                                   rdy_for_fetch,
    input       [11:0]                                      i_fea_addr,
    input                                                   i_fea_addr_v,

    // computing done signal
    input                                                   inf_res_v,
    
    // output ports to TFE
    output  reg                                             rd_fifo_en,

    // output ports to main feature memory
    output  reg       [11:0]                                o_fea_addr,
    output  reg                                             rd_fea_en,

    // output ports to ctrler
    output  reg                                             fetch_rdy
);

parameter           IDLE                                    =       0;
parameter           FETCHING                                =       1;
parameter           WAITING                                 =       2;

reg     [1:0]                                               state;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state                                               <=      IDLE;
    end
    else begin
        case (state)
        IDLE: begin
            if (rdy_for_fetch) begin
                state                                       <=      FETCHING;
            end
            else begin
                state                                       <=      IDLE;
            end
        end
        FETCHING: begin
            state                                           <=      WAITING;
        end
        WAITING: begin
            if (inf_res_v) begin
                state                                       <=      IDLE;
            end
            else begin
                state                                       <=      WAITING;
            end
        end
        endcase
    end
end



always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_fifo_en                                          <=      'd0;
    end
    else begin
        if(state == FETCHING) begin
            rd_fifo_en                                      <=      'd1;
        end
        else begin
            rd_fifo_en                                      <=      'd0;
        end
    end
end

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        o_fea_addr                                          <=      12'd0;
        rd_fea_en                                           <=      'd0;
    end
    else begin
        o_fea_addr                                          <=      i_fea_addr;
        rd_fea_en                                           <=      i_fea_addr_v;
    end
end


endmodule