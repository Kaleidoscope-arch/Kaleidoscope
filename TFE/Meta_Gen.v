/*  
    This file is the meta feature generator, producing pkt_arvt and reg
    other meta feature from Wine_dispenser. 

*/

module Meta_Gen (
    input   wire                                clk,
    input   wire                                rst_n,

    input   wire    [103:0]                     ip_tuple,
    input   wire    [15:0]                      i_pkt_size,
    input   wire    [7:0]                       pkt_flag,
    input   wire    [15:0]                      wind_size,
    input   wire                                pkt_v,

    output  wire    [143:0]                     meta_w,
    output  wire    [15:0]                      pkt_arvt_w,
    output  wire                                meta_v_w,
    output  wire    [15:0]                      o_pkt_size
);

assign  pkt_arvt_w                      =       meta_feature_r[19:4];
assign  meta_v_w                        =       meta_v;
assign  o_pkt_size                      =       o_pkt_size_r;
assign  meta_w                          =       meta_feature_r;

reg     [19:0]                                  timer;
reg                                             meta_v;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        timer                           <=      'd0;
    end
    else begin
        timer                           <=      timer + 'd1;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        meta_v                          <=      'd0;
    end
    else begin
        if(pkt_v) begin
            meta_v                      <=      'd1;
        end
        else begin
            meta_v                      <=      'd0;
        end
    end
end


reg     [143:0]                                 meta_feature_r;
reg     [15:0]                                  o_pkt_size_r;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        meta_feature_r                  <=      'd0;
        o_pkt_size_r                    <=      'd0;
    end
    else begin
        meta_feature_r                  <=      {ip_tuple, i_pkt_size[15:8], pkt_flag, wind_size[15:8]};
        o_pkt_size_r                    <=      i_pkt_size;
    end
end



endmodule
