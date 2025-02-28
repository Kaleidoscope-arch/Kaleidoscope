module VPE_Kernel_Top (
    input                                                   clk,
    input                                                   rst,

    // fetch pkt features ports
    output                                                  fetch_pkt_feature,
    input                                                   pkt_feature_valid,
    input   [255:0]                                         pkt_feature,

    // output inf results
    output  reg [255:0]                                     o_data,
    output  reg                                             o_data_valid
);



wire    [35:0]                                              vpe_inst;
wire    [7:0]                                               rd_inst_addr;
wire                                                        rd_inst_valid;
VPE_iCache vpe_icache (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .i_rd_valid                                             (rd_inst_valid),
    .i_rd_addr                                              (rd_inst_addr),
    .o_inst                                                 (vpe_inst)
);


wire                                                        ldr;
wire                                                        ldw;
wire                                                        ldb;
wire                                                        wr_reg;
wire                                                        en_relu;
wire                                                        en_simd;
wire                                                        en_vadd;
wire                                                        out_valid;
wire    [4:0]                                               ldr_idx;
wire    [4:0]                                               wr_reg_idx;
wire    [7:0]                                               ldw_addr;
wire    [7:0]                                               ldb_addr;
wire    [1:0]                                               wr_reg_mux;
// wire                                                        fin;
VPECtrler_ vpe_ctrler (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .i_inst                                                 (vpe_inst),
    .rd_inst_idx                                            (rd_inst_addr),
    .rd_inst_valid                                          (rd_inst_valid),
    .fetch_pkt_fea                                          (fetch_pkt_feature),
    .pkt_fea_valid                                          (pkt_feature_valid),
    .ldr                                                    (ldr),
    .ldr_idx                                                (ldr_idx),
    .ldw                                                    (ldw),
    .ldw_addr                                               (ldw_addr),
    .ldb                                                    (ldb),
    .ldb_addr                                               (ldb_addr),
    .wr_reg                                                 (wr_reg),
    .wr_reg_idx                                             (wr_reg_idx),
    .wr_reg_mux                                             (wr_reg_mux),
    .en_relu                                                (en_relu),
    .en_simd                                                (en_simd),
    .en_vadd                                                (en_vadd),
    .out_valid                                              (out_valid)
    // .fin                                                    (fin)
);



wire    [255:0]                                             regfile_odata;
wire    [255:0]                                             wmux_odata;
wire                                                        wmux_odata_valid;
wire    [4:0]                                               wmux_rf_idx;
wire    [4:0]                                               wmux_pre_fetch_idx;
wire                                                        wmux_pre_fetch;
reg                                                         rd_regfile;
reg     [4:0]                                               rd_regfile_idx;
always @ (*) begin
    rd_regfile                                      =        wmux_pre_fetch | ldr;
    
    if(ldr)
        rd_regfile_idx                              =       ldr_idx;
    else
        rd_regfile_idx                              =       wmux_pre_fetch_idx;
end


always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_data_valid                                <=      1'b0;
    end
    else begin
        o_data_valid                                <=      out_valid;
        o_data                                      <=      regfile_odata;
    end
end
// assign o_data_valid                                 =       out_valid;
// assign o_data                                       =       regfile_odata;


VPERegfile_scala vpe_regfile (
    .clk                                                    (clk),
    .reset                                                  (rst),
    .io_o_data                                              (regfile_odata),
    .io_rd_index                                            (rd_regfile_idx),
    .io_i_data                                              (wmux_odata),
    .io_wr_valid                                            (wmux_odata_valid),
    .io_wr_index                                            (wmux_rf_idx),
    .fin                                                    (fin)
);




reg     [255:0]                                             reg_group_idata;
reg                                                         reg_group_idata_valid;
wire    [255:0]                                             reg_group_odata;
wire                                                        reg_group_odata_valid;
wire    [4:0]                                               reg_group_rf_idx;
wire    [1:0]                                               reg_group_rf_mux;
always @ (*) begin
   if(pkt_feature_valid) begin
        reg_group_idata                             =       pkt_feature;
        reg_group_idata_valid                       =       pkt_feature_valid;
   end 
   else begin
        reg_group_idata                             =       regfile_odata;
        reg_group_idata_valid                       =       ldr;
   end
end

wire                                                        reg_group_en_simd;
wire                                                        reg_group_en_vadd;
wire                                                        reg_group_en_relu;
SIMD_in_Reg reg_group (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .i_data                                                 (reg_group_idata),
    .i_data_v                                               (reg_group_idata_valid),
    .o_data                                                 (reg_group_odata),
    .o_data_v                                               (reg_group_odata_valid),
    .i_rf_idx                                               (wr_reg_idx),
    .i_rf_mux                                               (wr_reg_mux),
    .i_en_simd                                              (en_simd),
    .i_en_vadd                                              (en_vadd),
    .i_en_relu                                              (en_relu),
    .o_en_simd                                              (reg_group_en_simd),
    .o_en_vadd                                              (reg_group_en_vadd),
    .o_en_relu                                              (reg_group_en_relu),
    .o_rf_idx                                               (reg_group_rf_idx),
    .o_rf_mux                                               (reg_group_rf_mux)
);




