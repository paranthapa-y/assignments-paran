`timescale 1ns/1ps

module top_module_tb;

  parameter N = 8;
  parameter NUM_TESTS = 20;

  reg clk;
  reg start;
  reg resetn;
  reg [N-1:0] A, B;

  wire [N:0] SUM;

  integer i;
  reg [N:0] expected_sum;

  // Instantiate DUT
  top_module #(N) dut (
    .clk(clk),
    .start(start),
    .resetn(resetn),
    .A(A),
    .B(B),
    .SUM(SUM)
  );

  // Clock generation (10ns period)
  always #5 clk = ~clk; 

  //-------------------------------------------------
  // Task: Run One Test
  //-------------------------------------------------
  task run_test(input [N-1:0] a_in, input [N-1:0] b_in);
  begin
    A = a_in;
    B = b_in;
    expected_sum = a_in + b_in;

    // Apply reset
    resetn = 0;
    start  = 0;
    @(posedge clk);
    @(posedge clk);
    resetn = 1;

    // Start operation
    @(posedge clk);
    start = 1;

    // Wait until DONE
    wait(dut.done == 1);
    @(posedge clk);

    // Check result
    if (SUM !== expected_sum) begin
      $error("FAILED: A=%0d B=%0d Expected=%0d Got=%0d",
              A, B, expected_sum, SUM);
    end
    else begin
      $display("PASS: A=%0d B=%0d SUM=%0d",
                A, B, SUM);
    end

    start = 0;
    @(posedge clk);
  end
  endtask

  //-------------------------------------------------
  // Test Sequence
  //-------------------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    clk = 0;

    //-------------------------------------------------
    // Directed Tests
    //-------------------------------------------------
    run_test(8'd9, 8'd0);
    run_test(8'd5, 8'd10);
    run_test(8'd255, 8'd1);   // overflow case
    run_test(8'd100, 8'd155);

    //-------------------------------------------------
    // Random Tests
    //-------------------------------------------------
    for (i = 0; i < NUM_TESTS; i++) begin
      run_test($urandom_range(0, 2**N-1),
               $urandom_range(0, 2**N-1));
    end

    $display(" ALL TESTS COMPLETED ");

    $finish;
  end

endmodule
