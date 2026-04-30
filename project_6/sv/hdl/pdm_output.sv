`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 01:31:13
// Design Name: 
// Module Name: pdm_output
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


module pdm_output (
    input  wire        clk,
    input  logic [6:0] data_in,
    output logic       data_out
);

  logic [7:0] error;

  initial begin
    error    = '0;
    data_out = '0;
  end

  always_ff @(posedge clk) begin
    if (data_in >= error) begin
      data_out <= '1;
      error    <= error + 127 - data_in;
    end else begin
      data_out <= '0;
      error    <= error + 127 - data_in;
    end
  end  // always_ff

endmodule
