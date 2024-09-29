module FIFO_VPE_Mux (
    input                                                   clk,
    input                                                   rst,
    input                                                   clk_octo,
    input                                                   rst_octo,

    // write port from fifo_mux
    input   [255:0]                                         i_feature,
    input                                                   i_feature_valid,

    // read port from vpe
    input                                                   fetch,
    output  reg     [255:0]                                 o_feature,
    output  reg     [7:0]                                   o_feature_mux_valid

);



wire    [255:0]                                         fifo_feature;
reg                                                     fifo_feature_valid;
reg                                                     fetch_r0;
wire                                                    fifo_empty;
always @ (posedge clk_octo or posedge rst_octo) begin
    if(rst_octo) begin
        fifo_feature_valid                      <=      1'b0;
        fetch_r0                                <=      1'b0;
    end
    else begin
        fifo_feature_valid                      <=      fetch_r0 && (~fifo_empty);
        fetch_r0                                <=      fetch;
    end
end

Feature_FIFO vpe_feature_fifo (
    // write port
    .full                                               (),
    .din                                                (i_feature),
    .wr_en                                              (i_feature_valid),

    // read port
    .empty                                              (fifo_empty),
    .dout                                               (fifo_feature),
    .rd_en                                              (fetch),

    // general
    .wr_clk                                             (clk),
    .rd_clk                                             (clk_octo),
    .srst                                               (rst)
);








always @ (posedge clk_octo or posedge rst_octo) begin
    if(rst_octo) begin
        o_feature                                   <=      256'd0;        
    end
    else begin
        o_feature                                   <=      fifo_feature;
    end
end


reg     [2:0]                                               vpe_ptr;
reg     [2:0]                                               vpe_ptr_r0;
reg     [2:0]                                               vpe_ptr_octo;
always @ (posedge clk_octo or posedge rst_octo) begin
    if(rst_octo) begin
        vpe_ptr                                     <=      3'b000;        
    end
    else begin
        vpe_ptr                                     <=      vpe_ptr + fifo_feature_valid;
    end
end

//always @ (posedge clk_octo or posedge rst_octo) begin
//    if(rst_octo) begin
//        vpe_ptr_octo                                <=      3'b000;
//        vpe_ptr_r0                                  <=      3'b000;        
//    end
//    else begin
//        vpe_ptr_r0                                  <=      vpe_ptr;
//        vpe_ptr_octo                                <=      vpe_ptr_r0;
//    end
//end


always @ (posedge clk_octo or posedge rst_octo) begin
    if(rst_octo) begin
        o_feature_mux_valid                         <=      8'b0;
    end
    else begin
        case(vpe_ptr)
        3'b000: begin
            if (fetch_r0 && (~fifo_empty))
                o_feature_mux_valid                 <=      8'b0000_0001;
            else
                o_feature_mux_valid                 <=      8'b0000_0000;
        end

        3'b001: begin
            if (fetch_r0 && (~fifo_empty))
                o_feature_mux_valid                 <=      8'b0000_0010;
            else
                o_feature_mux_valid                 <=      8'b0000_0000;
        end

        3'b010: begin
            if (fetch_r0 && (~fifo_empty))
                o_feature_mux_valid                 <=      8'b0000_0100;
            else
                o_feature_mux_valid                 <=      8'b0000_0000;
        end

        3'b011: begin
            if (fetch_r0 && (~fifo_empty))
                o_feature_mux_valid                 <=      8'b0000_1000;
            else
                o_feature_mux_valid                 <=      8'b0000_0000;
        end

        3'b100: begin
            if (fetch_r0 && (~fifo_empty))
                o_feature_mux_valid                 <=      8'b0001_0000;
            else
                o_feature_mux_valid                 <=      8'b0000_0000;
        end

        3'b101: begin
            if (fetch_r0 && (~fifo_empty))
                o_feature_mux_valid                 <=      8'b0010_0000;
            else
                o_feature_mux_valid                 <=      8'b0000_0000;
        end

        3'b110: begin
            if (fetch_r0 && (~fifo_empty))
                o_feature_mux_valid                 <=      8'b0100_0000;
            else
                o_feature_mux_valid                 <=      8'b0000_0000;
        end

        3'b111: begin
            if (fetch_r0 && (~fifo_empty))
                o_feature_mux_valid                 <=      8'b1000_0000;
            else
                o_feature_mux_valid                 <=      8'b0000_0000;
        end
        endcase
    end
end


endmodule