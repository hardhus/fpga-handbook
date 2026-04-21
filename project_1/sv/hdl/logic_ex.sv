`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 16:45:12
// Design Name: 
// Module Name: logic_ex
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


module logic_ex (
    input  wire  [1:0] SW,
    output logic [3:0] LED
);
  assign LED[0] = !SW[0];
  assign LED[1] = SW[1] && SW[0];
  assign LED[2] = SW[1] || SW[0];
  assign LED[3] = SW[1] ^ SW[0];
endmodule
