/*

    The tb top for hash TFE

*/


module tfe_top_tb();

reg                                     clk;
reg                                     rst;
reg     [110:0]                         cnter;

always #2 clk = ~clk;

initial begin
    clk = 1'b0;
    rst = 1'b0;
    #20;
    rst = 1'b1;
    #20;
    rst = 1'b0;
end

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        cnter <= 111'd0;
    end
    else begin
        cnter <= cnter + 1'b1;
    end
end


reg     [103:0]                         ip;
reg                                     ip_valid;
reg     [255:0]                         raw_bytes;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        ip <= 104'd0;
        ip_valid <= 1'b0;
        raw_bytes <= 256'b0;
    end
    else begin
        if(cnter >= 'd10 && cnter < 'd20) begin
            ip <= cnter;
            ip_valid <= 1'b1;
            raw_bytes <= 256'b0000100000000000000000000000110000011110000001110000100000000000000010000000001000001011000110000000000000000000000000000000000000000000000000000000000000000000000110110001011100011000000010100000000000001000000100000001100000010000000110000000000000000000;
        end
        else if(cnter >= 'd40 && cnter < 'd50) begin
            ip <= cnter-'d40;
            ip_valid <= 1'b1;
            raw_bytes <= 256'b0;
        end
        else if(cnter >= 'd80 && cnter < 'd100) begin
            ip <= cnter-'d80;
            ip_valid <= 1'b1;
            raw_bytes <= 256'b0;
        end
        else if(cnter >= 'd100 && cnter < 'd120) begin
            ip <= cnter-'d80;
            ip_valid <= 1'b1;
            raw_bytes <= 256'b0;
        end
        else begin
            ip_valid <= 1'b0;
            raw_bytes <= 256'b0;
        end
    end
end


TFE_top tfe_top (
    .clk                        (clk),
    .rst                        (rst),
    .ip_tuple                   (ip),
    .ip_valid                   (ip_valid),
    .i_raw_feature              (raw_bytes)
);



endmodule