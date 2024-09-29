/* 

This file is the vetcor data regfile, which comprises 8x32B regs.

*/

module Vector_Regfile(
    input                                                   clk,
    input                                                   rst_n,

    input                                                   wr_rf,
    input   [2:0]                                           rf_sel,
    input   [255:0]                                         wrf_data,

    input   [255:0]                                         wrf0_data,
    input                                                   wrf0_data_v,

    input                                                   rd_rf,
    output  reg                                             rrf_data_v,
    output  [255:0]                                         rrf_data
);


reg     [255:0]                                             vector_reg      [31:0];

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        vector_reg[0]                               <=      'd0;
        vector_reg[1]                               <=      'd0;
        vector_reg[2]                               <=      'd0;
        vector_reg[3]                               <=      'd0;
        vector_reg[4]                               <=      'd0;
        vector_reg[5]                               <=      'd0;
        vector_reg[6]                               <=      'd0;
        vector_reg[7]                               <=      'd0;
    end
    else begin
        // a new traffic feature arrives
        if (wrf0_data_v) begin
            vector_reg[0]                           <=      wrf0_data;
        end
        else begin
            if(wr_rf) begin
                vector_reg[rf_sel]                  <=      wrf_data;
            end
        end
    end
end

assign      rrf_data                                =       vector_reg[rf_sel];

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rrf_data_v                                  <=      1'b0;
    end
    else begin
        rrf_data_v                                  <=      rd_rf;
    end
end

endmodule