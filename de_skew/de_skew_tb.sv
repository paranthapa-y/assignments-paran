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

  parameter N = 8;

  logic clk;
  logic [3:0] s1,s2;
  logic [7:0] so;
  logic a,reset;
 
  de_skew dut (.i_clk(clk),.reset(reset), .i_stream1(s1), .i_stream2(s2), .o_stream(so), .o_aligned(a));

  always #10 clk = ~clk;

  task send(input [3:0] v1, v2); //task to send the values to streams
	  @(posedge clk);
	  s1 = v1;
	  s2 = v2;
  endtask

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
    $dumpfile("test_bench.vcd");
    $dumpvars;
    clk = 0;
    reset =1;
    #100 reset =0;
    @(posedge clk);
    positive_case();
    reset =1;
    repeat(10) @(posedge clk);
    reset =0;
    negative_case();
    reset = 1;
    #100 reset = 0;
    send(4'hA,4'hA);
    negative_case();
    reset =1;
    #100 reset =0;
    @(posedge clk);
    positive_case2();
    reset =1;
    #100 reset =0;
    @(posedge clk);
    positive_case();
    reset =1;
    #100 reset =0;
    @(posedge clk);
    positive_case2();
    reset =1;
    #100 reset =0;
    @(posedge clk);
    positive_case();
    reset = 1;
    #100 reset = 0;
    send(4'hA,4'hA);
    negative_case();
    reset = 1;
    #100 reset = 0;
    positive_case();
    reset =1;
    repeat(10) @(posedge clk);
    reset =0;
    send(0,0);
    negative_case1();
    reset =1;
    send(0,0);
    repeat(10) @(posedge clk);
    reset =0;
    negative_case2();
    reset =1;
    send(0,0);
    repeat(10) @(posedge clk);
    reset =0;
    negative_case1();
    reset =1;
    repeat(10) @(posedge clk);
    reset =0;
    negative_case2();


    $finish;
  end

endmodule
