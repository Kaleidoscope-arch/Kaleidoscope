// Generator : SpinalHDL v1.10.1    git head : 2527c7c6b0fb0f95e5e1a5722a0be732b364ce43
// Component : VPECtrler

`timescale 1ns/1ps

module VPECtrler_scala (
  input  wire [11:0]   io_i_inst,
  output wire [7:0]    io_rd_inst_idx,
  output wire          io_rd_inst_valid,
  output wire          io_fetch_pkt_fea,
  input  wire          io_pkt_fea_valid,
  output wire          io_ldr,
  output wire [4:0]    io_ldr_idx,
  output wire          io_ldw,
  output wire [7:0]    io_ldw_addr,
  output wire          io_wr_reg,
  output wire [4:0]    io_wr_reg_idx,
  output wire [1:0]    io_wr_reg_mux,
  output wire          io_en_relu,
  output wire          io_en_simd,
  output wire          io_en_vadd,
  output wire          io_out_valid,
  output wire          io_ldb,
  output wire [7:0]    io_ldb_addr,
  input  wire          clk,
  input  wire          reset
);

  wire       [3:0]    VMUL;
  wire       [3:0]    VMULR;
  wire       [3:0]    VADD;
  wire       [3:0]    VADDR;
  wire       [3:0]    LDW;
  wire       [3:0]    LDR;
  wire       [3:0]    FETCH;
  wire       [3:0]    OUT_1;
  wire       [3:0]    FIN;
  wire       [3:0]    LDB;
  wire       [3:0]    NOP;
  reg                 fetch_pkt_fea;
  wire       [3:0]    opcode;
  wire       [7:0]    param;
  wire       [1:0]    FETCH_STATE;
  wire       [1:0]    RUN_STATE;
  reg        [1:0]    state;
  wire                when_VPECtrler_l85;
  wire                when_VPECtrler_l92;
  wire                when_VPECtrler_l91;
  reg                 rd_inst_valid;
  reg        [7:0]    rd_inst_idx;
  wire                when_VPECtrler_l105;
  reg                 ldr_1;
  reg        [4:0]    ldr_idx;
  reg                 ldw_1;
  reg        [7:0]    ldw_addr;
  reg                 wr_reg;
  reg        [4:0]    wr_reg_idx;
  reg        [1:0]    wr_reg_mux;
  reg                 en_relu;
  reg                 en_simd;
  reg                 en_vadd;
  reg                 out_valid;
  reg                 ldb_1;
  reg        [7:0]    ldb_addr;
  wire                when_VPECtrler_l151;
  wire                when_VPECtrler_l159;
  wire                when_VPECtrler_l160;
  wire                when_VPECtrler_l170;
  wire                when_VPECtrler_l171;
  wire                when_VPECtrler_l182;
  wire                when_VPECtrler_l183;
  wire                when_VPECtrler_l194;
  wire                when_VPECtrler_l195;
  wire                when_VPECtrler_l207;
  wire                when_VPECtrler_l208;
  wire                when_VPECtrler_l217;
  wire                when_VPECtrler_l218;
  wire                when_VPECtrler_l232;
  wire                when_VPECtrler_l233;
  wire                when_VPECtrler_l249;
  wire                when_VPECtrler_l250;

  assign VMUL = 4'b0001;
  assign VMULR = 4'b0010;
  assign VADD = 4'b0011;
  assign VADDR = 4'b0100;
  assign LDW = 4'b0101;
  assign LDR = 4'b0110;
  assign FETCH = 4'b0111;
  assign OUT_1 = 4'b1000;
  assign FIN = 4'b1001;
  assign LDB = 4'b1010;
  assign NOP = 4'b0000;
  assign io_fetch_pkt_fea = fetch_pkt_fea;
  assign opcode = io_i_inst[11 : 8];
  assign param = io_i_inst[7 : 0];
  assign FETCH_STATE = 2'b01;
  assign RUN_STATE = 2'b10;
  assign when_VPECtrler_l85 = (state == FETCH_STATE);
  assign when_VPECtrler_l92 = (opcode == FIN);
  assign when_VPECtrler_l91 = (state == RUN_STATE);
  assign io_rd_inst_valid = rd_inst_valid;
  assign io_rd_inst_idx = rd_inst_idx;
  assign when_VPECtrler_l105 = (state == RUN_STATE);
  assign io_ldr = ldr_1;
  assign io_ldr_idx = ldr_idx;
  assign io_ldw = ldw_1;
  assign io_ldw_addr = ldw_addr;
  assign io_ldb = ldb_1;
  assign io_ldb_addr = ldb_addr;
  assign io_wr_reg = wr_reg;
  assign io_wr_reg_idx = wr_reg_idx;
  assign io_wr_reg_mux = wr_reg_mux;
  assign io_en_relu = en_relu;
  assign io_en_simd = en_simd;
  assign io_en_vadd = en_vadd;
  assign io_out_valid = out_valid;
  assign when_VPECtrler_l151 = (state == FETCH_STATE);
  assign when_VPECtrler_l159 = (state == RUN_STATE);
  assign when_VPECtrler_l160 = ((opcode == LDR) || (opcode == OUT_1));
  assign when_VPECtrler_l170 = (state == RUN_STATE);
  assign when_VPECtrler_l171 = (opcode == OUT_1);
  assign when_VPECtrler_l182 = (state == RUN_STATE);
  assign when_VPECtrler_l183 = (opcode == LDW);
  assign when_VPECtrler_l194 = (state == RUN_STATE);
  assign when_VPECtrler_l195 = (opcode == LDB);
  assign when_VPECtrler_l207 = (state == RUN_STATE);
  assign when_VPECtrler_l208 = ((opcode == VMUL) || (opcode == VMULR));
  assign when_VPECtrler_l217 = (state == RUN_STATE);
  assign when_VPECtrler_l218 = ((((opcode == VMUL) || (opcode == VMULR)) || (opcode == VADD)) || (opcode == VADDR));
  assign when_VPECtrler_l232 = (state == RUN_STATE);
  assign when_VPECtrler_l233 = ((((opcode == VMUL) || (opcode == VMULR)) || (opcode == VADD)) || (opcode == VADDR));
  assign when_VPECtrler_l249 = (state == RUN_STATE);
  assign when_VPECtrler_l250 = ((opcode == VMULR) || (opcode == VADDR));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      fetch_pkt_fea <= 1'b0;
      state <= 2'b01;
      rd_inst_valid <= 1'b0;
      rd_inst_idx <= 8'h00;
      ldr_1 <= 1'b0;
      ldw_1 <= 1'b0;
      wr_reg <= 1'b0;
      en_relu <= 1'b0;
      en_simd <= 1'b0;
      en_vadd <= 1'b0;
      out_valid <= 1'b0;
      ldb_1 <= 1'b0;
    end else begin
      if(when_VPECtrler_l85) begin
        if(io_pkt_fea_valid) begin
          state <= RUN_STATE;
        end else begin
          state <= FETCH_STATE;
        end
      end else begin
        if(when_VPECtrler_l91) begin
          if(when_VPECtrler_l92) begin
            state <= FETCH_STATE;
          end else begin
            state <= RUN_STATE;
          end
        end
      end
      if(when_VPECtrler_l105) begin
        rd_inst_valid <= 1'b1;
        rd_inst_idx <= (rd_inst_idx + 8'h01);
      end else begin
        rd_inst_valid <= 1'b0;
        rd_inst_idx <= 8'h00;
      end
      if(when_VPECtrler_l151) begin
        fetch_pkt_fea <= 1'b1;
      end else begin
        fetch_pkt_fea <= 1'b0;
      end
      if(when_VPECtrler_l159) begin
        if(when_VPECtrler_l160) begin
          ldr_1 <= 1'b1;
        end else begin
          ldr_1 <= 1'b0;
        end
      end else begin
        ldr_1 <= 1'b0;
      end
      if(when_VPECtrler_l170) begin
        if(when_VPECtrler_l171) begin
          out_valid <= 1'b1;
        end else begin
          out_valid <= 1'b0;
        end
      end else begin
        out_valid <= 1'b0;
      end
      if(when_VPECtrler_l182) begin
        if(when_VPECtrler_l183) begin
          ldw_1 <= 1'b1;
        end else begin
          ldw_1 <= 1'b0;
        end
      end else begin
        ldw_1 <= 1'b0;
      end
      if(when_VPECtrler_l194) begin
        if(when_VPECtrler_l195) begin
          ldb_1 <= 1'b1;
        end else begin
          ldb_1 <= 1'b0;
        end
      end else begin
        ldb_1 <= 1'b0;
      end
      if(when_VPECtrler_l207) begin
        if(when_VPECtrler_l208) begin
          en_simd <= 1'b1;
        end else begin
          en_simd <= 1'b0;
        end
      end else begin
        en_simd <= 1'b0;
      end
      if(when_VPECtrler_l217) begin
        if(when_VPECtrler_l218) begin
          en_vadd <= 1'b1;
          wr_reg <= 1'b1;
        end else begin
          en_vadd <= 1'b0;
          wr_reg <= 1'b0;
        end
      end else begin
        en_vadd <= 1'b0;
        wr_reg <= 1'b0;
      end
      if(when_VPECtrler_l232) begin
        if(when_VPECtrler_l233) begin
          en_vadd <= 1'b1;
          wr_reg <= 1'b1;
        end else begin
          en_vadd <= 1'b0;
          wr_reg <= 1'b0;
        end
      end else begin
        en_vadd <= 1'b0;
        wr_reg <= 1'b0;
      end
      if(when_VPECtrler_l249) begin
        if(when_VPECtrler_l250) begin
          en_relu <= 1'b1;
        end else begin
          en_relu <= 1'b0;
        end
      end else begin
        en_relu <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
    if(when_VPECtrler_l159) begin
      if(when_VPECtrler_l160) begin
        ldr_idx <= param[4 : 0];
      end
    end
    if(when_VPECtrler_l182) begin
      if(when_VPECtrler_l183) begin
        ldw_addr <= param;
      end
    end
    if(when_VPECtrler_l194) begin
      if(when_VPECtrler_l195) begin
        ldb_addr <= param;
      end
    end
    if(when_VPECtrler_l217) begin
      if(when_VPECtrler_l218) begin
        wr_reg_idx <= param[4 : 0];
        wr_reg_mux <= param[6 : 5];
      end
    end
    if(when_VPECtrler_l232) begin
      if(when_VPECtrler_l233) begin
        wr_reg_idx <= param[4 : 0];
        wr_reg_mux <= param[6 : 5];
      end
    end
  end


endmodule
