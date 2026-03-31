// -----------------------------------------------------------------------------
// File: driver.sv
// Description: Driver class for de-skew testbench. Drives stimulus to DUT via interface.
// -----------------------------------------------------------------------------


class Driver;
  
  mailbox gen2drv;
  virtual des_if vif;
  
  function new( mailbox gen2drv, virtual des_if vif);
      this.gen2drv = gen2drv;
      this.vif =vif;
  endfunction
      
    task run();
      Transaction tr;
      
      forever begin
        gen2drv.get(tr);
        @(posedge vif.clk);
        vif.stream1 <= tr.stream1;
        vif.stream2 <= tr.stream2;
        vif.reset <= tr.reset;
      end
    endtask
endclass
    