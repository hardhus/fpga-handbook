`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2026 18:46:36
// Design Name: 
// Module Name: num_ones
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


module num_ones #(
    parameter int BITS = 16
) (
    input  wire  [      BITS-1:0] SW,
    output logic [$clog2(BITS):0] LED
);

  always_comb begin
    LED = '0;
    for (int i = $low(SW); i <= $high(SW); i++) begin
      LED += SW[i];
    end  // for
  end  // always_comb
endmodule
