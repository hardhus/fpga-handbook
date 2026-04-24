`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2026 00:30:49
// Design Name: 
// Module Name: calculator_moore
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


module calculator_moore #(
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

  (* mark_debug = "true" *)logic [     4:0] op_store;
  (* mark_debug = "true" *)logic [     4:0] last_op;
  (* mark_debug = "true" *)logic [BITS-1:0] accumulator;

  typedef enum bit [2:0] {
    IDLE,
    WAIT4BUTTON,
    ADD,
    SUB,
    MULT,
    RESET_S
  } state_t;

  (* mark_debug = "true" *) state_t state;
  initial begin
    accumulator = '0;
    state       = IDLE;
  end

  always_ff @(posedge clk) begin
    case (state)
      IDLE: begin
        last_op <= buttons;
        if (start) state <= WAIT4BUTTON;
      end
      WAIT4BUTTON: begin
        case (1'b1)
          last_op[UP]:    state <= MULT;
          last_op[DOWN]:  state <= RESET_S;
          last_op[LEFT]:  state <= ADD;
          last_op[RIGHT]: state <= SUB;
          default:        state <= IDLE;
        endcase
      end
      MULT: begin
        accumulator <= accumulator * switch;
        state       <= IDLE;
      end
      ADD: begin
        accumulator <= accumulator + switch;
        state       <= IDLE;
      end
      SUB: begin
        accumulator <= accumulator - switch;
        state       <= IDLE;
      end
      RESET_S: begin
        accumulator <= '0;
        state       <= IDLE;
      end
    endcase
    if (reset) begin
      state       <= IDLE;
      accumulator <= '0;
    end  // if
  end  // always_ff

  assign accum = accumulator;

endmodule
