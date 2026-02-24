// ===============================================================
// SIPO (Serial-In Parallel-Out) Shift Register
// ---------------------------------------------------------------
// Parameter:
//    N  : Width of parallel output (final output is N+1 bits)
//
// Inputs:
//    clk     : Clock signal
//    reset   : Active-high synchronous reset
//    enable  : When high, shifting occurs
//    sum     : Serial input bit
//
// Output:
//    qo[N:0] : Parallel output data
`include "full_adder.sv" 
`include "fsm_design.sv" 
`include "dff.sv" 
module SIPO #(parameter N)(input clk, reset, enable, sum, output [N:0]qo);
  
  genvar i;

  wire [N:0]q; /// Internal registers to store shifted bits
  

    
  d_ff ff0 (.clk(clk),.reset(reset), .d(enable? sum : q[N]),.q(q[N])); // MSB flip-flop (serial input)
    // Shift chain
  generate
    for (i=0; i<N; i=i+1) begin : shift_chain
      d_ff ff (.clk(clk), .reset(reset), .d(enable? q[i+1]: q[i]), .q(q[i]));
    end
  endgenerate
  assign qo= q;
  
  
endmodule