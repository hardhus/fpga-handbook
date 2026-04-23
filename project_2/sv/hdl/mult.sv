`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2026 18:46:15
// Design Name: 
// Module Name: mult
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


module mult #(
    parameter int BITS = 16
) (
    input  wire         [BITS-1:0] SW,
    output logic signed [BITS-1:0] LED
);

  logic signed [BITS/2-1:0] a_in;
  logic signed [BITS/2-1:0] b_in;

  always_comb begin
    {a_in, b_in} = SW;
    LED          = a_in * b_in;
  end
endmodule
