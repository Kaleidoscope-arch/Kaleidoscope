/* 

This file is the computing SIMD unit of VPE. It contains eight
SIMD lanes.

*/

module SIMD (
    input                                                   clk,
    input                                                   rst,

    input   [255:0]                                         i_data,
    input                                                   i_data_v,
    input   [2047:0]                                        i_weight,

    input                                                   en_simd,
    input                                                   i_en_vadd,
    input                                                   i_en_relu,
    input   [4:0]                                           i_rf_idx,
    input   [1:0]                                           i_rf_mux,

    output  [255:0]                                         o_data,
    output                                                  o_data_v,
    output  reg                                             o_en_vadd,
    output  reg                                             o_en_relu,
    output  reg [4:0]                                       o_rf_idx,
    output  reg [1:0]                                       o_rf_mux
);


wire    [3:0]                                               o_data_v_w;
wire    [255:0]                                             o_data_w;
reg                                                         o_data_v_r;
reg     [255:0]                                             o_data_r;

genvar i;
generate
    for (i=0; i<4; i=i+1) begin: Lane_loop
        SIMD_LANE simd_lane(
            .clk                                            (clk),
            .rst                                            (rst),
            .i_data                                         (i_data[i*64+63:i*64]),
            // .i_data_v                                       (i_data_v & en_simd),
            .i_data_v                                       (en_simd),
            .i_weight                                       (i_weight[i*512+511:i*512]),
            .o_data                                         (o_data_w[i*64+63:i*64]),
            .o_data_v                                       (o_data_v_w[i])
        );

    end
endgenerate

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_data_v_r                                  <=      1'b0;
        o_data_r                                    <=      256'b0;
        o_en_vadd                                   <=      1'b0;
        o_en_relu                                   <=      1'b0;
    end
    else begin
        if(o_data_v_w[0]) begin
            o_data_v_r                              <=      o_data_v_w[0];
            o_data_r                                <=      o_data_w;
            o_en_vadd                               <=      en_vadd_r4;
            o_en_relu                               <=      en_relu_r4;
            o_rf_idx                                <=      rf_idx_r4;
            o_rf_mux                                <=      rf_mux_r4;
        end
        else if (i_en_vadd & (~en_simd)) begin
            // bypass simd
            o_data_v_r                              <=      i_en_vadd;
            o_data_r                                <=      i_data;
            o_en_vadd                               <=      i_en_vadd;
            o_en_relu                               <=      i_en_relu;
            o_rf_idx                                <=      i_rf_idx;
            o_rf_mux                                <=      i_rf_mux;
        end
        else begin
            o_data_v_r                              <=      1'b0;
            o_data_r                                <=      i_data;
            o_en_vadd                               <=      1'b0;
            o_en_relu                               <=      1'b0;
        end
    end
end


assign  o_data                                      =       o_data_r;
assign  o_data_v                                    =       o_data_v_r;



// pipeline cached
reg                                                         en_vadd_r0;
reg                                                         en_vadd_r1;
reg                                                         en_vadd_r2;
reg                                                         en_vadd_r3;
reg                                                         en_vadd_r4;
reg                                                         en_vadd_r5;

reg                                                         en_relu_r0;
reg                                                         en_relu_r1;
reg                                                         en_relu_r2;
reg                                                         en_relu_r3;
reg                                                         en_relu_r4;
reg                                                         en_relu_r5;

reg     [4:0]                                               rf_idx_r0;
reg     [4:0]                                               rf_idx_r1;
reg     [4:0]                                               rf_idx_r2;
reg     [4:0]                                               rf_idx_r3;
reg     [4:0]                                               rf_idx_r4;
reg     [4:0]                                               rf_idx_r5;

reg     [1:0]                                               rf_mux_r0;
reg     [1:0]                                               rf_mux_r1;
reg     [1:0]                                               rf_mux_r2;
reg     [1:0]                                               rf_mux_r3;
reg     [1:0]                                               rf_mux_r4;
reg     [1:0]                                               rf_mux_r5;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        en_vadd_r0                                  <=      1'b0;
        en_vadd_r1                                  <=      1'b0;
        en_vadd_r2                                  <=      1'b0;
        en_vadd_r3                                  <=      1'b0;
        en_vadd_r4                                  <=      1'b0;
        en_vadd_r5                                  <=      1'b0;

        en_relu_r0                                  <=      1'b0;
        en_relu_r1                                  <=      1'b0;
        en_relu_r2                                  <=      1'b0;
        en_relu_r3                                  <=      1'b0;
        en_relu_r4                                  <=      1'b0;
        en_relu_r5                                  <=      1'b0;
    end
    else begin
        en_vadd_r0                                  <=      i_en_vadd;
        en_vadd_r1                                  <=      en_vadd_r0;
        en_vadd_r2                                  <=      en_vadd_r1;
        en_vadd_r3                                  <=      en_vadd_r2;
        en_vadd_r4                                  <=      en_vadd_r3;
        en_vadd_r5                                  <=      en_vadd_r4;

        en_relu_r0                                  <=      i_en_relu;
        en_relu_r1                                  <=      en_relu_r0;
        en_relu_r2                                  <=      en_relu_r1;
        en_relu_r3                                  <=      en_relu_r2;
        en_relu_r4                                  <=      en_relu_r3;
        en_relu_r5                                  <=      en_relu_r4;

        rf_idx_r0                                   <=      i_rf_idx;
        rf_idx_r1                                   <=      rf_idx_r0;
        rf_idx_r2                                   <=      rf_idx_r1;
        rf_idx_r3                                   <=      rf_idx_r2;
        rf_idx_r4                                   <=      rf_idx_r3;
        rf_idx_r5                                   <=      rf_idx_r4;

        rf_mux_r0                                   <=      i_rf_mux;
        rf_mux_r1                                   <=      rf_mux_r0;
        rf_mux_r2                                   <=      rf_mux_r1;
        rf_mux_r3                                   <=      rf_mux_r2;
        rf_mux_r4                                   <=      rf_mux_r3;
        rf_mux_r5                                   <=      rf_mux_r4;
    end
end

endmodule