/* 

This file is the basic PE in VPE, which contains eight mult 
alu and an adder tree, conducting a 8element-8element vector
dot computation.

*/

module Dot_PE (
    input                                                   clk,
    input                                                   rst,
    input   [63:0]                                          i_data,
    input                                                   i_data_v,
    input   [63:0]                                          i_weight,
    output  [7:0]                                           o_data,
    output                                                  o_data_v
);


reg     [63:0]                                              i_weight_reg;
always @ (posedge clk) begin
    i_weight_reg                                    <=      i_weight;
end



wire    [8*16-1:0]                                          mult_res_w;
genvar i;
generate
    for (i=0; i<8; i=i+1) begin: mult_alu_loop
        mult_8bx8b mult_alu(
            .CLK                                            (clk),
            .A                                              (i_data[i*8+7:i*8]),
            .B                                              (i_weight_reg[i*8+7:i*8]),
            .P                                              (mult_res_w[i*16+15:i*16])
        );
    end
endgenerate



reg     [63:0]                                              mult_res_r;
reg                                                         i_data_v_r0;
reg                                                         mult_res_v;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        i_data_v_r0                                 <=      1'b0;
        mult_res_v                                  <=      1'b0;
    end
    else begin
        i_data_v_r0                                 <=      i_data_v;
        mult_res_v                                  <=      i_data_v_r0;
    end
end



// wire    [7:0]                                       dtf_0;
// wire    [7:0]                                       dtf_1;
// wire    [7:0]                                       dtf_2;
// wire    [7:0]                                       dtf_3;
// wire    [7:0]                                       dtf_4;
// wire    [7:0]                                       dtf_5;
// wire    [7:0]                                       dtf_6;
// wire    [7:0]                                       dtf_7;
// assign  dtf_0                               =       mult_res_r[7:0];
// assign  dtf_1                               =       mult_res_r[15:8];
// assign  dtf_2                               =       mult_res_r[23:16];
// assign  dtf_3                               =       mult_res_r[31:24];
// assign  dtf_4                               =       mult_res_r[39:32];
// assign  dtf_5                               =       mult_res_r[47:40];
// assign  dtf_6                               =       mult_res_r[55:48];
// assign  dtf_7                               =       mult_res_r[63:56];


