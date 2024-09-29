/*

    The kernel module for hash judging

*/

module TFE_Hash_Judging (
    input                                               rst,
    input                                               clk,
    input   [15:0]                                      i_hash,
    input                                               i_hash_valid,
    
    output                                              first_pkt,
    output                                              large_flow,
    output  [15:0]                                      o_hash,
    output                                              o_hash_valid

);


parameter   PKT_THRH                        =           1;
parameter   ARIT_THRH                       =           1024*1024*1024*1;




// Timer
wire        [33:0]                                      i_time;
TFE_Timer tfe_timer(
    .rst                                                (rst),
    .clk                                                (clk),
    .o_time                                             (i_time)
);




reg     [15:0]                                            hash_reg0;
reg     [15:0]                                            hash_reg1;
reg     [15:0]                                            hash_reg2;
reg     [15:0]                                            hash_reg3;
reg                                                       hash_valid_reg0;
reg                                                       hash_valid_reg1;
reg                                                       hash_valid_reg2;
reg                                                       hash_valid_reg3;


always @ (posedge clk or posedge rst) begin
    if(rst) begin
        hash_reg0                               <=      16'd0;        
        hash_reg1                               <=      16'd0;        
        hash_reg2                               <=      16'd0;        
        hash_reg3                               <=      16'd0;        

        hash_valid_reg0                         <=      1'b0;        
        hash_valid_reg1                         <=      1'b0;        
        hash_valid_reg2                         <=      1'b0;        
        hash_valid_reg3                         <=      1'b0;        
    end
    else begin
        hash_reg0                               <=      i_hash;
        hash_reg1                               <=      hash_reg0;
        hash_reg2                               <=      hash_reg1;
        hash_reg3                               <=      hash_reg2;

        hash_valid_reg0                         <=      i_hash_valid;
        hash_valid_reg1                         <=      hash_valid_reg0;
        hash_valid_reg2                         <=      hash_valid_reg1;
        hash_valid_reg3                         <=      hash_valid_reg2;
    end
end





// write ram
reg                                                     wr_hash_table;
reg         [4:0]                                       wr_pkt_cnt;
reg                                                     wr_word_valid;
wire        [39:0]                                      wdata;
assign      wdata                               =       {wr_pkt_cnt, i_time, wr_word_valid};

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        wr_hash_table                           <=      1'b0;
    end
    else begin
        if(rdata_valid) begin
            wr_hash_table                       <=      1'b1;
        end
        else begin
            wr_hash_table                       <=      1'b0;
        end
    end
end

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        wr_word_valid                           <=      1'b0;
    end
    else begin
        if(rdata_valid) begin
            wr_word_valid                       <=      1'b1;
        end
    end
end

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        wr_pkt_cnt                              <=      5'd0;
    end
    else begin
//        if((i_time - rd_last_time > ARIT_THRH) && rdata_valid) begin
//            wr_pkt_cnt                          <=      5'd1;
//        end
//        else begin
//            if((rd_pkt_cnter == PKT_THRH) && rdata_valid) begin
//                wr_pkt_cnt                      <=      rd_pkt_cnter;
//            end
//            else if (rdata_valid) begin
//                wr_pkt_cnt                      <=      rd_pkt_cnter + 1'b1;
//            end
//        end
        
        
        
      
            if((rd_pkt_cnter == PKT_THRH) && rdata_valid) begin
                wr_pkt_cnt                      <=      rd_pkt_cnter;
            end
            else if (rdata_valid) begin
                wr_pkt_cnt                      <=      rd_pkt_cnter + 1'b1;
            end
       
    end
end






// read ram
wire        [4:0]                                       rd_pkt_cnter;
wire        [33:0]                                      rd_last_time;
wire                                                    rd_word_valid;
wire                                                    rdata_valid;

TFE_Hash_Query_Table tfe_hash_query_table(
    .rst                                                (rst),
    .clk                                                (clk),
    // read port
    .raddr                                              (i_hash),
    .read                                               (i_hash_valid),
    .pkt_cnt                                            (rd_pkt_cnter),
    .last_time                                          (rd_last_time),
    .word_valid                                         (rd_word_valid),
    .rdata_valid                                        (rdata_valid),

    // write port
    .waddr                                              (hash_reg3),
    .wea                                                (wr_hash_table),
    .wdata                                              (wdata)
);




assign      o_hash                              =       hash_reg2;
assign      o_hash_valid                        =       hash_valid_reg2;
assign      first_pkt                           =       first_pkt_reg;
assign      large_flow                          =       large_flow_reg;

// first pkt and large flow
reg                                                     first_pkt_reg;
reg                                                     large_flow_reg;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        first_pkt_reg                           <=      1'b0;
        large_flow_reg                          <=      1'b0;
    end
    else begin
        if(rd_pkt_cnter == PKT_THRH && rdata_valid) begin
            large_flow_reg                      <=      1'b1;
        end
        else begin
            large_flow_reg                      <=      1'b0;
        end

//        if((rd_word_valid == 1'b0 && rdata_valid) || (i_time - rd_last_time >= ARIT_THRH  && rdata_valid)) begin
//            first_pkt_reg                       <=      1'b1;
//        end
//        else begin
//            first_pkt_reg                       <=      1'b0;
//        end

        if(rd_word_valid == 1'b0 && rdata_valid) begin
            first_pkt_reg                       <=      1'b1;
        end
        else begin
            first_pkt_reg                       <=      1'b0;
        end
    end
end

endmodule