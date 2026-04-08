// -----------------------------------------------------------------------------
// File: monitor.sv
// Description: Monitor class for de-skew testbench. Observes DUT outputs and collects coverage.
// -----------------------------------------------------------------------------
class Monitor;
  
  mailbox mon2scb;
  virtual des_if vif;
  // Functional coverage
  
  
  function new(mailbox mon2scb, virtual des_if  vif);
    this.mon2scb =mon2scb;
    this.vif = vif;
    // cg = new(); function new(virtual des_if #(4,4) vif);
  endfunction
  
  task run();
    
    Transaction tr;
    
    forever begin 
      tr = new();
      @(posedge vif.clk);
      // Sample coverage
      // cg.sample();
      tr.addra = vif.addra;
      tr.addrb = vif.addrb;
      tr.wea = vif.wea;
      tr.en = vif.en;
      tr.rst = vif.rst;
      tr.dina = vif.dina;
      tr.douta = vif.douta;
      tr.doutb = vif.doutb;
      tr.display("MON");
      mon2scb.put(tr);
    end
  endtask
endclass