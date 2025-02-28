/* 
This file is the top module of VPE ver 2.0.
*/

module VPE_top(
    input                                                   clk,
    input                                                   rst_n,

    // TFE signal
    input                                                   rdy_for_fetch,
    input       [11:0]                                      i_fea_addr,
    input                                                   i_fea_addr_v,
    // output ports to TFE
    output  wire                                            rd_fifo_vpe2tfe,

    // output ports to main feature memory
    output  wire        [11:0]                              o_fea_addr_vpe2mem,
    output  wire                                            rd_fea_en_vpe2mem,
    // input ports from main feature memory
    input       [255:0]                                     i_feature_mem2vpe,
    input                                                   i_feature_v_mem2vpe,

    // initial configure for loader
    input       [255:0]                                     i_ini_data,
    input                                                   i_ini_data_v,

    // configure for ctrler
    input       [10:0]                                      i_ctrl_runtime,
    input                                                   i_ctrl_start,


    // outputs to deparser
    output      [255:0]                                     o_inf_res,
    output                                                  o_inf_res_v
);


wire    [255:0]                                         inst_loader2ctrl;
wire                                                    inst_v_loader2ctrl;
wire    [255:0]                                         weight_loader2ROM;
wire                                                    weight_v_loader2ROM;
wire                                                    loading_weight_loader2ROM;
wire                                                    loading_weight_done_loader2ROM;

