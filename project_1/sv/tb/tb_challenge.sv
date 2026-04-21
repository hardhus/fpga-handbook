`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 19:58:26
// Design Name: 
// Module Name: tb_challenge
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


module tb_challenge;

  logic [2:0] SW;
  logic [1:0] LED;

  challenge u_challenge (.*);

  initial begin
    $printtimescale(tb_challenge);
    SW = '0;
    for (int i = 0; i < 8; i++) begin
      $display("Setting switches to %3b", i[2:0]);
      SW = i[2:0];
      #100;
    end
    $display("PASS: logic_ex test PASSED!");
    $stop;
  end

  logic [2:0] sum;
  assign sum = SW[0] + SW[1] + SW[2];

  always @(SW) begin
    #1;
    if (sum !== LED) begin
      $display("FAIL: Addition mismatch");
      $stop;
    end
  end
endmodule
