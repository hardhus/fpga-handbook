`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2026 15:19:08
// Design Name: 
// Module Name: pdm_inputs
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


module pdm_inputs #(
    parameter  CLK_FREQ     = 100,                      // Mhz
    parameter  MCLK_FREQ    = 2500000,                  // Hz
    localparam SAMPLE_COUNT = 128,
    localparam SAMPLE_BITS  = $clog2(SAMPLE_COUNT + 1)
) (
    input  wire                    clk,
    // mic interface
    output logic                   m_clk,
    output logic                   m_clk_en,
    input  wire                    m_data,
    // mic end
    output logic [SAMPLE_BITS-1:0] amplitude,
    output logic                   amplitude_valid
);

  localparam CLK_COUNT = int'((CLK_FREQ * 1000000) / (MCLK_FREQ * 2));
  localparam WINDOW_SIZE = 200;
  localparam COUNTER1_OFFSET = WINDOW_SIZE / 2;
  localparam TERMINAL_COUNT0 = SAMPLE_COUNT;
  localparam TERMINAL_COUNT1 = SAMPLE_COUNT - COUNTER1_OFFSET;

  logic [$clog2(WINDOW_SIZE)-1:0]                  counter = '0;
  logic [                    1:0][SAMPLE_BITS-1:0] sample_counter = '0;
  logic [  $clog2(CLK_COUNT)-1:0]                  clk_counter = '0;

  initial begin
    sample_counter = '0;
    counter        = '0;
    m_clk          = '0;
    clk_counter    = '0;
  end

  always_ff @(posedge clk) begin
    amplitude_valid <= '0;
    m_clk_en        <= '0;

    if (clk_counter == CLK_COUNT - 1) begin
      clk_counter <= '0;
      m_clk       <= ~m_clk;
      m_clk_en    <= ~m_clk;
    end else begin
      clk_counter <= clk_counter + 1;
    end

    if (m_clk_en) begin
      if (counter < WINDOW_SIZE - 1) counter <= counter + 1'b1;
      else counter <= '0;

      if (counter == TERMINAL_COUNT0) begin
        amplitude         <= sample_counter[0];
        amplitude_valid   <= '1;
        sample_counter[0] <= '0;
      end else if (counter < TERMINAL_COUNT0) begin
        sample_counter[0] <= sample_counter[0] + m_data;
      end
      if (counter == TERMINAL_COUNT1) begin
        amplitude         <= sample_counter[1];
        amplitude_valid   <= '1;
        sample_counter[1] <= '0;
      end else if (counter < TERMINAL_COUNT1 || counter >= COUNTER1_OFFSET) begin
        sample_counter[1] <= sample_counter[1] + m_data;
      end
    end  // if 

  end  // always_ff
endmodule
