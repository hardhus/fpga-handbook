`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06.05.2026 21:55:17
// Design Name:
// Module Name: i2c_temp_flt
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module flt_temp #(
    parameter SMOOTHING    = 16,
    parameter NUM_SEGMENTS = 8
) (
    input  wire                       clk,
    input  wire                       rst,
    // switch interface
    input  wire  [               1:0] SW,
    // LED interface
    output logic [               1:0] LED,
    // data from fix to float
    input  wire                       fix_temp_tvalid,
    input  wire  [              31:0] fix_temp_tdata,
    // addsub interface
    output logic                      addsub_a_tvalid,
    output logic [              31:0] addsub_a_tdata,
    output logic                      addsub_b_tvalid,
    output logic [              31:0] addsub_b_tdata,
    output logic                      addsub_op_tvalid,
    output logic [               7:0] addsub_op_tdata,
    input  wire                       addsub_tvalid,
    input  wire  [              31:0] addsub_tdata,
    // multiplier interface
    output logic                      mult_a_tvalid,
    output logic [              31:0] mult_a_tdata,
    output logic                      mult_b_tvalid,
    output logic [              31:0] mult_b_tdata,
    input  wire                       mult_tvalid,
    input  wire  [              31:0] mult_tdata,
    // fused multiplier-add interface
    output logic                      fused_a_tvalid,
    output logic [              31:0] fused_a_tdata,
    output logic                      fused_b_tvalid,
    output logic [              31:0] fused_b_tdata,
    output logic                      fused_c_tvalid,
    output logic [              31:0] fused_c_tdata,
    input  wire                       fused_tvalid,
    input  wire  [              31:0] fused_tdata,
    // float to fixed
    output logic                      fp_temp_tvalid,
    output logic [              31:0] fp_temp_tdata,
    input  wire                       fx_temp_tvalid,
    input  wire  [              15:0] fx_temp_tdata,
    // 7 segment display
    output logic                      seven_segment_tvalid,
    output logic [NUM_SEGMENTS*4-1:0] seven_segment_tdata,
    output logic [  NUM_SEGMENTS-1:0] seven_segment_tuser
);

  assign LED = SW;

  import temp_pkg::*;

  logic        [NUM_SEGMENTS-1:0][3:0] encoded;
  logic        [NUM_SEGMENTS-1:0][3:0] encoded_int;
  logic        [NUM_SEGMENTS-1:0][3:0] encoded_frac;
  logic        [NUM_SEGMENTS-1:0]      digit_point;
  // TEMP (* mark_debug = "true" *)logic                                     capture_en;

  logic signed [            15:0]      smooth_data;
  logic                                smooth_convert;
  logic        [             4:0]      sample_count;

  // TEMP localparam NINE_FIFTHS = 17'b1_11001100_11001100;
  typedef struct packed {
    bit sign;
    bit [7:0] exponent;
    bit [22:0] mantissa;
  } float_t;
  typedef union packed {
    float_t      fp;
    logic [31:0] raw;
  } float_u;

  localparam SMOOTHING_SHIFT = $clog2(SMOOTHING);
  logic     [SMOOTHING_SHIFT:0] smooth_count;
  (* mark_debug = "true" *)logic     [             31:0] dout;
  (* mark_debug = "true" *)logic                         rden;
  (* mark_debug = "true" *)float_u                       accumulator;  // 0.0 FP
  (* mark_debug = "true" *)float_u                       result_data;
  (* mark_debug = "true" *)logic                         result_valid;
  (* mark_debug = "true" *)float_u                       temperature;
  (* mark_debug = "true" *)logic                         temperature_valid;
  (* mark_debug = "true" *)logic     [              2:0] convert_pipe;
  logic     [             31:0] divide                                                    [17];

  const bit [             31:0] nine_fifths = 32'h3fe66666;  // 9/5 in FP
  const bit [             31:0] thirty_two = 32'h42000000;  // Floating point
  const bit [             31:0] kelvin_offset = 32'h43889333;  // 273.15 in Floating Point

  logic     [             31:0] mult_in                                                   [ 2];
  logic                         mult_in_valid;

  // TEMP logic     [             31:0] fused_data;
  // TEMP logic                         fused_valid;

  initial begin
    rden         = '0;
    smooth_count = '0;
    accumulator  = '0;
    sample_count = '0;
    divide[0]    = 32'h3F800000;  // 1
    divide[1]    = 32'h3F000000;  // 1/2
    divide[2]    = 32'h3eaaaaab;  // 1/3
    divide[3]    = 32'h3e800000;  // 1/4
    divide[4]    = 32'h3e4ccccd;  // 1/5
    divide[5]    = 32'h3e2aaaab;  // 1/6
    divide[6]    = 32'h3e124924;  // 1/7
    divide[7]    = 32'h3e000000;  // 1/8
    divide[8]    = 32'h3de38e39;  // 1/9
    divide[9]    = 32'h3dcccccd;  // 1/10
    divide[10]   = 32'h3dba2e8c;  // 1/11
    divide[11]   = 32'h3daaaaab;  // 1/12
    divide[12]   = 32'h3d9d89d9;  // 1/13
    divide[13]   = 32'h3d924925;  // 1/14
    divide[14]   = 32'h3d888888;  // 1/15
    divide[15]   = 32'h3d800000;  // 1/16
    divide[16]   = 32'h3d800000;  // 1/16
  end

  // TEMP logic        s_axis_a_tready;
  // TEMP logic accum_valid;

  logic [31:0] addsub_in[2];
  logic [31:0] fma_b;
  logic [31:0] fma_c;

  always_comb begin
    if (SW == 2'b10) begin
      fma_b = 32'h3F800000;  // 1.0
      fma_c = kelvin_offset;  // 273.15
    end else begin
      fma_b = nine_fifths;  // 1.8
      fma_c = thirty_two;  // 32.0
    end
  end  // always_comb

  // AXI
  assign addsub_a_tvalid  = convert_pipe[0];
  assign addsub_a_tdata   = addsub_in[0];
  assign addsub_b_tvalid  = convert_pipe[0];
  assign addsub_b_tdata   = addsub_in[1];
  assign addsub_op_tvalid = convert_pipe[0];

  assign mult_a_tvalid    = mult_in_valid;
  assign mult_a_tdata     = mult_in[0];
  assign mult_b_tvalid    = mult_in_valid;
  assign mult_b_tdata     = mult_in[1];
  assign result_valid     = mult_tvalid;
  assign result_data.raw  = mult_tdata;

  assign fp_temp_tvalid   = temperature_valid;
  assign fp_temp_tdata    = temperature.raw;
  assign smooth_convert   = fx_temp_tvalid;
  assign smooth_data      = fx_temp_tdata;

  assign fused_a_tvalid   = result_valid;
  assign fused_a_tdata    = result_data.raw;
  assign fused_b_tvalid   = result_valid;
  assign fused_b_tdata    = fma_b;
  assign fused_c_tvalid   = result_valid;
  assign fused_c_tdata    = fma_c;




  always @(posedge clk) begin
    rden              <= '0;
    convert_pipe      <= '0;
    temperature_valid <= '0;
    mult_in_valid     <= '0;

    if (fix_temp_tvalid) begin
      addsub_op_tdata <= '0;  // add
      convert_pipe[0] <= '1;
      addsub_in[0]    <= accumulator.raw;
      addsub_in[1]    <= fix_temp_tdata;
    end  // if
    if (addsub_tvalid) begin
      accumulator.raw <= addsub_tdata;
      if (~|addsub_op_tdata) begin
        convert_pipe[1] <= '1;
        rden            <= '1;
      end else begin
        convert_pipe[2] <= '1;
      end
    end  // if
    if (convert_pipe[1]) begin
      addsub_op_tdata <= 8'b1;  // subtract
      convert_pipe[0] <= '1;
      addsub_in[0]    <= accumulator.raw;
      addsub_in[1]    <= (smooth_count == SMOOTHING) ? dout : '0;
    end  // if
    if (convert_pipe[2]) begin
      if (~sample_count[4]) sample_count <= sample_count + 1'b1;
      if (smooth_count != SMOOTHING) smooth_count <= smooth_count + 1'b1;
      mult_in[0]    <= accumulator.raw;
      mult_in[1]    <= divide[smooth_count];
      mult_in_valid <= '1;
    end
    if (result_valid) begin
      temperature.fp    <= result_data.fp;
      temperature_valid <= (SW == 2'b00);
    end
    if ((SW != 2'b00) && fused_tvalid) begin
      temperature.raw   <= fused_tdata;
      temperature_valid <= '1;
    end
    if (rst) begin
      rden         <= '0;
      smooth_count <= '0;
      accumulator  <= '0;
      sample_count <= '0;
    end
  end

  xpm_fifo_sync #(
      .FIFO_WRITE_DEPTH(SMOOTHING * 2),
      .WRITE_DATA_WIDTH($bits(fix_temp_tdata)),
      .READ_MODE       ("fwft")
  ) u_xpm_fifo_sync (
      .sleep('0),
      .rst  ('0),

      .wr_clk       (clk),
      .wr_en        (fix_temp_tvalid),
      .din          (fix_temp_tdata),
      .full         (),
      .prog_full    (),
      .wr_data_count(),
      .overflow     (),
      .wr_rst_busy  (),
      .almost_full  (),
      .wr_ack       (),

      .rd_en        (rden),
      .dout         (dout),
      .empty        (),
      .prog_empty   (),
      .rd_data_count(),
      .underflow    (),
      .rd_rst_busy  (),
      .almost_empty (),
      .data_valid   (),

      .injectsbiterr('0),
      .injectdbiterr('0),
      .sbiterr      (),
      .dbiterr      ()
  );


  logic [ 3:0][3:0] fraction;
  logic [15:0]      fraction_table[16];

  initial begin
    for (int i = 0; i < 16; i++) fraction_table[i] = i * 625;
  end

  logic [3:0] sym_degree;
  logic [3:0] sym_unit;

  always_comb begin
    case (SW)
      2'b00: begin
        sym_degree = 4'hA;
        sym_unit   = 4'hC;
      end  // °C
      2'b01: begin
        sym_degree = 4'hA;
        sym_unit   = 4'hF;
      end  // °F
      2'b10: begin
        sym_degree = 4'hE;
        sym_unit   = 4'hB;
      end  // [Blank] H (Kelvin)
      default: begin
        sym_degree = 4'hE;
        sym_unit   = 4'hE;
      end  // [Blank] [Blank]
    endcase
  end  // always_comb

  // convert temperature from
  always @(posedge clk) begin
    seven_segment_tvalid <= '0;
    digit_point          <= 8'b00010000;
    if (smooth_convert) begin
      seven_segment_tvalid <= '1;
      if (smooth_data < 0) begin
        encoded_int <= '0;
        fraction    <= '0;
      end else begin
        encoded_int <= bin_to_bcd(smooth_data[12:4]);  // Decimal portion
        fraction    <= bin_to_bcd(fraction_table[smooth_data[3:0]]);
      end
    end
  end  // always @ (posedge clk)

  // Final mapping: Left to right display arrangement
  assign encoded = {
    4'h0,  // Anode 7 (Leftmost): Solid 0 as requested
    encoded_int[2],  // Anode 6: Hundreds digit (Displays 0 for C/F, 2 for Kelvin)
    encoded_int[1],  // Anode 5: Tens digit
    encoded_int[0],  // Anode 4: Units digit (Decimal point is here)
    fraction[3],  // Anode 3: Tenths digit
    fraction[2],  // Anode 2: Hundredths digit
    sym_degree,  // Anode 1: Degree symbol (°) or Blank for K
    sym_unit  // Anode 0 (Rightmost): Unit identifier (C, F, or H)
  };

  assign seven_segment_tdata = encoded;
  assign seven_segment_tuser = digit_point;

endmodule
