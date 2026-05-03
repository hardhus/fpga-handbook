`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 01:13:42
// Design Name: 
// Module Name: adt7420_mdl
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


module adt7420_mdl #(
    parameter I2C_ADDR = 7'h4B
) (
    input wire [15:0] temp,  // the temperature to read out

    input wire scl,
    inout      sda
);

  logic [6:0] addr;
  logic       rnw;
  logic sda_int, sda_en;
  logic   sda_in;
  integer ptr;

  assign sda_in = sda;
  assign sda    = sda_en ? sda_int : 'z;
  initial begin
    do begin
      ptr    = $bits(addr) - 1;
      sda_en = '0;

      // Wait for START condition
      wait (scl === 1);
      @(negedge sda_in);

      // Receive device address
      do begin
        @(posedge scl);
        addr[ptr--] = sda;
      end while (ptr >= 0);

      $display("addr = %h", addr);
      assert (addr == I2C_ADDR)
      else $fatal("unexpected I2C address: %h", addr);

      // Receive R/W flag
      @(posedge scl);
      rnw = sda;
      assert (rnw == 1)
      else $fatal("unexpected RNW");

      ptr = $bits(temp) - 1;

      // Transmit slave ACK
      @(negedge scl);
      sda_int = '0;
      sda_en  = '1;

      // Transmit TEMP high byte
      do begin
        @(negedge scl);
        sda_en  = temp[ptr] !== 1;
        sda_int = temp[ptr--] ? 'z : '0;  // We have a pull up on the board
      end while (ptr >= 8);

      // Receive master ACK
      @(negedge scl);
      sda_en = '0;
      @(posedge scl);
      assert (sda == '0)
      else $fatal("expected ACK by master");

      // Transmit TEMP low byte
      do begin
        @(negedge scl);
        sda_en  = temp[ptr] !== 1;
        sda_int = temp[ptr--] ? 'z : '0;  // We have a pull up on the board
      end while (ptr >= 0);

      // Receive master NO ACK
      @(negedge scl);
      sda_en = '0;
      @(negedge scl);
      assert (sda == '1)
      else $fatal("expected NO ACK by master");
    end while (1);
  end  // initial begin
endmodule  // adt7420_mdl
