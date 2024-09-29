
module Octopus_Top (
    input                                               rst,
    input                                               clk,
    input                                               clk_octo,
    input                                               rst_octo,

    input   [103:0]                                     ip_tuple,
    input   [255:0]                                     i_raw_feature,
    input                                               ip_valid,

    output  [3:0]                                       inf_res,
    output                                              inf_res_valid,
    output  [15:0]                                      hash2table

);




wire                                                    vpe_data_valid;
wire                                                    ape_data_valid;
wire    [15:0]                                          hash;
wire                                                    hash_valid;
wire    [255:0]                                         feature;

TFE_top tfe_top(
    .clk                                                (clk),
    .rst                                                (rst),
    .ip_tuple                                           (ip_tuple),
    .i_raw_feature                                      (i_raw_feature),
    .ip_valid                                           (ip_valid),
    .first_pkt                                          (vpe_data_valid),
    .large_flow                                         (ape_data_valid),
    .o_hash                                             (hash),
    .o_hash_valid                                       (hash_valid),
    .o_feature                                          (feature)
);





//wire    [255:0]                                         feature2vpe_fifo;
//wire    [3:0]                                           feature2vpe_fifo_valid;
//FIFO_Mux feature_fifo_mux (
//    .clk                                                (clk),
//    .rst                                                (rst),
//    .i_feature                                          (feature),
//    .i_feature_valid                                    (vpe_data_valid),
//    .o_feature_fifo                                     (feature2vpe_fifo),
//    .o_feature_fifo_valid                               (feature2vpe_fifo_valid)
//);







reg                                                     vpe_fetch_250m_reg;
wire                                                    vpe_fetch_250m;
wire    [255:0]                                         feature2vpe;
wire    [7:0]                                           mux2vpe;

always @ (posedge clk_octo or posedge rst_octo) begin
    if(rst_octo) begin
        vpe_fetch_250m_reg                      <=      1'b0;
    end
    else begin
        vpe_fetch_250m_reg                      <=      vpe_fetch_250m;
    end
end

//genvar i;
//generate
//for(i=0; i<4; i=i+1) begin: fifo_vpe_mux_loop
    FIFO_VPE_Mux fifo_vpe_mux(
        .clk                                            (clk),
        .rst                                            (rst),
        .clk_octo                                       (clk_octo),
        .rst_octo                                       (rst_octo),
        .i_feature                                      (feature),
        .i_feature_valid                                (hash_valid),
        .fetch                                          (vpe_fetch_250m_reg),
        .o_feature                                      (feature2vpe),
        .o_feature_mux_valid                            (mux2vpe)
    );
//end
//endgenerate














wire    [3:0]                                           inf_res_w;
wire                                                    inf_res_valid_w;

//generate
//for(i=0; i<4; i=i+1) begin: vpe_cluster_loop
    VPE_Cluster vpe_cluster(
        .clk                                            (clk_octo),
        .rst                                            (rst_octo),
        .fetch_pkt_feature                              (vpe_fetch_250m),
        .pkt_feature                                    (feature2vpe),
        .vpe_mux_valid                                  (mux2vpe),
        .inf_res                                        (inf_res_w),
        .inf_res_valid                                  (inf_res_valid_w)
    );
//end
//endgenerate


reg     [3:0]                                           inf_res_reg;
reg                                                     inf_res_valid_reg;

always @ (posedge clk_octo or posedge rst_octo) begin
    if(rst_octo) begin
        inf_res_reg                             <=      4'b0;
        inf_res_valid_reg                       <=      1'b0;        
    end
    else begin
//        case (inf_res_valid_w)
//        4'b0000: begin
//            inf_res_valid_reg                   <=      1'b0;
//        end

//        4'b0001: begin
//            inf_res_valid_reg                   <=      1'b1;
//            inf_res_reg                         <=      inf_res_w[0];
//        end

//        4'b0010: begin
//            inf_res_valid_reg                   <=      1'b1;
//            inf_res_reg                         <=      inf_res_w[1];
//        end

//        4'b0100: begin
//            inf_res_valid_reg                   <=      1'b1;
//            inf_res_reg                         <=      inf_res_w[2];
//        end

//        4'b1000: begin
//            inf_res_valid_reg                   <=      1'b1;
//            inf_res_reg                         <=      inf_res_w[3];
//        end

//        endcase
        inf_res_reg                             <=      inf_res_w;
        inf_res_valid_reg                       <=      inf_res_valid_w; 
    end
end





wire                                                    hash_fifo_empty;
wire    [15:0]                                          fifo_hash;
reg    [15:0]                                           fifo_hash_reg;
Hash_FIFO hash_fifo_inst(
    // write port
    .full                                               (),
    .din                                                (hash),
    .wr_en                                              (hash_valid),

    // read port
    .empty                                              (hash_fifo_empty),
    .dout                                               (fifo_hash),
    .rd_en                                              (inf_res_valid_reg),

    // general
    .wr_clk                                             (clk),
    .rd_clk                                             (clk_octo),
    .srst                                               (rst)
);


