/*  
    This module is the sub-alu for generating max and min value.
    
*/

module Max_Min_Alu(
    input   wire                                clk,
    input   wire                                rst_n,

    input   wire    [7:0]                       hist_data,
    input   wire                                hist_data_v,
    input   wire    [7:0]                       cur_data,
    input   wire                                cur_data_v,

    input   wire                                func, // 0 is min, 1 is max

    output  wire    [7:0]                       o_extreme_data,
    output  wire                                o_extreme_data_v
);

reg     [7:0]                                   extreme_data;
reg                                             extreme_data_v;

assign      o_extreme_data                  =       extreme_data;
assign      o_extreme_data_v                =       extreme_data_v;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        extreme_data                        <=      8'd0;
        extreme_data_v                      <=      1'd0;
    end
    else begin
        if (cur_data_v) begin
            extreme_data_v                  <=      1'd1;
            if(hist_data_v) begin
                // needing min data
                if (func == 'd0) begin
                    if(cur_data < hist_data || hist_data == 'd0) begin
                        extreme_data        <=      cur_data;
                    end
                    else begin
                        extreme_data        <=      hist_data;
                    end
                end
                // needing max data
                else begin
                    if(cur_data > hist_data) begin
                        extreme_data        <=      cur_data;
                    end
                    else begin
                        extreme_data        <=      hist_data;
                    end
                end
            end
            else begin
                extreme_data                <=      cur_data;
            end
        end
        else begin
            extreme_data                    <=      8'd0;
            extreme_data_v                  <=      1'd0;
        end
    end
end



endmodule