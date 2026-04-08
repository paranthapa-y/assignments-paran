// -----------------------------------------------------------------------------
// File: generator.sv
// Description: Generator class for de-skew testbench. Generates random or constrained transactions.
// -----------------------------------------------------------------------------


class Generator;
  
  mailbox gen2drv;
  
  function new( mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task manual(logic wea = 'x, en = 'x, rst = 'x);
    Transaction tr = new();
    tr.randomize();
    if (wea !== 'x) tr.wea = wea;
    if (en !== 'x) tr.en = en;
    if (rst !== 'x) tr.rst = rst;
    tr.display("GEN");
    gen2drv.put(tr);

  endtask

  task run();
  Transaction tr = new();
  tr.randomize() with{
      rst == 1;
    };
  tr.display("GEN");
  gen2drv.put(tr);
  write_focussed : repeat (500) begin
    Transaction tr = new();
    tr.randomize() with{
      wea dist {0:=10, 1:=99};
    };
    tr.display("GEN");
    gen2drv.put(tr);
  end

  manual(1, 0, 0);
  manual(1, 0, 0);

  read_foccused : repeat (500) begin
    Transaction tr = new();
    tr.randomize();
    tr.display("GEN");
    gen2drv.put(tr);
  end
  endtask
      
endclass
