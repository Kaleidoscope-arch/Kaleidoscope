/* 
Bias adder for VPE 2.1
conduct activation(1x8) + bias(1x8)
*/


module VPE_Bias_Adder_overflow (
    input                                                   clk,
    input                                                   rst_n,

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

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        add_bias_res_v                               <=      1'b0;
    end
    else begin
        add_bias_res_v                               <=      i_data_v;
    end
end


reg     [7:0]                                               o_data_reg  [7:0];
reg                                                         o_data_v_reg;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        o_data_v_reg                                <=      1'b0;
    end
    else begin
        o_data_v_reg                                <=      i_data_v;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if(i_en_relu) begin
        // o_data_reg                                  <=      add_bias_res_w;
        // res_ele_0
        if((i_data[7] == i_bias[7]) && (i_data[7] == 1'b0) && (add_bias_res_w[7] == 1'b1)) begin
            o_data_reg[0]                           <=      8'b0111_1111;
        end
        else if ((i_data[7] == i_bias[7]) && (i_data[7] == 1'b1) && (add_bias_res_w[7] == 1'b0)) begin
            o_data_reg[0]                           <=      8'b1000_0001;
        end
        else begin
            o_data_reg[0]                           <=      add_bias_res_w[7:0];
        end

        // res_ele_1
        if((i_data[15] == i_bias[15]) && (i_data[15] == 1'b0) && (add_bias_res_w[15] == 1'b1)) begin
            o_data_reg[1]                           <=      8'b0111_1111;
        end
        else if ((i_data[15] == i_bias[15]) && (i_data[15] == 1'b1) && (add_bias_res_w[15] == 1'b0)) begin
            o_data_reg[1]                           <=      8'b1000_0001;
        end
        else begin
            o_data_reg[1]                           <=      add_bias_res_w[15:8];
        end

        // res_ele_2
        if((i_data[23] == i_bias[23]) && (i_data[23] == 1'b0) && (add_bias_res_w[23] == 1'b1)) begin
            o_data_reg[2]                           <=      8'b0111_1111;
        end
        else if ((i_data[23] == i_bias[23]) && (i_data[23] == 1'b1) && (add_bias_res_w[23] == 1'b0)) begin
            o_data_reg[2]                           <=      8'b1000_0001;
        end
        else begin
            o_data_reg[2]                           <=      add_bias_res_w[23:16];
        end

        // res_ele_3
        if((i_data[31] == i_bias[31]) && (i_data[31] == 1'b0) && (add_bias_res_w[31] == 1'b1)) begin
            o_data_reg[3]                           <=      8'b0111_1111;
        end
        else if ((i_data[31] == i_bias[31]) && (i_data[31] == 1'b1) && (add_bias_res_w[31] == 1'b0)) begin
            o_data_reg[3]                           <=      8'b1000_0001;
        end
        else begin
            o_data_reg[3]                           <=      add_bias_res_w[31:24];
        end

        // res_ele_4
        if((i_data[39] == i_bias[39]) && (i_data[39] == 1'b0) && (add_bias_res_w[39] == 1'b1)) begin
            o_data_reg[4]                           <=      8'b0111_1111;
        end
        else if ((i_data[39] == i_bias[39]) && (i_data[39] == 1'b1) && (add_bias_res_w[39] == 1'b0)) begin
            o_data_reg[4]                           <=      8'b1000_0001;
        end
        else begin
            o_data_reg[4]                           <=      add_bias_res_w[39:32];
        end

        // res_ele_5
        if((i_data[47] == i_bias[47]) && (i_data[47] == 1'b0) && (add_bias_res_w[47] == 1'b1)) begin
            o_data_reg[5]                           <=      8'b0111_1111;
        end
        else if ((i_data[47] == i_bias[47]) && (i_data[47] == 1'b1) && (add_bias_res_w[47] == 1'b0)) begin
            o_data_reg[5]                           <=      8'b1000_0001;
        end
        else begin
            o_data_reg[5]                           <=      add_bias_res_w[47:40];
        end

        // res_ele_6
        if((i_data[55] == i_bias[55]) && (i_data[55] == 1'b0) && (add_bias_res_w[55] == 1'b1)) begin
            o_data_reg[6]                           <=      8'b0111_1111;
        end
        else if ((i_data[55] == i_bias[55]) && (i_data[55] == 1'b1) && (add_bias_res_w[55] == 1'b0)) begin
            o_data_reg[6]                           <=      8'b1000_0001;
        end
        else begin
            o_data_reg[6]                           <=      add_bias_res_w[55:48];
        end

        // res_ele_7
        if((i_data[63] == i_bias[63]) && (i_data[63] == 1'b0) && (add_bias_res_w[63] == 1'b1)) begin
            o_data_reg[7]                           <=      8'b0111_1111;
        end
        else if ((i_data[63] == i_bias[63]) && (i_data[63] == 1'b1) && (add_bias_res_w[63] == 1'b0)) begin
            o_data_reg[7]                           <=      8'b1000_0001;
        end
        else begin
            o_data_reg[7]                           <=      add_bias_res_w[63:56];
        end
    end
    else begin
        o_data_reg[0]                               <=      i_data[7:0];
        o_data_reg[1]                               <=      i_data[15:8];
        o_data_reg[2]                               <=      i_data[23:16];
        o_data_reg[3]                               <=      i_data[31:24];
        o_data_reg[4]                               <=      i_data[39:32];
        o_data_reg[5]                               <=      i_data[47:40];
        o_data_reg[6]                               <=      i_data[55:48];
        o_data_reg[7]                               <=      i_data[63:56];
    end
end


assign  o_data                                      =       {o_data_reg[0], o_data_reg[1], o_data_reg[2], 
                                                            o_data_reg[3], o_data_reg[4], o_data_reg[5], 
                                                            o_data_reg[6], o_data_reg[7]};
assign  o_data_v                                    =       o_data_v_reg;





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



always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        o_en_relu                                   <=      1'b0;
    end
    else begin
        o_en_relu                                   <=      i_en_relu;
        o_rf_idx                                    <=      i_rf_idx;
        o_rf_mux                                    <=      i_rf_mux;
    end
end



endmodule