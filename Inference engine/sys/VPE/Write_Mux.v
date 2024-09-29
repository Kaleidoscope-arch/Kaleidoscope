module Write_Mux (
    input                                                   clk,
    input                                                   rst,

    input   [63:0]                                          i_data,
    input                                                   i_data_v,
    input   [4:0]                                           i_rf_idx,
    input   [1:0]                                           i_rf_mux,
    output                                                  pre_fetch,
    output  [4:0]                                           pre_fetch_idx,
    input   [255:0]                                         pre_fetch_data,

    output  [255:0]                                         o_data,
    output                                                  o_data_v,
    output  [4:0]                                           o_rf_idx
);

assign  pre_fetch                                   =       i_data_v;
assign  pre_fetch_idx                               =       i_rf_idx;


reg     [63:0]                                              pre_reg [3:0];
assign  o_data_v                                    =       i_data_v;
assign  o_rf_idx                                    =       i_rf_idx;

always @ (*) begin
    case (i_rf_mux)
    2'b00: begin
        pre_reg[0]                                  =       i_data;
        pre_reg[1]                                  =       pre_fetch_data[127:64];
        pre_reg[2]                                  =       pre_fetch_data[191:128];
        pre_reg[3]                                  =       pre_fetch_data[255:192];
    end
    2'b01: begin
        pre_reg[0]                                  =       pre_fetch_data[63:0];
        pre_reg[1]                                  =       i_data;
        pre_reg[2]                                  =       pre_fetch_data[191:128];
        pre_reg[3]                                  =       pre_fetch_data[255:192];
    end
    2'b10: begin
        pre_reg[0]                                  =       pre_fetch_data[63:0];
        pre_reg[1]                                  =       pre_fetch_data[127:64];
        pre_reg[2]                                  =       i_data;
        pre_reg[3]                                  =       pre_fetch_data[255:192];
    end
    2'b11: begin
        pre_reg[0]                                  =       pre_fetch_data[63:0];
        pre_reg[1]                                  =       pre_fetch_data[127:64];
        pre_reg[2]                                  =       pre_fetch_data[191:128];
        pre_reg[3]                                  =       i_data;
    end
    endcase
end

assign o_data = {pre_reg[3], pre_reg[2], pre_reg[1], pre_reg[0]};


endmodule

