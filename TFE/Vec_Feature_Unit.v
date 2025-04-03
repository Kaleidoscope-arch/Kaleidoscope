/*  
    This module is the output buffer of alu cluster.
    
*/

module Vec_Feature_Unit (
    input   wire                                clk,
    input   wire                                rst_n,

    input   wire    [7:0]                       n_pkt,
    input   wire    [7:0]                       cur_data,
    input   wire                                cur_data_v,
    input   wire                                reach_thrh,
    input   wire    [159:0]                     hist_vec,
    input   wire    [1:0]                       vec_func, // 01: pkt_size, 10: pkt_arit
    // 00: non-work, 01: pkt_size only, 10: pkt_arit only, 
    // 11: high-80bit for pkt_size_vec, low-80bit for pkt_arit_vec
    input   wire    [1:0]                       vec_mode,

    output  wire    [159:0]                     vec_feature,
    output  wire                                vec_feature_v_w
);


reg     [7:0]                                   vec_reg     [19:0];
reg                                             vec_feature_v;

assign      vec_feature_v_w                    =        vec_feature_v;
assign      vec_feature         =   {
                                        vec_reg[19], vec_reg[18], vec_reg[17], 
                                        vec_reg[16], vec_reg[15], vec_reg[14], 
                                        vec_reg[13], vec_reg[12], vec_reg[11], 
                                        vec_reg[10], 
                                        vec_reg[9], vec_reg[8], vec_reg[7], 
                                        vec_reg[6], vec_reg[5], vec_reg[4], 
                                        vec_reg[3], vec_reg[2], vec_reg[1], 
                                        vec_reg[0]
                                    };




