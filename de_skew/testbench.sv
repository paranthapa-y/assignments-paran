`include "interfaces.sv"
`include "transaction.sv"
`include "generator.sv"
`include "scoreboard.sv"
`include "monitor.sv"
`include "driver.sv"
`include "environment.sv"


module tb;
  logic clk;
  always #5 clk = ~clk;
  
  des_if vif(clk);
  de_skew dut (
        .i_clk(clk),
    .reset(vif.reset),
    .i_stream1(vif.stream1),
    .i_stream2(vif.stream2),
    .o_stream(vif.o_stream),
    .o_aligned(vif.o_aligned)
  );
  
  Environment env;
  initial begin
    $dumpfile("test_bench.vcd");
    $dumpvars;
    
    clk = 0;
    vif.reset =1;
    
    #20 vif.reset = 0;
    
    env =new(vif);
    
    env.run();
    // wait($time >= 1000) vif.reset =1;
    // #50 vif.reset =0;
    
    
    #1000;
    $finish;
  end
  always @(posedge clk) begin
	  if (vif.o_aligned == 1) begin
		  #50;
		  vif.reset <=1;
	  end
	  else
		  vif.reset<=0;
  end
endmodule
