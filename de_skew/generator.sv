// -----------------------------------------------------------------------------
// File: generator.sv
// Description: Generator class for de-skew testbench. Generates random or constrained transactions.
// -----------------------------------------------------------------------------


class Generator;
  
  mailbox gen2drv;
  
  function new( mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task send(bit [3:0] v1, bit [3:0] v2);
	  Transaction tr;
	  tr = new();
	  tr.stream1 = v1;
	  tr.stream2 = v2;
	  tr.display("GEN");
	  gen2drv.put(tr);
  endtask
  task reset_pulse();

	Transaction tr;

	tr = new();

	tr.reset = 1;
	tr.stream1 = 0;
	tr.stream2 = 0;
	tr.display("GEN");

	gen2drv.put(tr);

	endtask

  task random_case();
	  Transaction tr;
	  tr = new();
	  if(!tr.randomize())
		  $display("randomization in GEN failed");
	  tr.display("GEN");
	  gen2drv.put(tr);
  endtask

  task pos_case();
	  send(4'hA,$urandom_range(0,15));
	  repeat ($urandom_range(0,2)) begin
		  random_case();
	  end
	  send($urandom_range(0,15),4'hA);
	  repeat(10) begin
		  random_case();
	  end
  endtask
  task pos_case2();
	  send(4'h9,4'hA);
	  repeat ($urandom_range(0,2)) begin
		  random_case();
	  end
	  send(4'hA,4'hB);
	  repeat(10) begin
		  random_case();
	  end
  endtask
  task neg_case();
	  send(4'hA,$urandom_range(0,15));
	  reset_pulse();
	  repeat ($urandom_range(0,5)) begin
		  random_case();
	  end
	  send($urandom_range(0,15),4'hA);
	  repeat(10) begin
		  random_case();
	  end
  endtask
  task neg_case2();
	  send(4'hB,$urandom_range(0,15));
	  repeat (2) begin
		  random_case();
	  end
	  send($urandom_range(0,15),4'hA);
	  repeat(10) begin
		  random_case();
	  end
  endtask

  task sync();
	  send(4'hA,4'hA);
	  repeat (2) begin
		  random_case();
	  end
	  send($urandom_range(0,15),4'hA);
	  repeat(10) begin
		  random_case();
	  end
  endtask


  task run();
  repeat (20) begin
	  pos_case();
	  reset_pulse();
	  #50;
	  pos_case2();
	  reset_pulse();
	  #50;
	  neg_case();
	  reset_pulse();
	  #50;
	  neg_case2();
	  reset_pulse();
	  #50 sync();
	  reset_pulse();
  end
	  
  endtask
      
endclass
