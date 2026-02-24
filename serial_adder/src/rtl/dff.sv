// ===============================================================
// D Flip-Flop (Positive Edge Triggered)
// ---------------------------------------------------------------
// Inputs:
//    clk   : Clock signal (data sampled on rising edge)
//    reset : Active-high synchronous reset
//    d     : Data input
//
// Output:
//    q     : Registered output

module d_ff (input clk,reset,d,output reg q);

  always @(posedge clk) begin // Sequential Logic
    if (reset) begin // active high reset
      q <= 0;
    end
    else begin // Store input data
      q <= d;
    end
  end
endmodule
