`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.04.2026 18:16:26
// Design Name: 
// Module Name: seven_segment
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


module seven_segment #(
    parameter NUM_SEGMENTS = 8,
    parameter CLK_PER      = 10,
    parameter REFR_RATE    = 1000
) (
    input  wire                          clk,
    input  wire                          reset,
    input  wire  [NUM_SEGMENTS-1:0][3:0] encoded,
    input  wire  [NUM_SEGMENTS-1:0]      digit_point,
    output logic [NUM_SEGMENTS-1:0]      anode,
    output logic [             7:0]      cathode
);

  localparam INTERVAL = int'(100000000 / (CLK_PER * REFR_RATE));

  logic [    $clog2(INTERVAL)-1:0]      refresh_count;
  logic [$clog2(NUM_SEGMENTS)-1:0]      anode_count;
  logic [        NUM_SEGMENTS-1:0][7:0] segments;

  cathode_top ct[NUM_SEGMENTS] (
      .clk        (clk),
      .encoded    (encoded),
      .digit_point(digit_point),
      .cathode    (segments)
  );

  initial begin
    refresh_count = '0;
    anode_count   = '0;
  end

  always_ff @(posedge clk) begin
    if (refresh_count == INTERVAL) begin
      refresh_count <= '0;
      anode_count   <= anode_count + 1'b1;
    end else refresh_count <= refresh_count + 1'b1;
    anode              <= '1;
    anode[anode_count] <= '0;
    cathode            <= segments[anode_count];
    if (reset) begin
      refresh_count <= '0;
      anode_count   <= '0;
    end  // if
  end  // always_ff

endmodule
