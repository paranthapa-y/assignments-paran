`timescale 1ns/1ps
`include "top_module.sv"
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


    task run_test_x(input [N-1:0] a_in, input [N-1:0] b_in);
   begin
    resetn = 0;
    start  = 1;

    // IDLE -> IDLE
    repeat(2) @(posedge clk);

    // IDLE -> LOAD
    resetn = 1;
    start  = 0;
    @(posedge clk);

    // LOAD -> SHIFT
    @(posedge clk);

    // SHIFT -> SHIFT
    repeat(N-1) @(posedge clk);

    // SHIFT -> DONE
    @(posedge clk);

    // DONE -> DONE
    @(posedge clk);
end

  endtask

  task run_test_u(input [N-1:0] a_in, input [N-1:0] b_in , input start_1);
  begin
    A = a_in;
    B = b_in;
    #2;
    expected_sum = a_in + b_in+1;

    // Apply reset
    resetn = 0;
    start  = start_1;
    #50;
    @(posedge clk);
    @(posedge clk);
    resetn = 1;
    #10;
    // Start operation
    @(posedge clk);
    resetn = 0;
    #15;
    resetn = 1;
    repeat(5) @(posedge clk);
    @(posedge clk);
    resetn = 0;
    @(posedge clk);
    resetn = 1;
    
    // Wait until DONE
    wait(dut.done == 1);
    @(posedge clk);
    #2;
    // Check result
    if (SUM !== expected_sum) begin
      $error("FAILED: A=%0d B=%0d Expected=%0d Got=%0d",
              A, B, expected_sum, SUM);
    end
    else begin
      $display("PASS: A=%0d B=%0d SUM=%0d",
                A, B, SUM);
    end

    @(posedge clk);
  end
  endtask
//================================================================================================
  task run_test_s(input [N-1:0] a_in, input [N-1:0] b_in);
  begin
    A = a_in;
    B = b_in;
    #2;
    expected_sum = a_in + b_in;

    // Apply reset
    resetn = 0;
    start  = 0;
    @(posedge clk);
    @(posedge clk);
    resetn = 1;
    

    // Start operation
    @(posedge clk);
    
    resetn = 1;
    start = 0;
    #50;
    resetn = 0;
    start = 1;
    #50;
    resetn = 0;
    start = 0;
    #50;
    resetn = 1;
    start = 1;
    #50;


    // Wait until DON
    wait(dut.done == 1);
    @(posedge clk);
    #2;

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
//-------------------------------------------------------------------------------------------------------------------------------------------------------
  task run_test(input [N-1:0] a_in, input [N-1:0] b_in);
  begin
    A = a_in;
    B = b_in;
    #2;
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
    #50 start =1;
    resetn = 1;
    start = 0;
    #50;
    resetn = 0;
    start = 1;
    #50;
    resetn = 0;
    start = 0;
    #50;
    resetn = 1;
    start = 1;
    #50;


    // Wait until DON
    wait(dut.done == 1);
    @(posedge clk);
    #2;

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
    run_test_s(8'd9, 8'd0);
    run_test_s(8'd255, 8'd255);
    run_test_s(8'd255, 8'd1);   // overflow case
    run_test_s(8'd100, 8'd155);
    run_test_s(8'd9, 8'd0);
    run_test(8'd5, 8'd10);
    run_test(8'd255, 8'd1);   // overflow case
    run_test(8'd100, 8'd155);
    run_test_u(8'd100, 8'd155,1);
    run_test_x(8'd100, 8'd155);
    run_test_x(8'd255, 8'd255);
    run_test_u(8'd255, 8'd255,1);
    for (i = 0; i < 100; i++) begin
      run_test_u($urandom_range(0, 2**N-1),
               $urandom_range(0, 2**N-1),1);
    end

    //-------------------------------------------------
    // Random Tests
    //-------------------------------------------------
    for (i = 0; i < NUM_TESTS; i++) begin
      run_test($urandom_range(0, 2**N-1),
               $urandom_range(0, 2**N-1));
    end
    repeat (30) begin
        run_test($urandom_range(0, 50),
               $urandom_range(51, 80));
    end

    $display(" ALL TESTS COMPLETED ");

    $finish;
  end

endmodule