always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        vec_reg[0]                              <=              8'd0;
        vec_reg[1]                              <=              8'd0;
        vec_reg[2]                              <=              8'd0;
        vec_reg[3]                              <=              8'd0;
        vec_reg[4]                              <=              8'd0;
        vec_reg[5]                              <=              8'd0;
        vec_reg[6]                              <=              8'd0;
        vec_reg[7]                              <=              8'd0;
        vec_reg[8]                              <=              8'd0;
        vec_reg[9]                              <=              8'd0;
        vec_reg[10]                             <=              8'd0;
        vec_reg[11]                             <=              8'd0;
        vec_reg[12]                             <=              8'd0;
        vec_reg[13]                             <=              8'd0;
        vec_reg[14]                             <=              8'd0;
        vec_reg[15]                             <=              8'd0;
        vec_reg[16]                             <=              8'd0;
        vec_reg[17]                             <=              8'd0;
        vec_reg[18]                             <=              8'd0;
        vec_reg[19]                             <=              8'd0;
    end
    else begin
        if(cur_data_v) begin
            if(vec_mode == 2'b01 || vec_mode == 2'b10) begin
                vec_reg[0]                              <=              hist_vec[7:0];
                vec_reg[1]                              <=              hist_vec[15:8];
                vec_reg[2]                              <=              hist_vec[23:16];
                vec_reg[3]                              <=              hist_vec[31:24];
                vec_reg[4]                              <=              hist_vec[39:32];
                vec_reg[5]                              <=              hist_vec[47:40];
                vec_reg[6]                              <=              hist_vec[55:48];
                vec_reg[7]                              <=              hist_vec[63:56];
                vec_reg[8]                              <=              hist_vec[71:64];
                vec_reg[9]                              <=              hist_vec[79:72];
                vec_reg[10]                             <=              hist_vec[87:80];
                vec_reg[11]                             <=              hist_vec[95:88];
                vec_reg[12]                             <=              hist_vec[103:96];
                vec_reg[13]                             <=              hist_vec[111:104];
                vec_reg[14]                             <=              hist_vec[119:112];
                vec_reg[15]                             <=              hist_vec[127:120];
                vec_reg[16]                             <=              hist_vec[135:128];
                vec_reg[17]                             <=              hist_vec[143:136];
                vec_reg[18]                             <=              hist_vec[151:144];
                vec_reg[19]                             <=              hist_vec[159:152];
                vec_reg[n_pkt-1]                        <=              cur_data;
            end
            else if (vec_mode == 2'b11) begin
                if (vec_func == 2'b01) begin // pkt_size_vec
                    vec_reg[0]                              <=              hist_vec[87:80];
                    vec_reg[1]                              <=              hist_vec[95:88];
                    vec_reg[2]                              <=              hist_vec[103:96];
                    vec_reg[3]                              <=              hist_vec[111:104];
                    vec_reg[4]                              <=              hist_vec[119:112];
                    vec_reg[5]                              <=              hist_vec[127:120];
                    vec_reg[6]                              <=              hist_vec[135:128];
                    vec_reg[7]                              <=              hist_vec[143:136];
                    vec_reg[8]                              <=              hist_vec[151:144];
                    vec_reg[9]                              <=              hist_vec[159:152];
                    vec_reg[10]                             <=              8'd0;
                    vec_reg[11]                             <=              8'd0;
                    vec_reg[12]                             <=              8'd0;
                    vec_reg[13]                             <=              8'd0;
                    vec_reg[14]                             <=              8'd0;
                    vec_reg[15]                             <=              8'd0;
                    vec_reg[16]                             <=              8'd0;
                    vec_reg[17]                             <=              8'd0;
                    vec_reg[18]                             <=              8'd0;
                    vec_reg[19]                             <=              8'd0;
                    vec_reg[n_pkt-1]                        <=              cur_data;
                end
                else begin // pkt_arit_vec
                    vec_reg[0]                              <=              hist_vec[7:0];
                    vec_reg[1]                              <=              hist_vec[15:8];
                    vec_reg[2]                              <=              hist_vec[23:16];
                    vec_reg[3]                              <=              hist_vec[31:24];
                    vec_reg[4]                              <=              hist_vec[39:32];
                    vec_reg[5]                              <=              hist_vec[47:40];
                    vec_reg[6]                              <=              hist_vec[55:48];
                    vec_reg[7]                              <=              hist_vec[63:56];
                    vec_reg[8]                              <=              hist_vec[71:64];
                    vec_reg[9]                              <=              hist_vec[79:72];
                    vec_reg[10]                             <=              8'd0;
                    vec_reg[11]                             <=              8'd0;
                    vec_reg[12]                             <=              8'd0;
                    vec_reg[13]                             <=              8'd0;
                    vec_reg[14]                             <=              8'd0;
                    vec_reg[15]                             <=              8'd0;
                    vec_reg[16]                             <=              8'd0;
                    vec_reg[17]                             <=              8'd0;
                    vec_reg[18]                             <=              8'd0;
                    vec_reg[19]                             <=              8'd0;
                    vec_reg[n_pkt-1]                        <=              cur_data;
                end
            end
            else begin
                vec_reg[0]                              <=              8'd0;
                vec_reg[1]                              <=              8'd0;
                vec_reg[2]                              <=              8'd0;
                vec_reg[3]                              <=              8'd0;
                vec_reg[4]                              <=              8'd0;
                vec_reg[5]                              <=              8'd0;
                vec_reg[6]                              <=              8'd0;
                vec_reg[7]                              <=              8'd0;
                vec_reg[8]                              <=              8'd0;
                vec_reg[9]                              <=              8'd0;
                vec_reg[10]                             <=              8'd0;
                vec_reg[11]                             <=              8'd0;
                vec_reg[12]                             <=              8'd0;
                vec_reg[13]                             <=              8'd0;
                vec_reg[14]                             <=              8'd0;
                vec_reg[15]                             <=              8'd0;
                vec_reg[16]                             <=              8'd0;
                vec_reg[17]                             <=              8'd0;
                vec_reg[18]                             <=              8'd0;
                vec_reg[19]                             <=              8'd0;
            end
        end
    end
end


always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        vec_feature_v                           <=              1'd0;
    end
    else begin
        if(cur_data_v) begin
            vec_feature_v                       <=              1'd1;
        end
        else begin
            vec_feature_v                       <=              1'd0;
        end
    end
end


endmodule