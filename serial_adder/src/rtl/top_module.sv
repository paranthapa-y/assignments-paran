// ===========================================================
// Top module for N-bit Serial Adder
// Instantiates the following modules:
//   1. FSM       : Controls the sequence of operations
//   2. PISO (A)  : Serializes input A
//   3. PISO (B)  : Serializes input B
//   4. Full Adder: Adds the serial bits of A and B
//   5. D Flip-Flop: Holds carry between additions
//   6. SIPO      : Collects serial sum into N-bit output
// 
// The module returns SUM[N:0], valid when done=1
// ===========================================================


`include "SerialInParllelOutRegister_RTL.sv" // Includes module definitions: d_ff, full_adder, SIPO, PISO
`include "ParlellInSerialOutRegister_RTL.sv" 
`include "full_adder.sv" 
`include "fsm_design.sv" 
`include "dff.sv" 
// `include "package.sv" 

module top_module #(parameter N=8) (input clk,start,resetn,[N-1:0]A, [N-1:0]B, output [N:0]SUM );

  

  wire load, enable, reset;          // Control signals from FSM
  wire done;                         // Indicates addition complete
  wire a_out, b_out;        // Serial outputs from PISO modules
  wire f_s;                          // Single-bit sum from full adder
  wire d, ff_q;                      // Carry out from full adder and stored in flip-flop
  wire [N:0] sum_out;                // Collected sum from SIPO
 
  assign SUM = done? sum_out: 0; // SUM is valid only after FSM signals done

    // Instantiate FSM
  FSM #(N) fsm (.clk(clk), .start(start), .resetn(resetn), .load(load), .enable(enable), .reset(reset), .done(done));
  
  // Instantiate PISO modules for serializing inputs
  PISO #(N) a1 ( .clk(clk), .reset(reset), .load(load), .enable(enable), .A(A), .q(a_out));
  
  PISO #(N) b1 ( .clk(clk),.reset(reset), .load(load), .enable(enable), .A(B), .q(b_out));
  
  // Instantiate Full Adder
  full_adder  fa(.a(a_out), .b(b_out), .cin(ff_q) , .sum(f_s), .c_out(d));
  
  // Carry Flip-Flop
  d_ff ff0 (.clk(clk),.reset(reset), .d(d),.q(ff_q));
  
  // SIPO module
  // Collects serial sum (f_s) and outputs as sum_out[N:0]
  SIPO #(N) sum1 (.clk(clk), .reset(reset), .enable(enable), .sum(f_s), .qo(sum_out));
  
  
  
endmodule
