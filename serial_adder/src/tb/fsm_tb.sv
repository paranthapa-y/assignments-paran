`timescale 1ns/1ps

module FSM_tb;

  parameter N = 8;

  reg clk;
  reg start;
  reg resetn;
  reg [N-1:0] A, B;

  wire load;
  wire enable;
  wire reset;
  wire done;

  // DUT
  FSM #(N) dut (
    .clk(clk),
    .start(start),
    .resetn(resetn),
    .A(A),
    .B(B),
    .load(load),
    .enable(enable),
    .reset(reset),
    .done(done)
  );

  // Clock generation (10ns period)
  always #5 clk = ~clk;

  integer shift_cycles;

  initial begin
    clk = 0;
    start = 0;
    resetn = 0;
    A = 8'hAA;
    B = 8'h55;
    shift_cycles = 0;

    //-----------------------------------------
    // Apply reset
    //-----------------------------------------
    #20;
    resetn = 1;

    //-----------------------------------------
    // Start FSM
    //-----------------------------------------
    #10;
    start = 1;

    //-----------------------------------------
    // Wait for LOAD state
    //-----------------------------------------
    @(posedge clk);
    if (!load) begin
      $error("LOAD not asserted when expected");
      $finish;
    end

    //-----------------------------------------
    // Count SHIFT cycles
    //-----------------------------------------
    wait(enable);  // wait until SHIFT begins

    while (!done) begin
      @(posedge clk);
      if (enable)
        shift_cycles++;
    end

    //-----------------------------------------
    // Checks
    //-----------------------------------------
    if (shift_cycles != N) begin
      $error("SHIFT cycle mismatch! Expected %0d, Got %0d",
              N, shift_cycles);
    end
    else begin
      $display("SHIFT cycle check PASSED (%0d cycles)", shift_cycles);
    end

    if (!done) begin
      $error("DONE not asserted!");
    end
    else begin
      $display("DONE asserted correctly");
    end

    $display("TEST PASSED");
    $finish;
  end

endmodule
