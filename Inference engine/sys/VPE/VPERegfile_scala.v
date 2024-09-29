// Generator : SpinalHDL v1.10.1    git head : 2527c7c6b0fb0f95e5e1a5722a0be732b364ce43
// Component : VPERegfile

`timescale 1ns/1ps

module VPERegfile_scala (
  input  wire [4:0]    io_rd_index,
  output wire [255:0]  io_o_data,
  input  wire [4:0]    io_wr_index,
  input  wire [255:0]  io_i_data,
  input  wire          io_wr_valid,
  input  wire          clk,
  input  wire          reset,
  input  wire          fin
);

  reg        [255:0]  _zz_io_o_data;
  reg        [255:0]  regfile_0;
  reg        [255:0]  regfile_1;
  reg        [255:0]  regfile_2;
  reg        [255:0]  regfile_3;
  reg        [255:0]  regfile_4;
  reg        [255:0]  regfile_5;
  reg        [255:0]  regfile_6;
  reg        [255:0]  regfile_7;
  reg        [255:0]  regfile_8;
  reg        [255:0]  regfile_9;
  reg        [255:0]  regfile_10;
  reg        [255:0]  regfile_11;
  reg        [255:0]  regfile_12;
  reg        [255:0]  regfile_13;
  reg        [255:0]  regfile_14;
  reg        [255:0]  regfile_15;
//  reg        [255:0]  regfile_16;
//  reg        [255:0]  regfile_17;
//  reg        [255:0]  regfile_18;
//  reg        [255:0]  regfile_19;
//  reg        [255:0]  regfile_20;
//  reg        [255:0]  regfile_21;
//  reg        [255:0]  regfile_22;
//  reg        [255:0]  regfile_23;
//  reg        [255:0]  regfile_24;
//  reg        [255:0]  regfile_25;
//  reg        [255:0]  regfile_26;
//  reg        [255:0]  regfile_27;
//  reg        [255:0]  regfile_28;
//  reg        [255:0]  regfile_29;
//  reg        [255:0]  regfile_30;
//  reg        [255:0]  regfile_31;
  wire       [255:0]  regfile_wire_0;
  wire       [255:0]  regfile_wire_1;
  wire       [255:0]  regfile_wire_2;
  wire       [255:0]  regfile_wire_3;
  wire       [255:0]  regfile_wire_4;
  wire       [255:0]  regfile_wire_5;
  wire       [255:0]  regfile_wire_6;
  wire       [255:0]  regfile_wire_7;
  wire       [255:0]  regfile_wire_8;
  wire       [255:0]  regfile_wire_9;
  wire       [255:0]  regfile_wire_10;
  wire       [255:0]  regfile_wire_11;
  wire       [255:0]  regfile_wire_12;
  wire       [255:0]  regfile_wire_13;
  wire       [255:0]  regfile_wire_14;
  wire       [255:0]  regfile_wire_15;
//  wire       [255:0]  regfile_wire_16;
//  wire       [255:0]  regfile_wire_17;
//  wire       [255:0]  regfile_wire_18;
//  wire       [255:0]  regfile_wire_19;
//  wire       [255:0]  regfile_wire_20;
//  wire       [255:0]  regfile_wire_21;
//  wire       [255:0]  regfile_wire_22;
//  wire       [255:0]  regfile_wire_23;
//  wire       [255:0]  regfile_wire_24;
//  wire       [255:0]  regfile_wire_25;
//  wire       [255:0]  regfile_wire_26;
//  wire       [255:0]  regfile_wire_27;
//  wire       [255:0]  regfile_wire_28;
//  wire       [255:0]  regfile_wire_29;
//  wire       [255:0]  regfile_wire_30;
//  wire       [255:0]  regfile_wire_31;
  wire       [31:0]   _zz_1;

  always @(*) begin
    case(io_rd_index)
      5'b00000 : _zz_io_o_data = regfile_wire_0;
      5'b00001 : _zz_io_o_data = regfile_wire_1;
      5'b00010 : _zz_io_o_data = regfile_wire_2;
      5'b00011 : _zz_io_o_data = regfile_wire_3;
      5'b00100 : _zz_io_o_data = regfile_wire_4;
      5'b00101 : _zz_io_o_data = regfile_wire_5;
      5'b00110 : _zz_io_o_data = regfile_wire_6;
      5'b00111 : _zz_io_o_data = regfile_wire_7;
      5'b01000 : _zz_io_o_data = regfile_wire_8;
      5'b01001 : _zz_io_o_data = regfile_wire_9;
      5'b01010 : _zz_io_o_data = regfile_wire_10;
      5'b01011 : _zz_io_o_data = regfile_wire_11;
      5'b01100 : _zz_io_o_data = regfile_wire_12;
      5'b01101 : _zz_io_o_data = regfile_wire_13;
      5'b01110 : _zz_io_o_data = regfile_wire_14;
      5'b01111 : _zz_io_o_data = regfile_wire_15;
//      5'b10000 : _zz_io_o_data = regfile_wire_16;
//      5'b10001 : _zz_io_o_data = regfile_wire_17;
//      5'b10010 : _zz_io_o_data = regfile_wire_18;
//      5'b10011 : _zz_io_o_data = regfile_wire_19;
//      5'b10100 : _zz_io_o_data = regfile_wire_20;
//      5'b10101 : _zz_io_o_data = regfile_wire_21;
//      5'b10110 : _zz_io_o_data = regfile_wire_22;
//      5'b10111 : _zz_io_o_data = regfile_wire_23;
//      5'b11000 : _zz_io_o_data = regfile_wire_24;
//      5'b11001 : _zz_io_o_data = regfile_wire_25;
//      5'b11010 : _zz_io_o_data = regfile_wire_26;
//      5'b11011 : _zz_io_o_data = regfile_wire_27;
//      5'b11100 : _zz_io_o_data = regfile_wire_28;
//      5'b11101 : _zz_io_o_data = regfile_wire_29;
//      5'b11110 : _zz_io_o_data = regfile_wire_30;
//      default : _zz_io_o_data = regfile_wire_31;
      default : _zz_io_o_data = regfile_wire_0;
    endcase
  end

  assign regfile_wire_0 = regfile_0;
  assign regfile_wire_1 = regfile_1;
  assign regfile_wire_2 = regfile_2;
  assign regfile_wire_3 = regfile_3;
  assign regfile_wire_4 = regfile_4;
  assign regfile_wire_5 = regfile_5;
  assign regfile_wire_6 = regfile_6;
  assign regfile_wire_7 = regfile_7;
  assign regfile_wire_8 = regfile_8;
  assign regfile_wire_9 = regfile_9;
  assign regfile_wire_10 = regfile_10;
  assign regfile_wire_11 = regfile_11;
  assign regfile_wire_12 = regfile_12;
  assign regfile_wire_13 = regfile_13;
  assign regfile_wire_14 = regfile_14;
  assign regfile_wire_15 = regfile_15;
//  assign regfile_wire_16 = regfile_16;
//  assign regfile_wire_17 = regfile_17;
//  assign regfile_wire_18 = regfile_18;
//  assign regfile_wire_19 = regfile_19;
//  assign regfile_wire_20 = regfile_20;
//  assign regfile_wire_21 = regfile_21;
//  assign regfile_wire_22 = regfile_22;
//  assign regfile_wire_23 = regfile_23;
//  assign regfile_wire_24 = regfile_24;
//  assign regfile_wire_25 = regfile_25;
//  assign regfile_wire_26 = regfile_26;
//  assign regfile_wire_27 = regfile_27;
//  assign regfile_wire_28 = regfile_28;
//  assign regfile_wire_29 = regfile_29;
//  assign regfile_wire_30 = regfile_30;
//  assign regfile_wire_31 = regfile_31;
  assign io_o_data = _zz_io_o_data;
  assign _zz_1 = ({31'd0,1'b1} <<< io_wr_index);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      regfile_0 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_1 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_2 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_3 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_4 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_5 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_6 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_7 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_8 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_9 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_10 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_11 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_12 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_13 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_14 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      regfile_15 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_16 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_17 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_18 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_19 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_20 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_21 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_22 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_23 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_24 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_25 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_26 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_27 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_28 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_29 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_30 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//      regfile_31 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
    end else begin
      if(io_wr_valid) begin
        if(_zz_1[0]) begin
          regfile_0 <= io_i_data;
        end
        if(_zz_1[1]) begin
          regfile_1 <= io_i_data;
        end
        if(_zz_1[2]) begin
          regfile_2 <= io_i_data;
        end
        if(_zz_1[3]) begin
          regfile_3 <= io_i_data;
        end
        if(_zz_1[4]) begin
          regfile_4 <= io_i_data;
        end
        if(_zz_1[5]) begin
          regfile_5 <= io_i_data;
        end
        if(_zz_1[6]) begin
          regfile_6 <= io_i_data;
        end
        if(_zz_1[7]) begin
          regfile_7 <= io_i_data;
        end
        if(_zz_1[8]) begin
          regfile_8 <= io_i_data;
        end
        if(_zz_1[9]) begin
          regfile_9 <= io_i_data;
        end
        if(_zz_1[10]) begin
          regfile_10 <= io_i_data;
        end
        if(_zz_1[11]) begin
          regfile_11 <= io_i_data;
        end
        if(_zz_1[12]) begin
          regfile_12 <= io_i_data;
        end
        if(_zz_1[13]) begin
          regfile_13 <= io_i_data;
        end
        if(_zz_1[14]) begin
          regfile_14 <= io_i_data;
        end
        if(_zz_1[15]) begin
          regfile_15 <= io_i_data;
        end
//        if(_zz_1[16]) begin
//          regfile_16 <= io_i_data;
//        end
//        if(_zz_1[17]) begin
//          regfile_17 <= io_i_data;
//        end
//        if(_zz_1[18]) begin
//          regfile_18 <= io_i_data;
//        end
//        if(_zz_1[19]) begin
//          regfile_19 <= io_i_data;
//        end
//        if(_zz_1[20]) begin
//          regfile_20 <= io_i_data;
//        end
//        if(_zz_1[21]) begin
//          regfile_21 <= io_i_data;
//        end
//        if(_zz_1[22]) begin
//          regfile_22 <= io_i_data;
//        end
//        if(_zz_1[23]) begin
//          regfile_23 <= io_i_data;
//        end
//        if(_zz_1[24]) begin
//          regfile_24 <= io_i_data;
//        end
//        if(_zz_1[25]) begin
//          regfile_25 <= io_i_data;
//        end
//        if(_zz_1[26]) begin
//          regfile_26 <= io_i_data;
//        end
//        if(_zz_1[27]) begin
//          regfile_27 <= io_i_data;
//        end
//        if(_zz_1[28]) begin
//          regfile_28 <= io_i_data;
//        end
//        if(_zz_1[29]) begin
//          regfile_29 <= io_i_data;
//        end
//        if(_zz_1[30]) begin
//          regfile_30 <= io_i_data;
//        end
//        if(_zz_1[31]) begin
//          regfile_31 <= io_i_data;
//        end
      end
      else if (fin) begin
        regfile_0 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_1 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_2 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_3 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_4 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_5 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_6 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_7 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_8 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_9 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_10 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_11 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_12 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_13 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_14 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        regfile_15 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_16 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_17 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_18 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_19 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_20 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_21 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_22 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_23 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_24 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_25 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_26 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_27 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_28 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_29 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_30 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
//        regfile_31 <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
      end
    end
  end


endmodule