reg     [3:0]                                           inf_res_reg_r0;
reg     [3:0]                                           inf_res_reg_r1;
reg                                                     inf_res_valid_reg_r0;
reg                                                     inf_res_valid_reg_r1;


always @ (posedge clk_octo or posedge rst_octo) begin
    if(rst_octo) begin
        inf_res_reg_r0                          <=      4'b0;
        inf_res_reg_r1                          <=      4'b0;
        inf_res_valid_reg_r0                    <=      1'b0;
        inf_res_valid_reg_r1                    <=      1'b0;
        fifo_hash_reg                           <=      16'b0;
    end
    else begin
        inf_res_reg_r0                          <=      inf_res_reg;
        inf_res_reg_r1                          <=      inf_res_reg_r0;
        inf_res_valid_reg_r0                    <=      inf_res_valid_reg;
        inf_res_valid_reg_r1                    <=      inf_res_valid_reg_r0;
        fifo_hash_reg                           <=      fifo_hash;
    end
end


//assign  hash2table                              =       fifo_hash_reg;
//assign  inf_res                                 =       inf_res_reg_r1;
//assign  inf_res_valid                           =       inf_res_valid_reg_r1;


wire                                                    infer_res_fifo_empty;
reg                                                     infer_res_nonempty;
reg                                                     infer_res_valid;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        infer_res_nonempty                      <=      1'b0;
        infer_res_valid                         <=      1'b0;
    end
    else begin
        infer_res_nonempty                      <=      ~infer_res_fifo_empty;
        infer_res_valid                         <=      infer_res_nonempty;
    end
end

assign  inf_res_valid                           =       infer_res_valid;


Infer_Res_FIFO infer_res_fifo_inst(
    // write port
    .full                                               (),
    .din                                                ({fifo_hash_reg, inf_res_reg_r1}),
    .wr_en                                              (inf_res_valid_reg_r1),

    // read port
    .empty                                              (infer_res_fifo_empty),
    .dout                                               ({hash2table, inf_res}),
    .rd_en                                              (~infer_res_fifo_empty),

    // general
    .wr_clk                                             (clk_octo),
    .rd_clk                                             (clk),
    .srst                                               (rst)
);











ila_clk ila_octopus_clk (
	.clk(clk), // input wire clk
	.probe0(i_raw_feature), // 256b
	.probe1(ip_tuple), // 104b 
	.probe2(ip_valid), // 1b 
	.probe3(hash), // 16b 
	.probe4(hash_valid), // 1b 
	.probe5(feature), // 256b 
	.probe6(infer_res_fifo_empty), // 1b 
	.probe7(vpe_data_valid), // 1b
	.probe8(inf_res), // 4b
	.probe9(inf_res_valid), // 1b
	.probe10(hash2table) // 16b
);



//wire [255:0] ila_feature2vpe_0;
//wire [255:0] ila_feature2vpe_1;
//wire [255:0] ila_feature2vpe_2;
//wire [255:0] ila_feature2vpe_3;

//assign ila_feature2vpe_0 = feature2vpe[0];
//assign ila_feature2vpe_1 = feature2vpe[1];
//assign ila_feature2vpe_2 = feature2vpe[2];
//assign ila_feature2vpe_3 = feature2vpe[3];


ila_clk_octo ila_octopus_clk_octo (
	.clk(clk_octo), // input wire clk
	.probe0(feature2vpe), // 256b 
	// .probe1(), // 256b
	// .probe2(), // 256b
	// .probe3(), // 256b
	.probe1(vpe_fetch_250m), // 4b 
	.probe2(inf_res_reg_r1), // 4b
	.probe3(inf_res_valid_reg_r1), // 1b
	.probe4(fifo_hash_reg) // 16b
);


//ila_0 octopus_1 (
//	.clk(clk), // input wire clk
//	.probe0(clk_octo), // input wire [511:0]  probe0  
//	.probe1(fifo_hash_reg), // input wire [63:0]  probe1 
//	.probe2(inf_res_reg_r1), // input wire [0:0]  probe2 
//	.probe3(inf_res_valid_reg_r1), // input wire [0:0]  probe3 
//	.probe4(infer_res_fifo_empty), // input wire [0:0]  probe4 
//	.probe5(hash2table), // input wire [255:0]  probe5 
//	.probe6(inf_res), // input wire [511:0]  probe6 
//	.probe7(inf_res_valid), // input wire [63:0]  probe7 
//	.probe8(infer_res_nonempty), // input wire [0:0]  probe8 
//	.probe9(inf_res_valid_w), // input wire [0:0]  probe9 
//	.probe10(fifo_hash_reg), // input wire [0:0]  probe10 
//	.probe11(fifo_hash_reg) // input wire [255:0]  probe11
//);



endmodule