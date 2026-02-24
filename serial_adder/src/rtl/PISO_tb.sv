module PISO_tb;//testing

  parameter N = 8;

  logic clk;
  logic load,reset;
  logic enable;
  logic qo;
  logic [N-1:0]a,expected_shift;
 

  logic expected_q;
  int error_count = 0;

  PISO #(N) dut (.clk(clk), .reset(reset), .load(load), .enable(enable), .A(a),.q(qo) );

  always #10 clk = ~clk;

  always @(posedge clk) begin
    if (reset)
      expected_shift <= 0;
    else if (load)
      expected_shift <= a;
    else if (enable)
      expected_shift <= {1'b0,expected_shift[N-1:1]};
    else
      expected_shift <= expected_shift;
  end
  assign expected_q = expected_shift[0];

  always @(posedge clk) begin
    //#3;

    if (qo !== expected_q) begin
      $display("ERROR at %0t | Expected=%b Got=%b",
               $time, expected_q, qo);
      error_count++;
    end
  end

  initial begin
    $dumpfile("test_bench.vcd");
    $dumpvars;
    clk = 0;
    load = 0;
    enable = 0;
    reset = 1;
    
    @(posedge clk);
    reset = 0;
    @(posedge clk);
    a = 8'b10101010;
    load = 1;
    @(posedge clk);
    load = 0;
    enable = 1;
    repeat(10) @(posedge clk);
    @(posedge clk);
    reset = 0;
    @(posedge clk);
    a = 8'b11111111;
    load = 1;
    @(posedge clk);
    load = 0;
    enable = 1;
    repeat(10) @(posedge clk);
        if (error_count == 0)
        $display("time = %0t, TEST PASSED expected_q=%b got_q=%b", $time, expected_q, qo);
        else
        $display("time = %0t, TEST FAILED expected_q=%b got_q=%b", $time, expected_q, qo);




    // repeat (30) begin
    //   @(posedge clk);
    //   #100
    //   enable = $urandom_range(0,1);
    //   load = $urandom_range(0,1);
    //   reset = $urandom_range(0,1);
    //   a    = $urandom_range(0,255);
    // end

    #20;
    if (error_count == 0)
      $display("TEST PASSED");
    else
      $display("TEST FAILED");

    $finish;
  end

endmodule