wire    [2047:0]                                            weight;
wire                                                        weight_valid;

VPE_Weights_ROM vpe_weights_rom (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .rd_valid                                               (ldw),
    .raddr                                                  (ldw_addr),
    .o_data                                                 (weight),
    .o_data_valid                                           (weight_valid)
);



wire    [63:0]                                              bias;
wire                                                        bias_valid;

VPE_Bias_ROM vpe_bias_rom (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .rd_valid                                               (ldb),
    .raddr                                                  (ldb_addr),
    .o_data                                                 (bias),
    .o_data_valid                                           (bias_valid)
);




wire    [255:0]                                             simd_odata;
wire                                                        simd_odata_valid;
wire                                                        simd_en_vadd;
wire                                                        simd_en_relu;
wire    [255:0]                                             simd_kpt_data;
wire    [4:0]                                               simd_rf_idx;
wire    [1:0]                                               simd_rf_mux;

SIMD simd (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .i_data                                                 (reg_group_odata),
    .i_data_v                                               (reg_group_odata_valid),
    .i_weight                                               (weight),
    .en_simd                                                (reg_group_en_simd),
    .i_en_vadd                                              (reg_group_en_vadd),
    .i_en_relu                                              (reg_group_en_relu),
    .o_data                                                 (simd_odata),
    .o_data_v                                               (simd_odata_valid),
    .o_en_vadd                                              (simd_en_vadd),
    .o_en_relu                                              (simd_en_relu),
    .i_rf_idx                                               (reg_group_rf_idx),
    .i_rf_mux                                               (reg_group_rf_mux),
    .o_rf_idx                                               (simd_rf_idx),
    .o_rf_mux                                               (simd_rf_mux)
);




wire    [63:0]                                              vadd_odata;
wire                                                        vadd_odata_valid;
wire                                                        vadd_en_relu;
wire    [4:0]                                               vadd_rf_idx;
wire    [1:0]                                               vadd_rf_mux;
VPE_Vector_Adder vec_adder (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .i_data                                                 (simd_odata),
    .i_data_v                                               (simd_odata_valid),
    .en_vadd                                                (simd_en_vadd),
    .i_en_relu                                              (simd_en_relu),
    .o_data                                                 (vadd_odata),
    .o_data_v                                               (vadd_odata_valid),
    .o_en_relu                                              (vadd_en_relu),
    .i_rf_idx                                               (simd_rf_idx),
    .i_rf_mux                                               (simd_rf_mux),
    .o_rf_idx                                               (vadd_rf_idx),
    .o_rf_mux                                               (vadd_rf_mux)
);





wire    [63:0]                                              bias_odata;
wire                                                        bias_odata_valid;
wire                                                        bias_en_relu;
wire    [4:0]                                               bias_rf_idx;
wire    [1:0]                                               bias_rf_mux;
VPE_Bias_Adder bias_adder(
    .clk                                                    (clk),
    .rst                                                    (rst),
    .i_data                                                 (vadd_odata),
    .i_data_v                                               (vadd_odata_valid),
    .i_bias                                                 (bias),
    .i_en_relu                                              (vadd_en_relu),
    .i_rf_idx                                               (vadd_rf_idx),
    .i_rf_mux                                               (vadd_rf_mux),
    .o_data                                                 (bias_odata),
    .o_data_v                                               (bias_odata_valid),
    .o_en_relu                                              (bias_en_relu),
    .o_rf_idx                                               (bias_rf_idx),
    .o_rf_mux                                               (bias_rf_mux)
);






wire    [63:0]                                              relu_odata;
wire                                                        relu_odata_valid;
wire    [4:0]                                               relu_rf_idx;
wire    [1:0]                                               relu_rf_mux;
VPE_ReLU vpe_relu (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .i_data                                                 (bias_odata),
    .i_data_v                                               (bias_odata_valid),
    .en_relu                                                (bias_en_relu),
    .o_data                                                 (relu_odata),
    .o_data_v                                               (relu_odata_valid),
    .i_rf_idx                                               (bias_rf_idx),
    .i_rf_mux                                               (bias_rf_mux),
    .o_rf_idx                                               (relu_rf_idx),
    .o_rf_mux                                               (relu_rf_mux)
);




Write_Mux wb_mux (
    .clk                                                    (clk),
    .rst                                                    (rst),
    .i_data                                                 (relu_odata),
    .i_data_v                                               (relu_odata_valid),
    .i_rf_idx                                               (relu_rf_idx),
    .i_rf_mux                                               (relu_rf_mux),
    .o_data                                                 (wmux_odata),
    .o_data_v                                               (wmux_odata_valid),
    .o_rf_idx                                               (wmux_rf_idx),
    .pre_fetch                                              (wmux_pre_fetch),
    .pre_fetch_idx                                          (wmux_pre_fetch_idx),
    .pre_fetch_data                                         (regfile_odata)
);





endmodule