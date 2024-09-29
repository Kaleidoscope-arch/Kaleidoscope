
module VPE_Cluster (
    input                                               rst,
    input                                               clk,

    // fetch pkt features ports
    output                                              fetch_pkt_feature,
    input   [255:0]                                     pkt_feature,
    input   [7:0]                                       vpe_mux_valid,

    output  [3:0]                                       inf_res,
    output                                              inf_res_valid
);



wire    [7:0]                                           fetch;
wire    [255:0]                                         vpe_raw_res     [7:0];
wire    [7:0]                                           vpe_raw_res_valid;
assign  fetch_pkt_feature                       =       fetch[0] | fetch[1] | fetch[2] | fetch[3] | fetch[4] | fetch[5] | fetch[6] | fetch[7];

genvar i;
generate
for (i=0; i<8; i=i+1) begin: vpe_kernel_top
    VPE_Kernel_Top vpe (
        .rst                                            (rst),
        .clk                                            (clk),
        .fetch_pkt_feature                              (fetch[i]),
        .pkt_feature                                    (pkt_feature),
        .pkt_feature_valid                              (vpe_mux_valid[i]),
        .o_data                                         (vpe_raw_res[i]),
        .o_data_valid                                   (vpe_raw_res_valid[i])
    );

end
endgenerate



reg     [71:0]                                          vpe_res2max;
reg                                                     vpe_res2max_valid;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        vpe_res2max                             <=      72'd0;
        vpe_res2max_valid                       <=      1'b0;
    end
    else begin
        case (vpe_raw_res_valid)
        8'b0000_0000: begin
            vpe_res2max_valid                   <=      1'b0;
        end

        8'b0000_0001: begin
            vpe_res2max_valid                   <=      1'b1;
            vpe_res2max                         <=      vpe_raw_res[0][127:56];
        end

        8'b0000_0010: begin
            vpe_res2max_valid                   <=      1'b1;
            vpe_res2max                         <=      vpe_raw_res[1][127:56];
        end

        8'b0000_0100: begin
            vpe_res2max_valid                   <=      1'b1;
            vpe_res2max                         <=      vpe_raw_res[2][127:56];
        end

        8'b0000_1000: begin
            vpe_res2max_valid                   <=      1'b1;
            vpe_res2max                         <=      vpe_raw_res[3][127:56];
        end

        8'b0001_0000: begin
            vpe_res2max_valid                   <=      1'b1;
            vpe_res2max                         <=      vpe_raw_res[4][127:56];
        end

        8'b0010_0000: begin
            vpe_res2max_valid                   <=      1'b1;
            vpe_res2max                         <=      vpe_raw_res[5][127:56];
        end

        8'b0100_0000: begin
            vpe_res2max_valid                   <=      1'b1;
            vpe_res2max                         <=      vpe_raw_res[6][127:56];
        end

        8'b1000_0000: begin
            vpe_res2max_valid                   <=      1'b1;
            vpe_res2max                         <=      vpe_raw_res[7][127:56];
        end

        endcase
    end
end


Max_Unit max_unit_inst(
    .rst                                            (rst),
    .clk                                            (clk),
    .i_data                                         (vpe_res2max),
    .i_data_valid                                   (vpe_res2max_valid),
    .inf_res                                        (inf_res),
    .inf_res_valid                                  (inf_res_valid)
);


endmodule