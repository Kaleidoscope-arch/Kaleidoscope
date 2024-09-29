/* 
Vector adder for VPE 2.0
Conduct a vector reduce operation, 
input: vec_a, vec_b, vec_c, vec_d
output: (vec_a+vec_b) + (vec_c+vec_d)
*/


module VPE_Vector_Adder_bak (
    input                                                   clk,
    input                                                   rst_n,

    input   [255:0]                                         i_data,
    input                                                   i_data_v,

    input                                                   en_vadd,
    input                                                   i_en_relu,
    input   [4:0]                                           i_rf_idx,
    input   [1:0]                                           i_rf_mux,
    
    output  [63:0]                                          o_data,
    output                                                  o_data_v,
    output  reg                                             o_en_relu,
    output  reg [4:0]                                       o_rf_idx,
    output  reg [1:0]                                       o_rf_mux
);


//  level 0 vector adder
wire    [63:0]                                              level0_vadd0_res_w;
wire    [63:0]                                              level0_vadd1_res_w;
genvar i;
generate
    for (i=0; i<8; i=i+1) begin: level0_add0
        vpe_adder_8b vadder_a(
            .A                                              (i_data[i*8+7:i*8]),
            .B                                              (i_data[i*8+7+64:i*8+64]),
            .S                                              (level0_vadd0_res_w[i*8+7:i*8])
        );
    end
endgenerate

generate
    for (i=0; i<8; i=i+1) begin: level0_add1
        vpe_adder_8b vadder_b(
            .A                                              (i_data[i*8+7+128:i*8+128]),
            .B                                              (i_data[i*8+7+192:i*8+192]),
            .S                                              (level0_vadd1_res_w[i*8+7:i*8])
        );
    end
endgenerate



//  reg results of level 0 vector adder
reg     [63:0]                                              level0_vadd0_res;
reg     [63:0]                                              level0_vadd1_res;
reg                                                         level0_res_v;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        level0_res_v                                <=      1'b0;
    end
    else begin
        level0_res_v                                <=      i_data_v;
    end
end

always @ (posedge clk or negedge rst_n) begin
    level0_vadd0_res                        <=      level0_vadd0_res_w;
    level0_vadd1_res                        <=      level0_vadd1_res_w;
end




// level 1 vector adder
wire    [63:0]                                              level1_vadd0_res_w;
reg     [63:0]                                              level1_vadd0_res;
reg                                                         level1_res_v;
generate
    for (i=0; i<8; i=i+1) begin: level1_add0
        vpe_adder_8b vadder_c(
            .A                                              (level0_vadd0_res[i*8+7:i*8]),
            .B                                              (level0_vadd1_res[i*8+7:i*8]),
            .S                                              (level1_vadd0_res_w[i*8+7:i*8])
        );
    end
endgenerate


// reg results of level 1 vector adder
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        level1_res_v                                <=      1'b0;
        o_en_relu                                   <=      1'b0;
    end
    else begin
        level1_res_v                                <=      level0_res_v;
        o_en_relu                                   <=      en_relu_r0;
        o_rf_idx                                    <=      rf_idx_r0;
        o_rf_mux                                    <=      rf_mux_r0;
    end
end

always @ (posedge clk or negedge rst_n) begin
    level1_vadd0_res                                <=      level1_vadd0_res_w;
end



assign  o_data                                      =       level1_vadd0_res;
assign  o_data_v                                    =       level1_res_v;





// pipeline cached
reg                                                         en_relu_r0;
reg                                                         en_relu_r1;
reg     [4:0]                                               rf_idx_r0;
reg     [4:0]                                               rf_idx_r1;
reg     [1:0]                                               rf_mux_r0;
reg     [1:0]                                               rf_mux_r1;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        en_relu_r0                                  <=      1'b0;
        en_relu_r1                                  <=      1'b0;
    end
    else begin
        en_relu_r0                                  <=      i_en_relu;
        en_relu_r1                                  <=      en_relu_r0;

        rf_idx_r0                                   <=      i_rf_idx;
        rf_idx_r1                                   <=      rf_idx_r0;

        rf_mux_r0                                   <=      i_rf_mux;
        rf_mux_r1                                   <=      rf_mux_r0;
    end
end


endmodule