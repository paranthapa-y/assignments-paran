// -----------------------------------------------------------------------------
// File: testbench.sv
// Description: Testbench environment setup for de-skew verification.
// Includes instantiation and connection of UVM-like components.
// -----------------------------------------------------------------------------
`include "interfaces.sv"
`include "transaction.sv"
`include "generator.sv"
`include "scoreboard.sv"
`include "monitor.sv"
`include "driver.sv"
`include "environment.sv"


module tb;
  logic clk;
  // Generate clock with 10 time unit period
  always #5 clk = ~clk;
  
  des_if vif(clk); // Instantiate interface
  // Instantiate DUT and connect to interface
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
    $dumpfile("test_bench.vcd"); // VCD waveform output
    $dumpvars;
    clk = 0;
    vif.reset = 1;
    #20 vif.reset = 0;
    env = new(vif); // Create environment
    env.run();      // Start environment
    // Optionally, you can force reset after a certain time:
    // wait($time >= 1000) vif.reset = 1;
    // #50 vif.reset = 0;
    #1000;
    $finish;
  end
  // Reset logic: assert reset if alignment detected
  always @(posedge clk) begin
    if (vif.o_aligned == 1) begin
      #50;
      vif.reset <= 1;
    end else
      vif.reset <= 0;
  end
endmodule
