// -----------------------------------------------------------------------------
// File: de_skew_tb.sv
// Description: Top-level SystemVerilog testbench for the de-skew module.
// Instantiates DUT and connects all testbench components.
// -----------------------------------------------------------------------------
// This testbench verifies the functionality of the de_skew module.
//
// The de_skew DUT aligns two 4-bit input streams (s1, s2)
// when a special alignment pattern (4'hA) appears within
// an allowed gap window.
//
// The testbench generates:
//
// 1. Positive test cases  -> Alignment should succeed
// 2. Negative test cases  -> Alignment should fail
//
// Randomized data is used to introduce variable skew
// between the two input streams.

module de_skew_tb;

  parameter N = 8; // Data width parameter (not used in this example)

  logic clk;              // Clock signal
  logic [3:0] s1,s2;      // Input streams
  logic [7:0] so;         // Output stream
  logic a,reset;          // Alignment flag and reset
 
  // Instantiate DUT (Device Under Test)
  de_skew dut (.i_clk(clk),.reset(reset), .i_stream1(s1), .i_stream2(s2), .o_stream(so), .o_aligned(a));

  // Generate clock with 20 time unit period
  always #10 clk = ~clk;

  // Task to send values to both input streams
  task send(input [3:0] v1, v2);
    @(posedge clk);
    s1 = v1;
    s2 = v2;
  endtask

  // Positive test case: alignment should succeed
  task positive_case();
	  int gap;
	  gap = $urandom_range(0,2);
	  send (4'hA,$urandom_range(0,9));
	  repeat(gap)
		  send ($urandom_range(0,15),$urandom_range(0,15));
	  send($urandom_range(0,15), 4'hA);
      repeat(10)
		  send ($urandom_range(0,15),$urandom_range(0,15));
  endtask
  // Another positive test case: alignment should succeed
  task positive_case2();
	  int gap;
	  gap = $urandom_range(0,2);
	  send ($urandom_range(0,9),4'hA);
	  repeat(gap)
		  send ($urandom_range(0,15),$urandom_range(0,15));
	  send(4'hA,$urandom_range(0,15));
      repeat(10)
		  send ($urandom_range(0,15),$urandom_range(0,15));
  endtask

  // Negative test case: alignment should fail (gap too large)
  task negative_case();
	  int gap;
	  gap = $urandom_range(3,5);
	  //send (4'hA,$urandom_range(0,15));
	  repeat(gap)
		  send ($urandom_range(0,15),$urandom_range(0,15));
	  send($urandom_range(0,15), 4'hA);
      repeat(10)
		  send ($urandom_range(0,15),$urandom_range(0,15));
  endtask
  // Negative test case variant
  task negative_case1();
	  int gap;
	  gap = $urandom_range(3,5);
	  send (4'hA,$urandom_range(0,15));
	  repeat(gap)
		  send ($urandom_range(0,15),$urandom_range(0,15));
	  send($urandom_range(0,15), 4'hA);
      repeat(10)
		  send ($urandom_range(0,15),$urandom_range(0,15));
  endtask
  // Negative test case variant
  task negative_case2();
	  int gap;
	  gap = $urandom_range(3,5);
	  send ($urandom_range(0,15), 4'hA);
	  repeat(gap)
		  send ($urandom_range(0,15),$urandom_range(0,15));
	  send($urandom_range(0,15), 4'hA);
      repeat(10)
		  send ($urandom_range(0,15),$urandom_range(0,15));
  endtask
  

  initial begin
    $dumpfile("test_bench.vcd"); // VCD waveform output
    $dumpvars;
    clk = 0;
    reset = 1;
    #100 reset = 0;
    @(posedge clk);
    // Run a sequence of positive and negative test cases
    positive_case();
    reset = 1;
    repeat(10) @(posedge clk);
    reset = 0;
    negative_case();
    reset = 1;
    #100 reset = 0;
    send(4'hA,4'hA); // Special case: both streams get alignment pattern
    negative_case();
    reset = 1;
    #100 reset = 0;
    @(posedge clk);
    positive_case2();
    reset = 1;
    #100 reset = 0;
    @(posedge clk);
    positive_case();
    reset = 1;
    #100 reset = 0;
    @(posedge clk);
    positive_case2();
    reset = 1;
    #100 reset = 0;
    @(posedge clk);
    positive_case();
    reset = 1;
    #100 reset = 0;
    send(4'hA,4'hA);
    negative_case();
    reset = 1;
    #100 reset = 0;
    positive_case();
    reset = 1;
    repeat(10) @(posedge clk);
    reset = 0;
    send(0,0); // Idle values
    negative_case1();
    reset = 1;
    send(0,0);
    repeat(10) @(posedge clk);
    reset = 0;
    negative_case2();
    reset = 1;
    send(0,0);
    repeat(10) @(posedge clk);
    reset = 0;
    negative_case1();
    reset = 1;
    repeat(10) @(posedge clk);
    reset = 0;
    negative_case2();
    $finish;
  end

endmodule
