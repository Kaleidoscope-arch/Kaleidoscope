`timescale 1ns / 1ps

module Query_modify#(
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
	input									    clk,		// axis clk
	input									    rst,	
    //写端口
    input									    clk_octo,
	input									    rst_octo,	
    input                                       wea,
    input [15:0]                                waddr,
    input [4:0]                                 wdata, 

	// input Slave AXI Stream
	input [C_S_AXIS_TDATA_WIDTH-1:0]		    s_axis_tdata ,
	input [C_S_AXIS_TKEEP_WIDTH-1:0]		    s_axis_tkeep ,
	input [C_S_AXIS_TUSER_WIDTH-1:0]			s_axis_tuser ,
	input										s_axis_tvalid,
	output										s_axis_tready,
	input										s_axis_tlast ,

	// output Master AXI Stream
	output  reg   [C_S_AXIS_TDATA_WIDTH-1:0]		m_axis_tdata ,
	output  reg   [C_S_AXIS_TKEEP_WIDTH-1:0]	    m_axis_tkeep ,
	output  reg   [C_S_AXIS_TUSER_WIDTH-1:0]		m_axis_tuser ,
	output  reg  									m_axis_tvalid,
	input										    m_axis_tready,
	output  reg									    m_axis_tlast
);
reg     [15:0]                          raddr;
wire    [15:0]                          raddr_wire;
reg                                     hash_valid;
wire                                    hash_valid_wire;
reg     [4:0]                           rout;
reg     [4:0]                           rout_r;
wire    [4:0]                           rout_wire;

reg [C_S_AXIS_TDATA_WIDTH-1:0]          s_axis_tdata_r1;
reg [C_S_AXIS_TKEEP_WIDTH-1:0]		    s_axis_tkeep_r1 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]			s_axis_tuser_r1 ;
reg										s_axis_tvalid_r1;
reg										s_axis_tlast_r1 ;
reg [C_S_AXIS_TDATA_WIDTH-1:0]          s_axis_tdata_r2;
reg [C_S_AXIS_TKEEP_WIDTH-1:0]		    s_axis_tkeep_r2 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]			s_axis_tuser_r2 ;
reg										s_axis_tvalid_r2;
reg										s_axis_tlast_r2 ;
reg [C_S_AXIS_TDATA_WIDTH-1:0]          s_axis_tdata_r3;
reg [C_S_AXIS_TKEEP_WIDTH-1:0]		    s_axis_tkeep_r3 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]			s_axis_tuser_r3 ;
reg										s_axis_tvalid_r3;
reg										s_axis_tlast_r3 ;
reg [C_S_AXIS_TDATA_WIDTH-1:0]          s_axis_tdata_r4;
reg [C_S_AXIS_TKEEP_WIDTH-1:0]		    s_axis_tkeep_r4 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]			s_axis_tuser_r4 ;
reg										s_axis_tvalid_r4;
reg										s_axis_tlast_r4 ;
reg [C_S_AXIS_TDATA_WIDTH-1:0]          s_axis_tdata_r5;
reg [C_S_AXIS_TKEEP_WIDTH-1:0]		    s_axis_tkeep_r5 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]			s_axis_tuser_r5 ;
reg										s_axis_tvalid_r5;
reg										s_axis_tlast_r5 ;
reg [C_S_AXIS_TDATA_WIDTH-1:0]          s_axis_tdata_r6;
reg [C_S_AXIS_TKEEP_WIDTH-1:0]		    s_axis_tkeep_r6 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]			s_axis_tuser_r6 ;
reg										s_axis_tvalid_r6;
reg										s_axis_tlast_r6 ;
reg                                     rden_r1;
reg                                     rden_r2;
reg                                     rden_r3;
reg                                     rden_r4;
reg                                     rden_r5;
reg                                     rden_r6;

wire [103:0]                            five_tuple;
wire                                    five_tuple_valid;
reg                                     rden;

assign five_tuple = {s_axis_tdata[303-:32],s_axis_tdata[271-:32],s_axis_tdata[239-:16],s_axis_tdata[223-:16],s_axis_tdata[327-:8]};
assign five_tuple_valid = s_axis_tvalid;

Inference_Result_Table inference_result_table (
  .clka(clk),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(waddr),  // input wire [15 : 0] addra
  .dina(wdata),    // input wire [4 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(hash_valid),      // input wire enb
  .addrb(raddr),  // input wire [15 : 0] addrb
  .doutb(rout_wire)  // output wire [4 : 0] doutb
);

TFE_Hash_Gener TFE_hash_gener(
    .clk(clk),
    .rst(rst),
    .d(five_tuple),
    .d_valid(five_tuple_valid),
    .crc_out(raddr_wire),
    .hash_valid(hash_valid_wire)
);

reg [1:0] state,next_state;
parameter IDLE=0;
parameter WRITE=1;
parameter TRANS=2;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state<=0;
        rden<=0;
        rout_r<=0;
        raddr<=0;
        hash_valid<=0;
        rout<=0;
        s_axis_tdata_r1<=0;
        s_axis_tkeep_r1<=0 ;
        s_axis_tuser_r1<=0 ;
        s_axis_tvalid_r1<=0;
        s_axis_tlast_r1<=0 ;
        s_axis_tdata_r2<=0;
        s_axis_tkeep_r2<=0 ;
        s_axis_tuser_r2<=0 ;
        s_axis_tvalid_r2<=0;
        s_axis_tlast_r2<=0 ;
        s_axis_tdata_r3<=0;
        s_axis_tkeep_r3<=0 ;
        s_axis_tuser_r3<=0 ;
        s_axis_tvalid_r3<=0;
        s_axis_tlast_r3<=0 ;
        s_axis_tdata_r4<=0;
        s_axis_tkeep_r4<=0 ;
        s_axis_tuser_r4<=0 ;
        s_axis_tvalid_r4<=0;
        s_axis_tlast_r4<=0 ;
        s_axis_tdata_r5<=0;
        s_axis_tkeep_r5<=0;
        s_axis_tuser_r5<=0;
        s_axis_tvalid_r5<=0;
        s_axis_tlast_r5<=0;
        s_axis_tdata_r6<=0;
        s_axis_tkeep_r6<=0;
        s_axis_tuser_r6<=0;
        s_axis_tvalid_r6<=0;
        s_axis_tlast_r6<=0;
        rden_r1<=0;
        rden_r2<=0;
        rden_r3<=0;
        rden_r4<=0;
        rden_r5<=0;
        rden_r6<=0;
    end
    else begin
        state<=next_state;
        rden<=1;
        if (m_axis_tready) begin            
            s_axis_tdata_r1<=s_axis_tdata;
            s_axis_tkeep_r1<=s_axis_tkeep;
            s_axis_tuser_r1<=s_axis_tuser;
            s_axis_tvalid_r1<=s_axis_tvalid;
            s_axis_tlast_r1<=s_axis_tlast;
            s_axis_tdata_r2<=s_axis_tdata_r1;
            s_axis_tkeep_r2<=s_axis_tkeep_r1;
            s_axis_tuser_r2<=s_axis_tuser_r1;
            s_axis_tvalid_r2<=s_axis_tvalid_r1;
            s_axis_tlast_r2<=s_axis_tlast_r1 ;
            s_axis_tdata_r3<=s_axis_tdata_r2;
            s_axis_tkeep_r3<=s_axis_tkeep_r2;
            s_axis_tuser_r3<=s_axis_tuser_r2;
            s_axis_tvalid_r3<=s_axis_tvalid_r2;
            s_axis_tlast_r3<=s_axis_tlast_r2;
            s_axis_tdata_r4<=s_axis_tdata_r3;
            s_axis_tkeep_r4<=s_axis_tkeep_r3;
            s_axis_tuser_r4<=s_axis_tuser_r3;
            s_axis_tvalid_r4<=s_axis_tvalid_r3;
            s_axis_tlast_r4<=s_axis_tlast_r3;
            s_axis_tdata_r5<=s_axis_tdata_r4;
            s_axis_tkeep_r5<=s_axis_tkeep_r4;
            s_axis_tuser_r5<=s_axis_tuser_r4;
            s_axis_tvalid_r5<=s_axis_tvalid_r4;
            s_axis_tlast_r5<=s_axis_tlast_r4;
            s_axis_tdata_r6<=s_axis_tdata_r5;
            s_axis_tkeep_r6<=s_axis_tkeep_r5;
            s_axis_tuser_r6<=s_axis_tuser_r5;
            s_axis_tvalid_r6<=s_axis_tvalid_r5;
            s_axis_tlast_r6<=s_axis_tlast_r5;
            rden_r1<=rden;
            rden_r2<=rden_r1;
            rden_r3<=rden_r2;
            rden_r4<=rden_r3;
            rden_r5<=rden_r4;
            rden_r6<=rden_r5;
            raddr<=raddr_wire;
            rout<=rout_wire;
            hash_valid<=hash_valid_wire;
            rout_r<=rout;
        end
        else begin
            raddr<=raddr;
            hash_valid<=hash_valid;
            rout<=rout;
            rout_r<=rout_r;
            s_axis_tdata_r1<=s_axis_tdata_r1;
            s_axis_tkeep_r1<=s_axis_tkeep_r1;
            s_axis_tuser_r1<=s_axis_tuser_r1;
            s_axis_tvalid_r1<=s_axis_tvalid_r1;
            s_axis_tlast_r1<=s_axis_tlast_r1;
            s_axis_tdata_r2<=s_axis_tdata_r2;
            s_axis_tkeep_r2<=s_axis_tkeep_r2;
            s_axis_tuser_r2<=s_axis_tuser_r2;
            s_axis_tvalid_r2<=s_axis_tvalid_r2;
            s_axis_tlast_r2<=s_axis_tlast_r2 ;
            s_axis_tdata_r3<=s_axis_tdata_r3;
            s_axis_tkeep_r3<=s_axis_tkeep_r3;
            s_axis_tuser_r3<=s_axis_tuser_r3;
            s_axis_tvalid_r3<=s_axis_tvalid_r3;
            s_axis_tlast_r3<=s_axis_tlast_r3;
            s_axis_tdata_r4<=s_axis_tdata_r4;
            s_axis_tkeep_r4<=s_axis_tkeep_r4;
            s_axis_tuser_r4<=s_axis_tuser_r4;
            s_axis_tvalid_r4<=s_axis_tvalid_r4;
            s_axis_tlast_r4<=s_axis_tlast_r4;
            s_axis_tdata_r5<=s_axis_tdata_r5;
            s_axis_tkeep_r5<=s_axis_tkeep_r5;
            s_axis_tuser_r5<=s_axis_tuser_r5;
            s_axis_tvalid_r5<=s_axis_tvalid_r5;
            s_axis_tlast_r5<=s_axis_tlast_r5;
            s_axis_tdata_r6<=s_axis_tdata_r6;
            s_axis_tkeep_r6<=s_axis_tkeep_r6;
            s_axis_tuser_r6<=s_axis_tuser_r6;
            s_axis_tvalid_r6<=s_axis_tvalid_r6;
            s_axis_tlast_r6<=s_axis_tlast_r6;
            rden_r1<=rden_r1;
            rden_r2<=rden_r2;
            rden_r3<=rden_r3;
            rden_r4<=rden_r4;
            rden_r5<=rden_r5;
            rden_r6<=rden_r6;
        end
    end
end

assign s_axis_tready=m_axis_tready;

always @(*) begin
    case(state) 
        IDLE:begin
            m_axis_tdata=0; 
            m_axis_tkeep=0; 
            m_axis_tuser=0; 
            m_axis_tvalid=0;
            m_axis_tlast=0;
            if(s_axis_tvalid_r4 & rden_r4 & rout[0] & m_axis_tready)begin
                next_state=WRITE;
            end
            else if (s_axis_tvalid_r4 & !(rden_r4 & rout[0]) & m_axis_tready) begin
                next_state=TRANS;
            end
            else begin
                next_state=IDLE;
            end
        end
        WRITE:begin
            m_axis_tdata={s_axis_tdata_r5[511:248],rout_r[4:1],s_axis_tdata_r5[243:0]}; 
            m_axis_tkeep=s_axis_tkeep_r5; 
            m_axis_tuser=s_axis_tuser_r5; 
            m_axis_tvalid=s_axis_tvalid_r5;
            m_axis_tlast=s_axis_tlast_r5;
            if (s_axis_tlast_r5 & m_axis_tready & rden_r4 & s_axis_tvalid_r4) begin
                next_state=WRITE;
            end
            else
                next_state=TRANS;
        end
        TRANS:begin
            m_axis_tdata=s_axis_tdata_r5; 
            m_axis_tkeep=s_axis_tkeep_r5; 
            m_axis_tuser=s_axis_tuser_r5; 
            m_axis_tvalid=s_axis_tvalid_r5;
            m_axis_tlast=s_axis_tlast_r5;
            if (s_axis_tvalid_r4 & s_axis_tvalid_r5 & s_axis_tlast_r5 & m_axis_tready & rden_r4 & rout[0]) begin
                next_state=WRITE;
            end
            else
                next_state=TRANS;
        end
        default: begin
            m_axis_tdata=0; 
            m_axis_tkeep=0; 
            m_axis_tuser=0; 
            m_axis_tvalid=0;
            m_axis_tlast=0;
            next_state=IDLE;
        end
            
    endcase

end











endmodule
