/*

    The tb top for hash TFE

*/


module judge_hash_tb();

reg                                     clk;
reg                                     rst;
reg     [20:0]                          cnter;

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
        cnter <= 21'd0;
    end
    else begin
        cnter <= cnter + 1'b1;
    end
end


reg     [15:0]                          hash;
reg                                     hash_valid;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        hash <= 16'd0;
        hash_valid <= 1'b0;        
    end
    else begin
        if(cnter >= 'd10 && cnter < 'd20) begin
            hash <= cnter;
            hash_valid <= 1'b1;
        end
        else if(cnter >= 'd40 && cnter < 'd50) begin
            hash <= cnter-'d40;
            hash_valid <= 1'b1;
        end
        else if(cnter >= 'd80 && cnter < 'd100) begin
            hash <= cnter-'d80;
            hash_valid <= 1'b1;
        end
        else if(cnter >= 'd100 && cnter < 'd120) begin
            hash <= cnter-'d80;
            hash_valid <= 1'b1;
        end
        else begin
            hash_valid <= 1'b0;
        end
    end
end


TFE_Hash_Judging tfe_hash_judge (
    .clk(clk),
    .rst(rst),
    .i_hash(hash),
    .i_hash_valid(hash_valid)
);



endmodule