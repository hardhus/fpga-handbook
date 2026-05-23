`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 00:12:03
// Design Name: 
// Module Name: temp_pkg
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


`ifndef _TEMP_PKG
`define _TEMP_PKG

package temp_pkg;

  localparam NUM_SEGMENTS = 8;

  function bit [NUM_SEGMENTS-1:0][3:0] bin_to_bcd;
    input [31:0] bin_in;
    bit [NUM_SEGMENTS*4-1:0] shifted;
    shifted = {30'b0, bin_in[31:30]};
    for (int i = 29; i >= 1; i--) begin
      shifted = shifted << 1 | bin_in[i];
      for (int j = 0; j < 8; j++) begin
        if (shifted[j*4+:4] > 4) shifted[j*4+:4] += 3;
      end  // for
    end  // for
    shifted = shifted << 1 | bin_in[0];
    for (int i = 0; i < NUM_SEGMENTS; i++) begin
      bin_to_bcd[i] = shifted[4*i+:4];
    end  // for
  endfunction

endpackage

`endif
