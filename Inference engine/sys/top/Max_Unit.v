module Max_Unit (
    input                                               rst,
    input                                               clk,

    input   [71:0]                                      i_data,
    input                                               i_data_valid,

    output  [3:0]                                       inf_res,
    output                                              inf_res_valid
);



// compare level 0
reg     [7:0]                                           cmp_data_levl0      [4:0];
reg     [3:0]                                           cmp_idx_levl0       [4:0];
reg                                                     valid_levl0;
wire    [7:0]                                           sub_levl0_group0;
wire    [7:0]                                           sub_levl0_group1;
wire    [7:0]                                           sub_levl0_group2;
wire    [7:0]                                           sub_levl0_group3;
assign      sub_levl0_group0                    =       i_data[15:8] - i_data[7:0];
assign      sub_levl0_group1                    =       i_data[31:24] - i_data[23:16];
assign      sub_levl0_group2                    =       i_data[47:40] - i_data[39:32];
assign      sub_levl0_group3                    =       i_data[63:56] - i_data[55:48];

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        cmp_data_levl0[0]                       <=      8'b0;
        cmp_data_levl0[1]                       <=      8'b0;
        cmp_data_levl0[2]                       <=      8'b0;
        cmp_data_levl0[3]                       <=      8'b0;
        cmp_idx_levl0[0]                        <=      4'b0;
        cmp_idx_levl0[1]                        <=      4'b0;
        cmp_idx_levl0[2]                        <=      4'b0;
        cmp_idx_levl0[3]                        <=      4'b0;
        valid_levl0                             <=      1'b0;
    end
    else begin
        if(i_data_valid) begin
            valid_levl0                         <=      1'b1;
            
            if(~sub_levl0_group0[7]) begin
                cmp_data_levl0[0]               <=      i_data[15:8];
                cmp_idx_levl0[0]                <=      4'd1;
            end
            else begin
                cmp_data_levl0[0]               <=      i_data[7:0];
                cmp_idx_levl0[0]                <=      4'd0;
            end

            if(~sub_levl0_group1[7]) begin
                cmp_data_levl0[1]               <=      i_data[31:24];
                cmp_idx_levl0[1]                <=      4'd3;
            end
            else begin
                cmp_data_levl0[1]               <=      i_data[23:16];
                cmp_idx_levl0[1]                <=      4'd2;
            end

            if(~sub_levl0_group2[7]) begin
                cmp_data_levl0[2]               <=      i_data[47:40];
                cmp_idx_levl0[2]                <=      4'd5;
            end
            else begin
                cmp_data_levl0[2]               <=      i_data[39:32];
                cmp_idx_levl0[2]                <=      4'd4;
            end

            if(~sub_levl0_group3[7]) begin
                cmp_data_levl0[3]               <=      i_data[63:56];
                cmp_idx_levl0[3]                <=      4'd7;
            end
            else begin
                cmp_data_levl0[3]               <=      i_data[55:48];
                cmp_idx_levl0[3]                <=      4'd6;
            end

            cmp_data_levl0[4]                   <=      i_data[71:64];
            cmp_idx_levl0[4]                    <=      4'd8;

        end
        else begin
            valid_levl0                         <=      1'b0;
        end
    end
end




