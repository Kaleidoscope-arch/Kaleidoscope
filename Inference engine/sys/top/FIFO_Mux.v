module FIFO_Mux 
(
    input                                                   clk,
    input                                                   rst,

    input   [255:0]                                         i_feature,
    input                                                   i_feature_valid,

    output  reg  [255:0]                                    o_feature_fifo,
    output  reg  [3:0]                                      o_feature_fifo_valid
);

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_feature_fifo                              <=      256'd0;        
    end
    else begin
        o_feature_fifo                              <=      i_feature;
    end
end



reg     [1:0]                                               fifo_ptr;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        fifo_ptr                                    <=      2'b00;        
    end
    else begin
        fifo_ptr                                    <=      fifo_ptr + i_feature_valid;
    end
end


always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_feature_fifo_valid[0]                     <=      1'b0;        
        o_feature_fifo_valid[1]                     <=      1'b0;        
        o_feature_fifo_valid[2]                     <=      1'b0;        
        o_feature_fifo_valid[3]                     <=      1'b0;        
    end
    else begin
        case (fifo_ptr)
        2'b00: begin
            o_feature_fifo_valid[0]                 <=      i_feature_valid;
            o_feature_fifo_valid[1]                 <=      1'b0;
            o_feature_fifo_valid[2]                 <=      1'b0;
            o_feature_fifo_valid[3]                 <=      1'b0;
        end

        2'b01: begin
            o_feature_fifo_valid[0]                 <=      1'b0;
            o_feature_fifo_valid[1]                 <=      i_feature_valid;
            o_feature_fifo_valid[2]                 <=      1'b0;
            o_feature_fifo_valid[3]                 <=      1'b0;
        end

        2'b10: begin
            o_feature_fifo_valid[0]                 <=      1'b0;
            o_feature_fifo_valid[1]                 <=      1'b0;
            o_feature_fifo_valid[2]                 <=      i_feature_valid;
            o_feature_fifo_valid[3]                 <=      1'b0;
        end

        2'b11: begin
            o_feature_fifo_valid[0]                 <=      1'b0;
            o_feature_fifo_valid[1]                 <=      1'b0;
            o_feature_fifo_valid[2]                 <=      1'b0;
            o_feature_fifo_valid[3]                 <=      i_feature_valid;
        end

        endcase
    end
end





endmodule