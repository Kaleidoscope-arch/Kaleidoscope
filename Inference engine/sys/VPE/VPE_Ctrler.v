/* 
Controler for VPE 2.1
Written by verilog from scratch
*/


module VPECtrler_ (
  input  wire [35:0]   i_inst,
  output wire [7:0]    rd_inst_idx,
  output wire          rd_inst_valid,
  output wire          fetch_pkt_fea,
  input  wire          pkt_fea_valid,
  output wire          ldr,
  output wire [4:0]    ldr_idx,
  output wire          ldw,
  output wire [7:0]    ldw_addr,
  output wire          wr_reg,
  output wire [4:0]    wr_reg_idx,
  output wire [1:0]    wr_reg_mux,
  output wire          en_relu,
  output wire          en_simd,
  output wire          en_vadd,
  output wire          out_valid,
  output wire          ldb,
  output wire [7:0]    ldb_addr,
  input  wire          clk,
  input  wire          rst
);


parameter    VMUL   = 4'b0001;
parameter    VMULR  = 4'b0010;
parameter    VADD   = 4'b0011;
parameter    VADDR  = 4'b0100;
parameter    LDW    = 4'b0101;
parameter    LDR    = 4'b0110;
parameter    FETCH  = 4'b0111;
parameter    OUT    = 4'b1000;
parameter    FIN    = 4'b1001;
parameter    LDB    = 4'b1010;
parameter    NOP    = 4'b0000;
parameter    RUN_STATE    = 2'b10;
parameter    FETCH_STATE  = 2'b01;



wire    [3:0]                                       opcode_a;
wire    [7:0]                                       param_a;
wire    [3:0]                                       opcode_b;
wire    [7:0]                                       param_b;
wire    [3:0]                                       opcode_c;
wire    [7:0]                                       param_c;
assign  opcode_a                            =       i_inst[35:32];
assign  param_a                             =       i_inst[31:24];
assign  opcode_b                            =       i_inst[23:20];
assign  param_b                             =       i_inst[19:12];
assign  opcode_c                            =       i_inst[11:8];
assign  param_c                             =       i_inst[7:0];



reg     [1:0]                                       state;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        state                               <=      FETCH_STATE;
    end
    else begin
        case (state)
        FETCH_STATE: begin
            if(pkt_fea_valid) begin
                state                       <=      RUN_STATE;
            end
        end

        RUN_STATE: begin
            if(opcode_a == FIN) begin
                state                       <=      FETCH_STATE;
            end          
        end
        endcase
    end
end




reg                                                 rd_inst_reg;
reg     [7:0]                                       rd_inst_addr_reg;
assign  rd_inst_idx                         =       rd_inst_addr_reg;
assign  rd_inst_valid                       =       rd_inst_reg;
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        rd_inst_reg                         <=      1'b0;
        rd_inst_addr_reg                    <=      8'b0;
    end
    else begin
        case (state)
        RUN_STATE: begin
            rd_inst_reg                     <=      1'b1;
            rd_inst_addr_reg                <=      rd_inst_addr_reg + 1'b1;
        end

        FETCH_STATE: begin
            rd_inst_reg                     <=      1'b0;
            rd_inst_addr_reg                <=      8'b0;
        end

        endcase
    end
end




reg                                                 ldr_reg;
reg     [4:0]                                       ldr_idx_reg;
reg                                                 ldw_reg;
reg     [7:0]                                       ldw_addr_reg;
reg                                                 ldb_reg;
reg     [7:0]                                       ldb_addr_reg;
reg                                                 wr_reg_valid_reg;
reg     [4:0]                                       wr_reg_idx_reg;
reg     [1:0]                                       wr_reg_mux_reg;
reg                                                 en_relu_reg;
reg                                                 en_simd_reg;
reg                                                 en_vadd_reg;
reg                                                 out_valid_reg;
reg                                                 fetch_pkt_fea_reg;

