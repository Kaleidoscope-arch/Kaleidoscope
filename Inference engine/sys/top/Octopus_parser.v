`timescale 1ns / 1ps

module Octopus_parser #(
	// Slave AXI parameters
	// AXI Stream parameters
	// Slave
	parameter C_S_AXIS_TDATA_WIDTH = 512,
	parameter C_S_AXIS_TUSER_WIDTH = 256,
	parameter C_S_AXIS_TKEEP_WIDTH = 64,
	parameter C_NUM_QUEUES = 1,
	parameter C_VLANID_WIDTH = 12,
    parameter C_S_AXI_DATA_WIDTH    = 32,
    parameter C_S_AXI_ADDR_WIDTH    = 32,
	parameter INIT_FILE             = 1  
	
	// Master
	// self-defined
)
(
	input									    clk          ,		// axis clk
	input									    rst      ,	

	// input Slave AXI Stream
	input [C_S_AXIS_TDATA_WIDTH-1:0]		    s_axis_tdata ,
	input [C_S_AXIS_TKEEP_WIDTH-1:0]		    s_axis_tkeep ,
	input [C_S_AXIS_TUSER_WIDTH-1:0]			s_axis_tuser ,
	input										s_axis_tvalid,
	input										s_axis_tlast ,

	// output Master AXI Stream
	output  reg  [32+32+48+48+16-1:0]		five_tuple ,
	output  reg  [16+16+8-1:0]	            three_tuple ,
	output  reg 					        valid,
    output  reg  [64*8-1:0]                 payload,
	input 		 							ready
	
);
// reg [C_S_AXIS_TDATA_WIDTH-1:0] data_t;
// integer i;
wire [C_S_AXIS_TDATA_WIDTH-1:0] data_t;
// always @(*) begin
//     for (i = 0;i<64 ;i=i+1 ) begin
//         data_t[8*i+:8]=s_axis_tdata[511-8*i-:8];
//     end
// end
generate
    genvar i;
    for (i = 0;i<64 ;i=i+1 ) begin
        assign data_t[8*i+:8]=s_axis_tdata[511-8*i-:8];
    end
endgenerate
// assign data_t = {	                s_axis_tdata[0+:8],
// 								    s_axis_tdata[8+:8],
// 								    s_axis_tdata[16+:8],
// 								    s_axis_tdata[24+:8],
// 								    s_axis_tdata[32+:8],
// 								    s_axis_tdata[40+:8],
// 								    s_axis_tdata[48+:8],
// 								    s_axis_tdata[56+:8],
// 								    s_axis_tdata[64+:8],
// 								    s_axis_tdata[72+:8],
// 								    s_axis_tdata[80+:8],
// 								    s_axis_tdata[88+:8],
// 								    s_axis_tdata[96+:8],
// 								    s_axis_tdata[104+:8],
// 								    s_axis_tdata[112+:8],
// 								    s_axis_tdata[120+:8],
// 								    s_axis_tdata[128+:8],
// 								    s_axis_tdata[136+:8],
// 								    s_axis_tdata[144+:8],
// 								    s_axis_tdata[152+:8],
// 								    s_axis_tdata[160+:8],
// 								    s_axis_tdata[168+:8],
// 								    s_axis_tdata[176+:8],
// 								    s_axis_tdata[184+:8],
// 								    s_axis_tdata[192+:8],
// 								    s_axis_tdata[200+:8],
// 								    s_axis_tdata[208+:8],
// 								    s_axis_tdata[216+:8],
// 								    s_axis_tdata[224+:8],
// 								    s_axis_tdata[232+:8],
// 								    s_axis_tdata[240+:8],
// 								    s_axis_tdata[248+:8],
//                                     s_axis_tdata[256+:8],
// 								    s_axis_tdata[264+:8],
// 								    s_axis_tdata[272+:8],
// 								    s_axis_tdata[280+:8],
// 								    s_axis_tdata[288+:8],
// 								    s_axis_tdata[296+:8],
// 								    s_axis_tdata[304+:8],
// 								    s_axis_tdata[312+:8],
// 								    s_axis_tdata[320+:8],
// 								    s_axis_tdata[328+:8],
// 								    s_axis_tdata[336+:8],
// 								    s_axis_tdata[344+:8],
// 								    s_axis_tdata[352+:8],
// 								    s_axis_tdata[360+:8],
// 								    s_axis_tdata[368+:8],
// 								    s_axis_tdata[376+:8],
// 								    s_axis_tdata[384+:8],
// 								    s_axis_tdata[392+:8],
// 								    s_axis_tdata[400+:8],
// 								    s_axis_tdata[408+:8],
// 								    s_axis_tdata[416+:8],
// 								    s_axis_tdata[424+:8],
// 								    s_axis_tdata[432+:8],
// 								    s_axis_tdata[440+:8],
// 								    s_axis_tdata[448+:8],
// 								    s_axis_tdata[456+:8],
// 								    s_axis_tdata[464+:8],
// 								    s_axis_tdata[472+:8],
// 								    s_axis_tdata[480+:8],
// 								    s_axis_tdata[488+:8],
// 								    s_axis_tdata[496+:8],
// 								    s_axis_tdata[504+:8]          
//                                         };
reg [2:0] state,next_state;

parameter IDLE=0;
parameter Ext=1;
parameter Wait_UDP=2;
parameter Wait_UDP2=3;
parameter Wait_TCP=4;
parameter Wait_TCP2=5;
parameter Wait=6;

reg [31:0] sip;
reg [31:0] dip;
reg [15:0] sport;
reg [15:0] dport;
reg [7:0] trans_protocol;
reg [7:0] trans_protocol_r;

reg [32+32+48+48+16-1:0] five_tuple_r;
reg [16+16+8-1:0]	     three_tuple_r;
reg [64*8-1:0]           payload_r;

always @(*) begin
    sip=data_t[303-:32];
    dip=data_t[271-:32];
    sport=data_t[239-:16];
    dport=data_t[223-:16];
    trans_protocol=data_t[327-:8];
    //trans_protocol=data_t[7:0];
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state<=0;
    end else begin
        state<=next_state;
    end
end
// assign s_axis_tready=ready;
always @(*) begin
    case (state)
        IDLE:begin
            five_tuple=0;
            three_tuple=0;
            payload=0;
            valid=0;
            if (s_axis_tvalid&s_axis_tlast&ready) begin
                next_state=Ext;
                trans_protocol_r=trans_protocol;
            end
            else if(s_axis_tvalid&(!s_axis_tlast)&ready) begin
                next_state=trans_protocol==6?Wait_TCP:Wait_UDP;
                trans_protocol_r=trans_protocol;
            end
            else begin
                next_state=IDLE;
            end
        end 
        Ext:begin
            five_tuple={sip,dip,sport,dport,trans_protocol_r};
            three_tuple={sport,dport,trans_protocol_r};
            payload=trans_protocol_r==6?{data_t[79:0],432'b0}:{data_t[175:0],336'b0};
            valid=1;
            if (s_axis_tvalid&s_axis_tlast&ready) begin
                next_state=Ext;
                trans_protocol_r=trans_protocol;
            end
            else if(s_axis_tvalid&(!s_axis_tlast)&ready) begin
                next_state=trans_protocol==6?Wait_TCP:Wait_UDP;
                trans_protocol_r=trans_protocol;
            end
            else begin
                next_state=IDLE;
            end
        end
        Wait_TCP:begin
            valid=0;
            five_tuple_r={sip,dip,sport,dport,trans_protocol_r};
            three_tuple_r={sport,dport,trans_protocol_r};
            payload_r={data_t[79:0],432'b0};
            if (s_axis_tvalid) begin
                next_state=Wait_TCP2;
                //payload_r={payload_r[511:432],data_t[511:80]};
            end
            else begin
                next_state=Wait_TCP;
                //payload_r=payload_r;
            end
        end
        Wait_TCP2:begin
            valid=1;
            five_tuple=five_tuple_r;
            three_tuple=three_tuple_r;
            payload={payload_r[511:432],data_t[511:80]};
            if ({s_axis_tvalid,s_axis_tlast,ready}==3'b111) begin
                next_state=IDLE;
            end
            else if({s_axis_tvalid,s_axis_tlast,ready}==3'b101) begin
                next_state=Wait;
            end
            else begin
                next_state=Wait_TCP2;
            end
        end
        Wait_UDP:begin
            valid=0;
            five_tuple_r={sip,dip,sport,dport,trans_protocol_r};
            three_tuple_r={sport,dport,trans_protocol_r};
            payload_r={data_t[175:0],336'b0};
            if (s_axis_tvalid) begin
                next_state=Wait_UDP2;
            end
            else begin
                next_state=Wait_UDP;
            end
        end
        Wait_UDP2:begin
            valid=1;
            five_tuple=five_tuple_r;
            three_tuple=three_tuple_r;
            payload={payload_r[511:336],data_t[511:176]};
            if ({s_axis_tvalid,s_axis_tlast,ready}==3'b111) begin
                next_state=IDLE;
            end
            else if({s_axis_tvalid,s_axis_tlast,ready}==3'b101) begin
                next_state=Wait;
            end
            else begin
                next_state=Wait_UDP2;
            end
        end
        Wait:begin
            valid=0;
            if (s_axis_tvalid&s_axis_tlast) begin
                next_state=IDLE;
            end
            else begin
                next_state=Wait;
            end
        end
        default: begin
            five_tuple=0;
            three_tuple=0;
            payload=0;
            valid=0;
            if (s_axis_tvalid&s_axis_tlast&ready) begin
                next_state=Ext;
            end
            else if(s_axis_tvalid&(!s_axis_tlast)&ready) begin
                next_state=trans_protocol==6?Wait_TCP:Wait_UDP;
            end
            else begin
                next_state=IDLE;
            end
        end
    endcase
end
endmodule
