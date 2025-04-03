/*  
    This file is a dispenser, dispensing 512 bit input packet into different
    segments:
    IP tuple and all meta feature.
*/

// Note: All data in network transfering are big-endin
module Wine_Dispenser(
    input   wire    [511:0]                                 i_packet,

    output  wire    [103:0]                                 ip_tuple,
    output  wire    [103:0]                                 r_ip_tuple,
    output  wire    [15:0]                                  pkt_size,
    output  wire    [7:0]                                   tcp_flag,
    // output  wire    [79:0]                                  paylaod,
    output  wire    [15:0]                                  tcp_wind_size
);



wire    [47:0]                                              src_mac;
wire    [47:0]                                              dst_mac;
wire    [15:0]                                              eth_type;

wire    [3:0]                                               ip_ver;
wire    [3:0]                                               ip_head_size;
wire    [7:0]                                               ip_service;
// wire    [15:0]                                              pkt_size;
wire    [15:0]                                              ip_tag;
wire    [2:0]                                               ip_flag;
wire    [12:0]                                              ip_offs;
wire    [7:0]                                               live_time;
wire    [7:0]                                               ip_protocol;
wire    [15:0]                                              ip_head_checksum;
wire    [31:0]                                              src_ip;
wire    [31:0]                                              dst_ip;

wire    [15:0]                                              src_port;
wire    [15:0]                                              dst_port;
wire    [31:0]                                              tcp_seq;
wire    [31:0]                                              tcp_ack;
wire    [3:0]                                               tcp_head_size;
wire    [5:0]                                               tcp_reserve;
wire    [7:0]                                               tcp_flag;
wire    [15:0]                                              tcp_checksum;
wire    [15:0]                                              tcp_urgent_pt;



assign  src_mac                         =           i_packet[511:464];
assign  dst_mac                         =           i_packet[463:416];
assign  eth_type                        =           i_packet[415:400];
assign  ip_ver                          =           i_packet[399:396];
assign  ip_head_size                    =           i_packet[395:392];
assign  ip_service                      =           i_packet[391:384];
assign  pkt_size                        =           i_packet[383:368];
assign  ip_tag                          =           i_packet[367:352];
assign  ip_flag                         =           i_packet[351:349];
assign  ip_offs                         =           i_packet[348:336];
assign  live_time                       =           i_packet[335:328];
assign  ip_protocol                     =           i_packet[327:320];
assign  ip_head_checksum                =           i_packet[319:304];
assign  src_ip                          =           i_packet[303:272];
assign  dst_ip                          =           i_packet[271:240];
assign  src_port                        =           i_packet[239:224];
assign  dst_port                        =           i_packet[223:208];
assign  tcp_seq                         =           i_packet[207:176];
assign  tcp_ack                         =           i_packet[175:144];
assign  tcp_head_size                   =           i_packet[143:140];
assign  tcp_reserve                     =           i_packet[139:134];
assign  tcp_flag                        =           {2'b00, i_packet[133:128]};
assign  tcp_wind_size                   =           i_packet[127:112];
assign  tcp_checksum                    =           i_packet[111:96];
assign  tcp_urgent_pt                   =           i_packet[95:80];
// assign  paylaod                         =           i_packet[79:0];


assign  ip_tuple                        =           {src_ip, dst_ip, src_port, dst_port, ip_protocol};
assign  r_ip_tuple                      =           {dst_ip, src_ip, dst_port, src_port, ip_protocol};




endmodule