`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2026 18:40:04
// Design Name: 
// Module Name: project_2
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


module project_2 #(
    parameter SELECTOR,
    parameter BITS     = 16
) (
    input wire [BITS-1:0] SW,
    input wire            BTNC,
    input wire            BTNU,
    input wire            BTNL,
    input wire            BTNR,
    input wire            BTND,

    output logic signed [BITS-1:0] LED
);

  logic [$clog2(BITS):0] LO_LED;
  logic [$clog2(BITS):0] NO_LED;
  logic [      BITS-1:0] AD_LED;
  logic [      BITS-1:0] SB_LED;
  logic [      BITS-1:0] MULT_LED;

  leading_ones #(
      .SELECTOR(SELECTOR),
      .BITS    (BITS)
  ) u_lo (
      .SW (SW),
      .LED(LO_LED)
  );
  add_sub #(
      .SELECTOR("ADD"),
      .BITS    (BITS)
  ) u_ad (
      .SW (SW),
      .LED(AD_LED)
  );
  add_sub #(
      .SELECTOR("SUB"),
      .BITS    (BITS)
  ) u_sb (
      .SW (SW),
      .LED(SB_LED)
  );
  num_ones #(
      .BITS(BITS)
  ) u_no (
      .SW (SW),
      .LED(NO_LED)
  );
  mult #(
      .BITS(BITS)
  ) u_mt (
      .SW (SW),
      .LED(MULT_LED)
  );

  always_comb begin
    LED = '0;
    case (1'b1)
      BTNC: LED = MULT_LED;
      BTNU: LED = LO_LED;
      BTND: LED = NO_LED;
      BTNL: LED = AD_LED;
      BTNR: LED = SB_LED;
      default: LED = '0;
    endcase
  end  // always_comb

endmodule
