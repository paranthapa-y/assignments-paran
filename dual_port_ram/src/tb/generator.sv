// -----------------------------------------------------------------------------
// File: generator.sv
// Description: Generator class for de-skew testbench. Generates random or constrained transactions.
// -----------------------------------------------------------------------------


class Generator;
  
  mailbox gen2drv;
  
  function new( mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task run();
  repeat (500) begin
    Transaction tr = new();
    tr.randomize() with{
      wea dist {0:=10, 1:=99};
    };
    tr.display("GEN");
    gen2drv.put(tr);
  end
  repeat (200) begin
	Transaction tr = new();
	tr.randomize();
	tr.display("GEN");
	gen2drv.put(tr);
  end
  endtask
      
endclass
