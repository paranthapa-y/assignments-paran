module SIPO_tb;

  parameter N = 8;

  logic clk;
  logic reset;
  logic enable;
  logic sum;
  logic [N:0] qo;

  logic [N:0] expected_q;
  int error_count = 0;

  SIPO #(N) dut (.clk(clk), .reset(reset), .enable(enable), .sum(sum),.qo(qo) );

  always #10 clk = ~clk;

  always @(posedge clk) begin
    if (reset)
      expected_q <= 0;
    else if (enable)
      expected_q <= {sum, expected_q[N:1]};
    else
      expected_q <= expected_q;
  end

  always @(posedge clk) begin

    if (qo !== expected_q) begin
      $display("ERROR");
      error_count++;
    end
  end

  initial begin
    clk = 0;
    reset = 1;
    enable = 0;
    sum = 0;

    #15;
    reset = 0;

    repeat (30) begin
      @(negedge clk);
      enable = $urandom_range(0,1);
      sum    = $urandom_range(0,1);
    end

    #20;
    if (error_count == 0)
      $display("TEST PASSED");
    else
      $display("TEST FAILED");

    $finish;
  end

endmodule
