`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 01:56:22
// Design Name: 
// Module Name: pwm_outputs
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


module pwm_outputs #(
    parameter  CLK_FREQ     = 100,
    parameter  RAM_SIZE     = 16384,
    localparam SAMPLE_COUNT = 128,
    localparam INPUT_FREQ   = 24000,
    localparam SAMPLE_BITS  = $clog2(SAMPLE_COUNT + 1)
) (
    input wire clk,

    input  wire                         start_playback,
    output logic [$clog2(RAM_SIZE)-1:0] ram_rdaddr,
    input  wire  [     SAMPLE_BITS-1:0] ram_sample,

    // amplitude outputs
    output logic        AUD_PWM_en,
    // LED clearing
    output logic [15:0] clr_led = '0
);

  localparam CLK_COUNT = int'((CLK_FREQ * 1000000) / (INPUT_FREQ * SAMPLE_COUNT));

  logic [$clog2(CLK_COUNT)-1:0] clk_counter;
  logic [      SAMPLE_BITS-1:0] sample_counter;
  logic                         sample_valid;
  logic                         playback;
  (*mark_debug = "true" *)logic [                  2:0] start_sync;
  logic [                  3:0] clr_addr;
  logic [      SAMPLE_BITS-1:0] amp_capture;

  assign clr_addr = ~ram_rdaddr[$clog2(RAM_SIZE)-1:$clog2(RAM_SIZE)-4];

  initial begin
    clk_counter = '0;
  end

  always_ff @(posedge clk) begin
    clr_led      <= '0;
    start_sync   <= start_sync << 1 | start_playback;
    sample_valid <= '0;
    if (clk_counter == CLK_COUNT - 1) begin
      sample_valid <= '1;
      clk_counter  <= '0;
    end else begin
      clk_counter <= clk_counter + 1;
    end

    if (start_sync[2:1] == 2'b01) begin
      playback       <= '1;
      ram_rdaddr     <= '0;
      sample_counter <= '0;
      amp_capture    <= '0;
    end else if (playback && sample_valid) begin
      clr_led[clr_addr] <= '1;
      AUD_PWM_en        <= '1;
      sample_counter    <= sample_counter + 1'b1;
      if (sample_counter < amp_capture) AUD_PWM_en <= '0;
      if (sample_counter == 0) begin
        ram_rdaddr <= ram_rdaddr + 1'b1;
        if (ram_sample > 0) AUD_PWM_en <= '0;
        amp_capture <= ram_sample;
      end else if (sample_counter == SAMPLE_COUNT - 1) begin
        sample_counter <= '0;
        if (ram_rdaddr == RAM_SIZE - 1) begin
          playback   <= '0;
          ram_rdaddr <= '0;
        end
      end
    end


  end  // always_ff

endmodule
