module iCacheSimTop ();


reg                         clk;
reg                         rst_n;

always #2 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 1;
    #15;
    rst_n = 0;
    #15; 
    rst_n = 1;
end



reg [11:0]                  i_data;
reg                         wr_valid;
reg [7:0]                   wr_addr;
reg                         rd_valid;
reg [7:0]                   rd_addr;
reg [11:0]                  cnter;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cnter           <=  'd0;    
    end
    else begin
        cnter           <=  cnter + 1'b1;
    end
end


always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wr_valid           <=  'd0;    
        rd_valid           <=  'd0;    
    end
    else begin
        if (cnter >= 'd1 && cnter < 'd11) begin
            wr_valid    <=  1'b1;
            wr_addr     <=  cnter[7:0] - 1;
            i_data      <=  cnter;
        end
        else if (cnter >= 'd20 && cnter < 'd31) begin
            wr_valid    <=  1'b0;
            rd_valid    <=  1'b1;
            rd_addr     <=  cnter[7:0] - 'd20;
        end
        else begin
            rd_valid    <=  1'b0;
            wr_valid    <=  1'b0;
        end
    end
end





VPE_iCache vpe_icache (
    .clk                    (clk),
    .rst_n                  (rst_n),
    .i_data                 (i_data),
    .i_wr_valid             (wr_valid),
    .i_rd_valid             (rd_valid),
    .i_rd_addr              (rd_addr),
    .i_wr_addr              (wr_addr)
);


endmodule