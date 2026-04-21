`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 19:56:36
// Design Name: 
// Module Name: challenge
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


module challenge (
    input  wire  [2:0] SW,
    output logic [1:0] LED
);

  // SW[2] is carry in
  // SW[1] is A
  // SW[0] is B
  assign LED[0] = SW[1] ^ SW[0] ^ SW[2];  // Write the code for the Sum
  assign LED[1] = SW[1] & SW[0] | (SW[1] ^ SW[0]) & SW[2];  // Write the code for the Carry
endmodule