// compare level 1
reg     [7:0]                                           cmp_data_levl1      [2:0];
reg     [3:0]                                           cmp_idx_levl1       [2:0];
reg                                                     valid_levl1;
wire    [7:0]                                           sub_levl1_group0;
wire    [7:0]                                           sub_levl1_group1;
assign      sub_levl1_group0                    =       cmp_data_levl0[1] - cmp_data_levl0[0];
assign      sub_levl1_group1                    =       cmp_data_levl0[3] - cmp_data_levl0[2];

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        cmp_data_levl1[0]                       <=      8'b0;
        cmp_data_levl1[1]                       <=      8'b0;
        cmp_data_levl1[2]                       <=      8'b0;
        cmp_idx_levl1[0]                        <=      4'b0;
        cmp_idx_levl1[1]                        <=      4'b0;
        cmp_idx_levl1[2]                        <=      4'b0;
        valid_levl1                             <=      1'b0;
    end
    else begin
        if(valid_levl0) begin
            valid_levl1                         <=      1'b1;
            
            if(~sub_levl1_group0[7]) begin
                cmp_data_levl1[0]               <=      cmp_data_levl0[1];
                cmp_idx_levl1[0]                <=      cmp_idx_levl0[1];
            end
            else begin
                cmp_data_levl1[0]               <=      cmp_data_levl0[0];
                cmp_idx_levl1[0]                <=      cmp_idx_levl0[0];
            end

            if(~sub_levl1_group1[7]) begin
                cmp_data_levl1[1]               <=      cmp_data_levl0[3];
                cmp_idx_levl1[1]                <=      cmp_idx_levl0[3];
            end
            else begin
                cmp_data_levl1[1]               <=      cmp_data_levl0[2];
                cmp_idx_levl1[1]                <=      cmp_idx_levl0[2];
            end


            cmp_data_levl1[2]                   <=      cmp_data_levl0[4];
            cmp_idx_levl1[2]                    <=      cmp_idx_levl0[4];

        end
        else begin
            valid_levl1                         <=      1'b0;
        end
    end
end





// compare level 2
reg     [7:0]                                           cmp_data_levl2      [1:0];
reg     [3:0]                                           cmp_idx_levl2       [1:0];
reg                                                     valid_levl2;
wire    [7:0]                                           sub_levl2_group0;
assign      sub_levl2_group0                    =       cmp_data_levl1[1] - cmp_data_levl1[0];


always @ (posedge clk or posedge rst) begin
    if(rst) begin
        cmp_data_levl2[0]                       <=      8'b0;
        cmp_data_levl2[1]                       <=      8'b0;
        cmp_idx_levl2[0]                        <=      4'b0;
        cmp_idx_levl2[1]                        <=      4'b0;
        valid_levl2                             <=      1'b0;
    end
    else begin
        if(valid_levl1) begin
            valid_levl2                         <=      1'b1;
            
            if(~sub_levl2_group0[7]) begin
                cmp_data_levl2[0]               <=      cmp_data_levl1[1];
                cmp_idx_levl2[0]                <=      cmp_idx_levl1[1];
            end
            else begin
                cmp_data_levl2[0]               <=      cmp_data_levl1[0];
                cmp_idx_levl2[0]                <=      cmp_idx_levl1[0];
            end

            cmp_data_levl2[1]                   <=      cmp_data_levl1[2];
            cmp_idx_levl2[1]                    <=      cmp_idx_levl1[2];

        end
        else begin
            valid_levl2                         <=      1'b0;
        end
    end
end





// compare level 3
reg     [7:0]                                           cmp_data_levl3;
reg     [3:0]                                           cmp_idx_levl3;
reg                                                     valid_levl3;
wire    [7:0]                                           sub_levl3_group0;
assign      sub_levl3_group0                    =       cmp_data_levl2[1] - cmp_data_levl2[0];


always @ (posedge clk or posedge rst) begin
    if(rst) begin
        cmp_data_levl3                          <=      8'b0;
        cmp_idx_levl3                           <=      4'b0;
        valid_levl3                             <=      1'b0;
    end
    else begin
        if(valid_levl2) begin
            valid_levl3                         <=      1'b1;
            
            if(~sub_levl3_group0[7]) begin
                cmp_data_levl3                  <=      cmp_data_levl2[1];
                cmp_idx_levl3                   <=      cmp_idx_levl2[1];
            end
            else begin
                cmp_data_levl3                  <=      cmp_data_levl2[0];
                cmp_idx_levl3                   <=      cmp_idx_levl2[0];
            end

        end
        else begin
            valid_levl3                         <=      1'b0;
        end
    end
end


assign      inf_res                             =       cmp_idx_levl3;
assign      inf_res_valid                       =       valid_levl3;



endmodule