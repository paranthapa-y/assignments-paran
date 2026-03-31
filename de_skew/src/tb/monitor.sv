// -----------------------------------------------------------------------------
// File: monitor.sv
// Description: Monitor class for de-skew testbench. Observes DUT outputs and collects coverage.
// -----------------------------------------------------------------------------
class Monitor;
  
  mailbox mon2scb;
  virtual des_if vif;
  // Functional coverage
  covergroup cg @(posedge vif.clk);
    cp1 : coverpoint vif.stream1 {
      bins s1[] = {[0:15]};
    }
    cp2 : coverpoint vif.stream2 {
      bins s2[] = {[0:15]};
    }
    // coverpoint vif.o_stream {
    //   bins out[] = {[0:255]};
    // }
    coverpoint vif.o_aligned {
      bins aligned = {0, 1};
    }
    coverpoint vif.reset {
      bins reset = {0, 1};
    }
    
    // Cross coverage for interesting combinations
    cross cp1, cp2;
    // cross s1, s2, reset;
    // cross aligned, reset;
  endgroup
  
  function new(mailbox mon2scb, virtual des_if vif);
    this.mon2scb =mon2scb;
    this.vif = vif;
    cg = new();
  endfunction
  
  task run();
    
    Transaction tr;
    
    forever begin 
      tr = new();
      @(posedge vif.clk);
      // Sample coverage
      cg.sample();
      tr.stream1 = vif.stream1;
      tr.stream2 = vif.stream2;
      tr.out_stream = vif.o_stream;
      tr.aligned = vif.o_aligned;
      tr.reset = vif.reset;
      mon2scb.put(tr);
    end
  endtask
endclass