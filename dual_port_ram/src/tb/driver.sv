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
        vif.addra <= tr.addra;
        vif.addrb <= tr.addrb;
        vif.wea <= tr.wea;
        vif.en <= tr.en;
        vif.rst <= tr.rst;
        vif.dina <= tr.dina;
      end
    endtask
endclass
    