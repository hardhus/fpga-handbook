`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2026 00:41:22
// Design Name: 
// Module Name: calculator_mealy
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


module calculator_mealy #(
    parameter BITS = 32
) (
    input wire               clk,
    input wire               reset,
    input wire               start,
    input wire        [ 4:0] buttons,
    input wire signed [15:0] switch,

    output logic [BITS-1:0] accum
);

  import calculator_pkg::*;

  localparam BC = $clog2(BITS);

  (* mark_debug = "true" *)logic [     4:0] last_op;
  (* mark_debug = "true" *)logic [BITS-1:0] accumulator;

  typedef enum bit {
    IDLE,
    WAIT4BUTTON
  } state_t;

  (* mark_debug = "true" *) state_t state;
  initial begin
    accumulator = '0;
    state       = IDLE;
  end

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        last_op <= buttons;
        if (start) state <= WAIT4BUTTON;
      end
      WAIT4BUTTON: begin
        state <= IDLE;
        case (1'b1)
          last_op[UP]:    accumulator <= accumulator * switch;
          last_op[DOWN]:  accumulator <= '0;
          last_op[LEFT]:  accumulator <= accumulator + switch;
          last_op[RIGHT]: accumulator <= accumulator - switch;
        endcase
      end
    endcase
    if (reset) begin
      state       <= IDLE;
      accumulator <= '0;
    end
  end

  assign accum = accumulator;

endmodule
