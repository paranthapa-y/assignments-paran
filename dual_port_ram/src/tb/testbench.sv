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

  ram dut( .addra(vif.addra), .addrb(vif.addrb) , .wea(vif.wea), .clk(clk) ,.en(vif.en), .rst(vif.rst) , .dina(vif.dina), 
          .douta(vif.douta) , .doutb(vif.doutb));

  

  Environment env;
  initial begin
    $dumpfile("test_bench.vcd");
    $dumpvars;
    clk = 0;
    vif.rst = 1;
    #40 vif.rst = 0;
    env = new(vif);
    env.run();

   #10000;
    $finish;
  
  end


  
endmodule