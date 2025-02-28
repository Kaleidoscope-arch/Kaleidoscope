/* 
Vector adder for VPE 2.0
Conduct a vector reduce operation, 
input: vec_a, vec_b, vec_c, vec_d
output: (vec_a+vec_b) + (vec_c+vec_d)
*/


module VPE_Vector_Adder (
    input                                                   clk,
    input                                                   rst,

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


// pipeline cached
reg                                                         en_relu_r0;
reg                                                         en_relu_r1;
reg     [4:0]                                               rf_idx_r0;
reg     [4:0]                                               rf_idx_r1;
reg     [1:0]                                               rf_mux_r0;
reg     [1:0]                                               rf_mux_r1;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
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
reg     [7:0]                                               level0_vadd0_res    [7:0];
reg     [7:0]                                               level0_vadd1_res    [7:0];
reg                                                         level0_res_v;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        level0_res_v                                <=      1'b0;
    end
    else begin
        level0_res_v                                <=      i_data_v;
    end
end




generate
    for (i=0; i<8; i=i+1) begin: overflow_level0_add0
        always @ (posedge clk) begin
            if(i_data[8*i+7] == 1'b1 && i_data[8*i+7+64] == 1'b1 && level0_vadd0_res_w[8*i+7] == 1'b0) begin
                level0_vadd0_res[i]                 <=      8'b1000_0001;
            end
            else if (i_data[8*i+7] == 1'b0 && i_data[8*i+7+64] == 1'b0 && level0_vadd0_res_w[8*i+7] == 1'b1) begin
                level0_vadd0_res[i]                 <=      8'b0111_1111;
            end
            else begin
                level0_vadd0_res[i]                 <=      level0_vadd0_res_w[8*i+7:8*i];
            end
        end
    end
endgenerate


generate
    for (i=0; i<8; i=i+1) begin: overflow_level0_add1
        always @ (posedge clk) begin
            if(i_data[8*i+7+128] == 1'b1 && i_data[8*i+7+64+128] == 1'b1 && level0_vadd1_res_w[8*i+7] == 1'b0) begin
                level0_vadd1_res[i]                 <=      8'b1000_0001;
            end
            else if (i_data[8*i+7+128] == 1'b0 && i_data[8*i+7+64+128] == 1'b0 && level0_vadd1_res_w[8*i+7] == 1'b1) begin
                level0_vadd1_res[i]                 <=      8'b0111_1111;
            end
            else begin
                level0_vadd1_res[i]                 <=      level0_vadd1_res_w[8*i+7:8*i];
            end
        end
    end
endgenerate






// level 1 vector adder
wire    [63:0]                                              level1_vadd0_res_w;
reg     [7:0]                                               level1_vadd0_res    [7:0];
reg                                                         level1_res_v;
generate
    for (i=0; i<8; i=i+1) begin: level1_add0
        vpe_adder_8b vadder_c(
            .A                                              (level0_vadd0_res[i]),
            .B                                              (level0_vadd1_res[i]),
            .S                                              (level1_vadd0_res_w[i*8+7:i*8])
        );
    end
endgenerate


// reg results of level 1 vector adder
always @ (posedge clk or posedge rst) begin
    if(rst) begin
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





generate
    for (i=0; i<8; i=i+1) begin: overflow_level1_add0
        always @ (posedge clk) begin
            if(level0_vadd0_res[i][7] == 1'b1 && level0_vadd1_res[i][7] == 1'b1 && level1_vadd0_res_w[8*i+7] == 1'b0) begin
                level1_vadd0_res[i]                 <=      8'b1000_0001;
            end
            else if (level0_vadd0_res[i][7] == 1'b0 && level0_vadd1_res[i][7] == 1'b0 && level1_vadd0_res_w[8*i+7] == 1'b1) begin
                level1_vadd0_res[i]                 <=      8'b0111_1111;
            end
            else begin
                level1_vadd0_res[i]                 <=      level1_vadd0_res_w[8*i+7:8*i];
            end
        end
    end
endgenerate



assign  o_data                                      =       {level1_vadd0_res[7], level1_vadd0_res[6], level1_vadd0_res[5],
                                                            level1_vadd0_res[4], level1_vadd0_res[3], level1_vadd0_res[2], 
                                                            level1_vadd0_res[1], level1_vadd0_res[0]};
assign  o_data_v                                    =       level1_res_v;







endmodule