(* dont_touch = "YES" *) VPE_Params_Loader vpe_params_loader(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .i_data                                 (i_ini_data),
    .i_data_v                               (i_ini_data_v),
    .inst_len                               ('d511),
    .weights_len                            ('d4095),
    .o_inst                                 (inst_loader2ctrl),
    .o_inst_v                               (inst_v_loader2ctrl),
    .o_weight                               (weight_loader2ROM),
    .o_weight_v                             (weight_v_loader2ROM),
    .loading_weight                         (loading_weight_loader2ROM),
    .loading_weight_done                    (loading_weight_done_loader2ROM)
);



wire                                        wr_rf_ctrl2vrf;
wire                                        rd_rf_ctrl2vrf;
wire    [2:0]                               rf_sel_ctrl2vrf;
wire    [1:0]                               mux0_ctrl2inreg;
wire    [1:0]                               mux1_ctrl2inreg;
wire    [1:0]                               mux2_ctrl2inreg;
wire    [1:0]                               mux3_ctrl2inreg;
wire                                        en_level0_vadd0;
wire                                        en_level0_vadd1;
wire                                        en_level1_vadd0;
wire    [1:0]                               muxa_level0_vadd0;
wire    [1:0]                               muxb_level0_vadd0;
wire    [1:0]                               muxa_level0_vadd1;
wire    [1:0]                               muxb_level0_vadd1;
wire                                        en_relu;
wire    [6:0]                               rd_weight_addr;
wire                                        out_mux;

(* dont_touch = "YES" *) VPE_Ctrl vpe_ctrl(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .i_inst                                 (inst_loader2ctrl),
    .i_inst_v                               (inst_v_loader2ctrl),
    .start                                  (i_ctrl_start),
    .fetch_rdy                              (i_feature_v_mem2vpe),
    .run_time                               (i_ctrl_runtime),
    .wr_rf                                  (wr_rf_ctrl2vrf),
    .rd_rf                                  (rd_rf_ctrl2vrf),
    .rf_sel                                 (rf_sel_ctrl2vrf),
    .in_mux0                                (mux0_ctrl2inreg),
    .in_mux1                                (mux1_ctrl2inreg),
    .in_mux2                                (mux2_ctrl2inreg),
    .in_mux3                                (mux3_ctrl2inreg),
    .rd_weight_addr                         (rd_weight_addr),
    .en_level0_vadd0                        (en_level0_vadd0),
    .en_level0_vadd1                        (en_level0_vadd1),
    .en_level1_vadd0                        (en_level1_vadd0),
    .muxa_level0_vadd0                      (muxa_level0_vadd0),
    .muxb_level0_vadd0                      (muxb_level0_vadd0),
    .muxa_level0_vadd1                      (muxa_level0_vadd1),
    .muxb_level0_vadd1                      (muxb_level0_vadd1),
    .en_relu                                (en_relu),
    .out_mux                                (out_mux)
);



(* dont_touch = "YES" *) VPE_TF_Fetcher vpe_tf_fetcher(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .rdy_for_fetch                          (rdy_for_fetch),
    .i_fea_addr                             (i_fea_addr),
    .i_fea_addr_v                           (i_fea_addr_v),
    .rd_fifo_en                             (rd_fifo_vpe2tfe),
    .o_fea_addr                             (o_fea_addr_vpe2mem),
    .rd_fea_en                              (rd_fea_en_vpe2mem),
    .inf_res_v                              (out_mux&relu_res_v)
);



wire    [255:0]                                             rrf_data_vrf2inreg;
wire                                                        rrf_data_v_vrf2inreg;
(* dont_touch = "YES" *) Vector_Regfile vrf(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .wr_rf                                  (wr_rf_ctrl2vrf),
    .rf_sel                                 (rf_sel_ctrl2vrf),
    .rd_rf                                  (rd_rf_ctrl2vrf),
    .rrf_data                               (rrf_data_vrf2inreg),
    .rrf_data_v                             (rrf_data_v_vrf2inreg),
    .wrf0_data                              (i_feature_mem2vpe),
    .wrf0_data_v                            (i_feature_v_mem2vpe)
);



wire    [255:0]                             data_inreg2simd;
wire                                        data_v_inreg2simd;

(* dont_touch = "YES" *) SIMD_in_Reg simd_in_reg(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .i_data                                 (rrf_data_vrf2inreg),
    .i_data_v                               (rrf_data_v_vrf2inreg),
    .mux0                                   (mux0_ctrl2inreg),
    .mux1                                   (mux1_ctrl2inreg),
    .mux2                                   (mux2_ctrl2inreg),
    .mux3                                   (mux3_ctrl2inreg),
    .o_data                                 (data_inreg2simd),
    .o_data_v                               (data_v_inreg2simd)
);


wire    [8191:0]                            weight2simd;
(* dont_touch = "YES" *) VPE_Weights_ROM vpe_weights_rom(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .ini_weight_data                        (weight_loader2ROM),
    .ini_weight_data_v                      (weight_v_loader2ROM),
    .rd_weight_addr                         (rd_weight_addr),
    .o_weight                               (weight2simd)
);



wire    [255:0]                             data_simd2vadd;
wire                                        data_v_simd2vadd;
(* dont_touch = "YES" *) SIMD simd(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .i_data                                 (data_inreg2simd),
    .i_data_v                               (data_v_inreg2simd),
    .i_weight                               (weight2simd),
    .o_data                                 (data_simd2vadd),
    .o_data_v                               (data_v_simd2vadd)
);


wire    [255:0]                             data_vadd2relu;
wire                                        data_v_vadd2relu;
(* dont_touch = "YES" *) VPE_Vector_Adder vpe_vector_adder(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .i_data                                 (data_simd2vadd),
    .i_data_v                               (data_v_simd2vadd),
    .en_level0_vadd0                        (en_level0_vadd0),
    .en_level0_vadd1                        (en_level0_vadd1),
    .en_level1_vadd0                        (en_level1_vadd0),
    .muxa_level0_vadd0                      (muxa_level0_vadd0),
    .muxb_level0_vadd0                      (muxb_level0_vadd0),
    .muxa_level0_vadd1                      (muxa_level0_vadd1),
    .muxb_level0_vadd1                      (muxb_level0_vadd1),
    .o_data                                 (data_vadd2relu),
    .o_data_v                               (data_v_vadd2relu)
);


wire    [255:0]                             relu_res;
wire                                        relu_res_v;
(* dont_touch = "YES" *) VPE_ReLU vpe_relu(
    .clk                                    (clk),
    .rst_n                                  (rst_n),
    .i_data                                 (data_vadd2relu),
    .i_data_v                               (data_v_vadd2relu),
    .en_relu                                (en_relu),
    .o_data                                 (relu_res),
    .o_data_v                               (relu_res_v)
);


reg     [255:0]                             o_inf_res_r;
reg                                         o_inf_res_v_r;
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        o_inf_res_r                 <=      256'b0;
        o_inf_res_v_r               <=      1'b0;
    end
    else begin
        o_inf_res_r                 <=      relu_res;
        o_inf_res_v_r               <=      relu_res_v & out_mux;
    end
end

assign  o_inf_res                   =       o_inf_res_r;
assign  o_inf_res_v                 =       o_inf_res_v_r;

endmodule