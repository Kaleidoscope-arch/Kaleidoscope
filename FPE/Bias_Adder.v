/* 
Bias adder for VPE 2.1
conduct activation(1x8) + bias(1x8)
*/


module VPE_Bias_Adder (
    input                                                   clk,
    input                                                   rst,

    input   [63:0]                                          i_data,
    input                                                   i_data_v,
    input   [63:0]                                          i_bias,


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
wire    [63:0]                                              add_bias_res_w;
genvar i;
generate
    for (i=0; i<8; i=i+1) begin: level0_add0
        vpe_adder_8b vadder_a(
            .A                                              (i_data[i*8+7:i*8]),
            .B                                              (i_bias[i*8+7:i*8]),
            .S                                              (add_bias_res_w[i*8+7:i*8])
        );
    end
endgenerate



reg                                                         add_bias_res_v;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        add_bias_res_v                               <=      1'b0;
    end
    else begin
        add_bias_res_v                               <=      i_data_v;
    end
end


reg     [63:0]                                              o_data_reg;
reg                                                         o_data_v_reg;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_data_v_reg                                <=      1'b0;
    end
    else begin
        o_data_v_reg                                <=      i_data_v;
    end
end

// always @ (posedge clk or posedge rst) begin
//     if(i_en_relu) begin
//         o_data_reg                                  <=      add_bias_res_w;
//     end
//     else begin
//         o_data_reg                                  <=      i_data;
//     end
// end



generate
    for (i=0; i<8; i=i+1) begin: overflow_level0
        always @ (posedge clk) begin
            if(i_en_relu) begin
                if(i_data[i*8+7] == 1'b1 && i_bias[i*8+7] == 1'b1 && add_bias_res_w[8*i+7] == 1'b0) begin
                    o_data_reg[8*i+7:8*i]               <=      8'b1000_0001;
                end
                else if (i_data[i*8+7] == 1'b0 && i_bias[i*8+7] == 1'b0 && add_bias_res_w[8*i+7] == 1'b1) begin
                    o_data_reg[8*i+7:8*i]               <=      8'b0111_1111;
                end
                else begin
                    o_data_reg[8*i+7:8*i]               <=      add_bias_res_w[8*i+7:8*i];
                end
            end

            else begin
                o_data_reg[8*i+7:8*i]                   <=      i_data[8*i+7:8*i];
            end
        end
    end
endgenerate














assign  o_data                                      =       o_data_reg;
assign  o_data_v                                    =       o_data_v_reg;





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



always @ (posedge clk or posedge rst) begin
    if(rst) begin
        o_en_relu                                   <=      1'b0;
    end
    else begin
        o_en_relu                                   <=      i_en_relu;
        o_rf_idx                                    <=      i_rf_idx;
        o_rf_mux                                    <=      i_rf_mux;
    end
end



endmodule