// -----------------------------------------------------------------------------
// File: interfaces.sv
// Description: Interface definitions for de-skew testbench. Connects DUT and testbench components.
// -----------------------------------------------------------------------------


interface des_if (input logic clk);
  
  logic reset;
  logic [3:0] stream1;
  logic [3:0] stream2;
  
  logic [7:0] o_stream;
  logic o_aligned;

    property skew_check1;
	  @(posedge clk) disable iff(reset)
	  (stream1 == 4'hA && !o_aligned) |-> ##[0:2] (stream2 == 4'hA)
	  or
          (stream2 == 4'hA && !o_aligned) |-> ##[0:2] (stream1 == 4'hA);
  endproperty

  assert property(skew_check1);
  
endinterface