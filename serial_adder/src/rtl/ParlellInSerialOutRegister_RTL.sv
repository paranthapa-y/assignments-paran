// ===============================================================
// PISO (Parallel-In Serial-Out) Shift Register
// ---------------------------------------------------------------
// Parameter:
//    N  : Width of parallel input
//
// Inputs:
//    clk    : Clock signal
//    reset  : Active-high synchronous reset
//    load   : When high, loads parallel data A into register
//    enable : When high, shifts data right by 1 bit
//    A[N-1:0] : Parallel input data
//
// Output:
//    q      : Serial output (LSB first)

`include "full_adder.sv" 
`include "fsm_design.sv" 
`include "dff.sv" 
module PISO #(parameter N)(input clk,reset, load, enable, [N-1:0] A, output q);
  
  genvar i;
  wire [N-1:0]temp; // Internal register wires (each driven by a D flip-flop)

    // MSB Flip-Flop
  d_ff ff_last (.clk(clk), .reset(reset), .d(load ? A[N-1] :(enable ? 1'b0 : temp[N-1])), .q(temp[N-1]));

    // Shift chain for remaining bits
  generate
    for (i=0; i<N-1; i=i+1) begin: dff_inst
      d_ff dff_i ( .clk(clk), .reset(reset), .d(load ? A[i]:(enable?temp[i+1] : temp[i])), .q(temp[i]));
    end
  endgenerate 

  // LSB of shift register
  assign q = (temp[0]&enable);
       
endmodule