assign  ldr                                 =       ldr_reg;
assign  ldr_idx                             =       ldr_idx_reg;
assign  ldw                                 =       ldw_reg;
assign  ldw_addr                            =       ldw_addr_reg;
assign  ldb                                 =       ldb_reg;
assign  ldb_addr                            =       ldb_addr_reg;
assign  wr_reg                              =       wr_reg_valid_reg;
assign  wr_reg_idx                          =       wr_reg_idx_reg;
assign  wr_reg_mux                          =       wr_reg_mux_reg;
assign  en_relu                             =       en_relu_reg;
assign  en_simd                             =       en_simd_reg;
assign  en_vadd                             =       en_vadd_reg;
assign  out_valid                           =       out_valid_reg;
assign  fetch_pkt_fea                       =       fetch_pkt_fea_reg;


always @ (posedge clk or posedge rst) begin
    if(rst) begin
        fetch_pkt_fea_reg                   <=      1'b0;    
    end
    else begin
        case (state)
        RUN_STATE: begin
            fetch_pkt_fea_reg               <=      1'b0;
        end
        FETCH_STATE: begin
            fetch_pkt_fea_reg               <=      1'b1;
        end
        endcase
    end
end


always @ (posedge clk or posedge rst) begin
    if(rst) begin
        ldr_reg                             <=      1'b0;
    end
    else begin
        if(opcode_b == LDR && state == RUN_STATE) begin
            ldr_reg                         <=      1'b1;
            ldr_idx_reg                     <=      param_b[4:0];
        end
        else begin
            ldr_reg                         <=      1'b0;
        end
    end
end



always @ (posedge clk or posedge rst) begin
    if(rst) begin
        out_valid_reg                       <=      1'b0;
    end
    else begin
        if(opcode_b == OUT && state == RUN_STATE) begin
            out_valid_reg                   <=      1'b1;
        end
        else begin
            out_valid_reg                   <=      1'b0;
        end
    end
end



always @ (posedge clk or posedge rst) begin
    if(rst) begin
        ldw_reg                             <=      1'b0;
    end
    else begin
        if(opcode_a == LDW && state == RUN_STATE) begin
            ldw_reg                         <=      1'b1;
            ldw_addr_reg                    <=      param_a;
        end
        else begin
            ldw_reg                         <=      1'b0;
        end
    end
end




always @ (posedge clk or posedge rst) begin
    if(rst) begin
        ldb_reg                             <=      1'b0;
    end
    else begin
        if(opcode_c == LDB && state == RUN_STATE) begin
            ldb_reg                         <=      1'b1;
            ldb_addr_reg                    <=      param_c;
        end
        else begin
            ldb_reg                         <=      1'b0;
        end
    end
end



always @ (posedge clk or posedge rst) begin
    if(rst) begin
        en_simd_reg                         <=      1'b0;
    end
    else begin
        if((opcode_b == VMUL || opcode_b == VMULR) && state == RUN_STATE) begin
            en_simd_reg                     <=      1'b1;
        end
        else begin
            en_simd_reg                     <=      1'b0;
        end
    end
end




always @ (posedge clk or posedge rst) begin
    if(rst) begin
        en_vadd_reg                         <=      1'b0;
        wr_reg_valid_reg                    <=      1'b0;
    end
    else begin
        if((opcode_b == VMUL || opcode_b == VMULR || opcode_b == VADD || opcode_b == VADDR) && state == RUN_STATE) begin
            en_vadd_reg                     <=      1'b1;
            wr_reg_valid_reg                <=      1'b1;
            wr_reg_idx_reg                  <=      param_b[4:0];
            wr_reg_mux_reg                  <=      param_b[6:5];
        end
        else begin
            en_vadd_reg                     <=      1'b0;
            wr_reg_valid_reg                <=      1'b0;
        end
    end
end


always @ (posedge clk or posedge rst) begin
    if(rst) begin
        en_relu_reg                         <=      1'b0;
    end
    else begin
        if((opcode_b == VMULR || opcode_b == VADDR) && state == RUN_STATE) begin
            en_relu_reg                     <=      1'b1;
        end
        else begin
            en_relu_reg                     <=      1'b0;
        end
    end
end




endmodule