generate
    for (i=0; i<8; i=i+1) begin: mult_res_loop
        always @ (posedge clk or posedge rst) begin
            if(rst) begin
                mult_res_r[i*8+7:i*8]               <=      8'b0;
            end
            else begin
                if(i_data_v_r0) begin
                    // overflow
                    if (mult_res_w[i*16+12] == mult_res_w[i*16+13]) begin
                        mult_res_r[i*8+7:i*8]       <=      mult_res_w[i*16+12:i*16+5];
                    end
                    else if (mult_res_w[i*16+12] == 1'b0) begin
                        mult_res_r[i*8+7:i*8]       <=      8'b0111_1111;
                    end
                    else begin
                        mult_res_r[i*8+7:i*8]       <=      8'b1000_0000;
                    end
                end
            end
        end
    end
endgenerate


wire    [31:0]                                              tree_level0_res_w;
reg     [31:0]                                              tree_level0_res;
reg                                                         tree_level0_res_v;
generate
    for (i=0; i<4; i=i+1) begin: tree_level0_loop
        vpe_adder_8b tree_level0 (
            .A                                              (mult_res_r[i*16+7:i*16]),
            .B                                              (mult_res_r[i*16+15:i*16+8]),
            .S                                              (tree_level0_res_w[i*8+7:i*8])
        );
    end
endgenerate

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        // tree_level0_res                             <=      32'b0;
        tree_level0_res_v                           <=      1'b0;
    end
    else begin
        // tree_level0_res                             <=      tree_level0_res_w;
        tree_level0_res_v                           <=      mult_res_v;
    end
end




generate
    for (i=0; i<4; i=i+1) begin: overflow_level0
        always @ (posedge clk) begin
            if(mult_res_r[i*16+7] == 1'b1 && mult_res_r[i*16+15] == 1'b1 && tree_level0_res_w[8*i+7] == 1'b0) begin
                tree_level0_res[8*i+7:8*i]           <=      8'b1000_0001;
            end
            else if (mult_res_r[i*16+7] == 1'b0 && mult_res_r[i*16+15] == 1'b0 && tree_level0_res_w[8*i+7] == 1'b1) begin
                tree_level0_res[8*i+7:8*i]           <=      8'b0111_1111;
            end
            else begin
                tree_level0_res[8*i+7:8*i]           <=      tree_level0_res_w[8*i+7:8*i];
            end
        end
    end
endgenerate











wire    [15:0]                                              tree_level1_res_w;
reg     [15:0]                                              tree_level1_res;
reg                                                         tree_level1_res_v;
generate
    for (i=0; i<2; i=i+1) begin: tree_level1_loop
        vpe_adder_8b tree_level1(
            .A                                              (tree_level0_res[i*16+7:i*16]),
            .B                                              (tree_level0_res[i*16+15:i*16+8]),
            .S                                              (tree_level1_res_w[i*8+7:i*8])
        );
    end
endgenerate

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        // tree_level1_res                             <=      32'b0;
        tree_level1_res_v                           <=      1'b0;
    end
    else begin
        // tree_level1_res                             <=      tree_level1_res_w;
        tree_level1_res_v                           <=      tree_level0_res_v;
    end
end


generate
    for (i=0; i<2; i=i+1) begin: overflow_level1
        always @ (posedge clk) begin
            if(tree_level0_res[i*16+7] == 1'b1 && tree_level0_res[i*16+15] == 1'b1 && tree_level1_res_w[8*i+7] == 1'b0) begin
                tree_level1_res[8*i+7:8*i]           <=      8'b1000_0001;
            end
            else if (tree_level0_res[i*16+7] == 1'b0 && tree_level0_res[i*16+15] == 1'b0 && tree_level1_res_w[8*i+7] == 1'b1) begin
                tree_level1_res[8*i+7:8*i]           <=      8'b0111_1111;
            end
            else begin
                tree_level1_res[8*i+7:8*i]           <=      tree_level1_res_w[8*i+7:8*i];
            end
        end
    end
endgenerate














wire    [7:0]                                               tree_level2_res_w;
reg     [7:0]                                               tree_level2_res;
reg                                                         tree_level2_res_v;
generate
    for (i=0; i<1; i=i+1) begin: tree_level2_loop
        vpe_adder_8b tree_level2(
            .A                                              (tree_level1_res[i*16+7:i*16]),
            .B                                              (tree_level1_res[i*16+15:i*16+8]),
            .S                                              (tree_level2_res_w[i*8+7:i*8])
        );
    end
endgenerate

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        // tree_level2_res                             <=      32'b0;
        tree_level2_res_v                           <=      1'b0;
    end
    else begin
        // tree_level2_res                             <=      tree_level2_res_w;
        tree_level2_res_v                           <=      tree_level1_res_v;
    end
end



generate
    for (i=0; i<1; i=i+1) begin: overflow_level2
        always @ (posedge clk) begin
            if(tree_level1_res[i*16+7] == 1'b1 && tree_level1_res[i*16+15] == 1'b1 && tree_level2_res_w[8*i+7] == 1'b0) begin
                tree_level2_res[8*i+7:8*i]           <=      8'b1000_0001;
            end
            else if (tree_level1_res[i*16+7] == 1'b0 && tree_level1_res[i*16+15] == 1'b0 && tree_level2_res_w[8*i+7] == 1'b1) begin
                tree_level2_res[8*i+7:8*i]           <=      8'b0111_1111;
            end
            else begin
                tree_level2_res[8*i+7:8*i]           <=      tree_level2_res_w[8*i+7:8*i];
            end
        end
    end
endgenerate










assign      o_data                                  =       tree_level2_res;
assign      o_data_v                                =       tree_level2_res_v;

endmodule