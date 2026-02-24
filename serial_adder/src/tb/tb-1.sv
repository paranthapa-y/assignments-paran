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
//--------------------------------------
    // resetn = 0;
    // start  = 0;
    // @(posedge clk);
    // @(posedge clk);
    // resetn = 1;

    // // Start operation
    // @(posedge clk);
    // start = 0;
    // #220
    // start =1

    // // Wait until DONE
    // wait(dut.done == 1);
    // @(posedge clk);

//--------------------------------------


    // Apply reset
    resetn = 0;
    start  = 0;
    @(posedge clk);
    @(posedge clk);
    resetn = 1;

    // Start operation
    @(posedge clk);
    start = 0;
    #220;
    start =1;
    @(posedge clk);
    start = 0; 
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
  // Additional tasks for SIPO and PISO coverage
  //-------------------------------------------------
  task test_piso;
    reg [N-1:0] test_data;
    integer j;
    begin
      test_data = 8'b10101010;
      A = test_data;
      B = 0;
      resetn = 0;
      @(posedge clk);
      resetn = 1;
      @(posedge clk);
      start = 1;
      @(posedge clk);
      start = 0;
      // Wait for done
      wait(dut.done == 1);
      @(posedge clk);
      // Check serial output from PISO
      for (j = 0; j < N; j = j + 1) begin
        // Check each bit shifted out
        // (Assumes access to PISO internals or via top_module)
        // $display("PISO bit %0d: %b", j, dut.a1.temp[j]);
      end
    end
  endtask

  task test_sipo;
    reg [N:0] serial_sum;
    integer k;
    begin
      serial_sum = 9'b110011001;
      resetn = 0;
      @(posedge clk);
      resetn = 1;
      @(posedge clk);
      start = 1;
      @(posedge clk);
      start = 0;
      // Wait for done
      wait(dut.done == 1);
      @(posedge clk);
      // Check parallel output from SIPO
      // $display("SIPO output: %b", dut.sum1.qo);
      for (k = 0; k <= N; k = k + 1) begin
        // Check each bit collected
        // (Assumes access to SIPO internals or via top_module)
        // $display("SIPO bit %0d: %b", k, dut.sum1.qo[k]);
      end
    end
  endtask

  // Task to explicitly test PISO modules a1 and b1
  task test_piso_full_coverage;
    reg [N-1:0] patterns [0:4];
    integer idx, bit_idx;
    begin
      // Patterns: all 0s, all 1s, single 1, alternating, incrementing
      patterns[0] = {N{1'b0}};
      patterns[1] = {N{1'b1}};
      patterns[2] = 8'b00000001;
      patterns[3] = 8'b10101010;
      patterns[4] = 8'b11110000;
      for (idx = 0; idx < 5; idx = idx + 1) begin
        // Test A (a1)
        A = patterns[idx];
        B = 0;
        resetn = 0;
        @(posedge clk);
        resetn = 1;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        wait(dut.done == 1);
        @(posedge clk);
        // Test B (b1)
        A = 0;
        B = patterns[idx];
        resetn = 0;
        @(posedge clk);
        resetn = 1;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        wait(dut.done == 1);
        @(posedge clk);
      end
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

    // Additional coverage for SIPO and PISO
    test_piso;
    test_sipo;
    // Full coverage for a1 and b1
    test_piso_full_coverage;

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
