// -----------------------------------------------------------------------------
// File: sv_tb.sv
// Description: Alternative SystemVerilog testbench for the de-skew module.
// May be used for additional or legacy test scenarios.
// -----------------------------------------------------------------------------
// This is the base transaction object that will be used
// in the environment to initiate new transactions and 
// capture transactions at DUT interface
class reg_item;
  rand  bit [7:0]   addr;   // Address
  rand  bit [15:0]  wdata;  // Write data
      bit [15:0]  rdata;   // Read data
  rand  bit     wr;     // Write/read flag
  
  // This function allows us to print contents of the data packet
  // so that it is easier to track in a logfile
  function void print(string tag="");
    $display ("T=%0t [%s] addr=0x%0h wr=%0d wdata=0x%0h rdata=0x%0h", 
              			$time, tag, addr, wr, wdata, rdata);
  endfunction
endclass

// The driver is responsible for driving transactions to the DUT 
// All it does is to get a transaction from the mailbox if it is 
// available and drive it out into the DUT interface.
class driver;
  virtual reg_if vif; // Virtual interface handle
  event drv_done;     // Event to signal transaction done
  mailbox drv_mbx;   // Mailbox for transactions
  
  // Main driver loop
  task run();
    $display ("T=%0t [Driver] starting ...", $time);
    @ (posedge vif.clk);
    
    // Try to get a new transaction every time and then assign 
    // packet contents to the interface. But do this only if the 
    // design is ready to accept new transactions
    forever begin
      reg_item item;
      
      $display ("T=%0t [Driver] waiting for item ...", $time);
      drv_mbx.get(item);      
	  item.print("Driver");
      vif.sel <= 1;
      vif.addr 	<= item.addr;
      vif.wr 	<= item.wr;
      vif.wdata <= item.wdata;
      @ (posedge vif.clk);
      while (!vif.ready)  begin
        $display ("T=%0t [Driver] wait until ready is high", $time);
        @(posedge vif.clk);
      end
      
      // When transfer is over, raise the done event
      vif.sel <= 0;
      ->drv_done;
    end   
  endtask
endclass

// The monitor has a virtual interface handle with which it can monitor
// the events happening on the interface. It sees new transactions and then
// captures information into a packet and sends it to the scoreboard
// using another mailbox.
class monitor;
  virtual reg_if vif;     // Virtual interface handle
  mailbox scb_mbx;        // Mailbox connected to scoreboard
  
  task run();
    $display ("T=%0t [Monitor] starting ...", $time);
    
    // Check forever at every clock edge to see if there is a 
    // valid transaction and if yes, capture info into a class
    // object and send it to the scoreboard when the transaction 
    // is over.
    forever begin
      @ (posedge vif.clk);
      if (vif.sel) begin
        reg_item item = new;
        item.addr = vif.addr;
        item.wr = vif.wr;
        item.wdata = vif.wdata;

        if (!vif.wr) begin
          @(posedge vif.clk);
        	item.rdata = vif.rdata;
        end
        item.print("Monitor");
        scb_mbx.put(item);
      end
    end
  endtask
endclass

// The scoreboard is responsible to check data integrity. Since the design
// stores data it receives for each address, scoreboard helps to check if the
// same data is received when the same address is read at any later point
// in time. So the scoreboard has a "memory" element which updates it
// internally for every write operation.
class scoreboard;
  mailbox scb_mbx;        // Mailbox from monitor
  reg_item refq[256];     // Reference queue for checking data
  
  task run();
    forever begin
      reg_item item;
      scb_mbx.get(item);
      item.print("Scoreboard");
      
      if (item.wr) begin
        if (refq[item.addr] == null)
          refq[item.addr] = new;
        
        refq[item.addr] = item;
        $display ("T=%0t [Scoreboard] Store addr=0x%0h wr=0x%0h data=0x%0h", $time, item.addr, item.wr, item.wdata);
      end
      
        if (!item.wr) begin
          if (refq[item.addr] == null)
            if (item.rdata != 'h1234)
              	$display ("T=%0t [Scoreboard] ERROR! First time read, addr=0x%0h exp=1234 act=0x%0h",
                        											$time, item.addr, item.rdata);
          	else
          		$display ("T=%0t [Scoreboard] PASS! First time read, addr=0x%0h exp=1234 act=0x%0h",
                    												$time, item.addr, item.rdata);
          else
            if (item.rdata != refq[item.addr].wdata)
              $display ("T=%0t [Scoreboard] ERROR! addr=0x%0h exp=0x%0h act=0x%0h",
                        $time, item.addr, refq[item.addr].wdata, item.rdata);
           else
             $display ("T=%0t [Scoreboard] PASS! addr=0x%0h exp=0x%0h act=0x%0h", 
                       $time, item.addr, refq[item.addr].wdata, item.rdata);
        end
    end
  endtask
endclass

// The environment is a container object simply to hold all verification 
// components together. This environment can then be reused later and all
// components in it would be automatically connected and available for use
// This is an environment without a generator.
class env;
  driver 			d0; 		// Driver to design
  monitor 			m0; 		// Monitor from design
  scoreboard 		s0; 		// Scoreboard connected to monitor
  mailbox 			scb_mbx; 	// Top level mailbox for SCB <-> MON 
  virtual reg_if 	vif; 		// Virtual interface handle
  
  // Instantiate all testbench components
  function new();
    d0 = new;
    m0 = new;
    s0 = new;
    scb_mbx = new();
  endfunction
  
  // Assign handles and start all components so that 
  // they all become active and wait for transactions to be
  // available
  virtual task run();
    d0.vif = vif;
    m0.vif = vif;
    m0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;
    
    fork
    	s0.run();
		d0.run();
    	m0.run();
    join_any
  endtask
endclass

// Sometimes we simply need to generate N random transactions to random
// locations so a generator would be useful to do just that. In this case
// loop determines how many transactions need to be sent
class generator;
  int 	loop = 10;
  event drv_done;
  mailbox drv_mbx;
  
  task run();
    for (int i = 0; i < loop; i++) begin
      reg_item item = new;
      item.randomize();
      $display ("T=%0t [Generator] Loop:%0d/%0d create next item", $time, i+1, loop);
      drv_mbx.put(item);
      $display ("T=%0t [Generator] Wait for driver to be done", $time);
      @(drv_done);
    end
  endtask
endclass


// Lets say that the environment class was already there, and generator is 
// a new component that needs to be included in the ENV. So a child ENV can
// be derived and generator be instantiated in it along with all others.
// Note that the run task should be overridden to start the generator as 
// well.
class env_w_gen extends env;
  generator g0;
  
  event drv_done;
  mailbox drv_mbx;
  
  function new();
    super.new();
    g0 = new;
    drv_mbx = new;
  endfunction
  
  virtual task run();
    // Connect virtual interface handles
    d0.vif = vif;
    m0.vif = vif;
    
    // Connect mailboxes between each component
    d0.drv_mbx = drv_mbx;
    g0.drv_mbx = drv_mbx;
    
    m0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;
    
    // Connect event handles
    d0.drv_done = drv_done;
    g0.drv_done = drv_done;
    
    // Start all components - a fork join_any is used because 
    // the stimulus is generated by the generator and we want the
    // simulation to exit only when the generator has finished 
    // creating all transactions. Until then all other components
    // have to run in the background.
    fork
    	s0.run();
		d0.run();
    	m0.run();
      g0.run();
    join_any
  endtask
endclass

// The interface allows verification components to access DUT signals
// using a virtual interface handle
interface reg_if (input bit clk);
  logic rstn;
  logic [7:0] addr;
  logic [15:0] wdata;
  logic [15:0] rdata;
  logic 		wr;
  logic 		sel;
  logic 		ready;
endinterface

// The test can instantiate any environment. In this test, we are using
// an environment without the generator and hence the stimulus should be 
// written in the test. 
class test;
  env e0;
  mailbox drv_mbx;
  
  function new();
    drv_mbx = new();
    e0 = new();
  endfunction
  
  virtual task run();
    e0.d0.drv_mbx = drv_mbx;
    
    fork
    	e0.run();
    join_none
    
    apply_stim();
  endtask
  
  virtual task apply_stim();
    reg_item item;
    
    $display ("T=%0t [Test] Starting stimulus ...", $time);
    item = new;
    item.randomize() with { addr == 8'haa; wr == 1; };
    drv_mbx.put(item);
    
    item = new;
    item.randomize() with { addr == 8'haa; wr == 0; };
    drv_mbx.put(item);
  endtask
endclass

// In this test, the original "apply_stim" method is overridden to
// generate 20 randomized transactions
class rand_test extends test;
  virtual task apply_stim();
    for (int i = 0; i < 20; i++) begin
      reg_item item = new;
      item.randomize();
      drv_mbx.put(item);
    end
  endtask
endclass

// This is a new test that instead instantiates an environment with a 
// generator so that random stimulus is automatically applied instead 
// of having to create an "apply_stim" task. Remember that this is a 
// random environment and for more finer control, the above two tests
// can be used.
class new_test;
  env_w_gen e0;
  
  function new();
    e0 = new();
  endfunction
  
  virtual task run();    
    fork
    	e0.run();
    join_none
  endtask
endclass

// Top level testbench contains the interface, DUT and test handles which 
// can be used to start test components once the DUT comes out of reset. Or
// the reset can also be a part of the test class in which case all you need
// to do is start the test's run method.
module tb;
  reg clk;
  
  always #10 clk = ~clk;
  reg_if _if (clk);
  
  reg_ctrl u0 ( .clk (clk),
            .addr (_if.addr),
               .rstn(_if.rstn),
            .sel  (_if.sel),
               .wr (_if.wr),
            .wdata (_if.wdata),
            .rdata (_if.rdata),
            .ready (_if.ready));
  
  initial begin
    test	  t0;	
    new_test  t1;
    rand_test t2;
    
    clk <= 0;
    _if.rstn <= 0;
    _if.sel <= 0;
    #20 _if.rstn <= 1;

    t0 = new;
    t0.e0.vif = _if;
//    t0.run();
    
    t1 = new;
    t1.e0.vif = _if;
//    t1.run();
    
    t2 = new;
    t2.e0.vif = _if;
    t2.run();
    
    // Once the main stimulus is over, wait for some time
    // until all transactions are finished and then end 
    // simulation. Note that $finish is required because
    // there are components that are running forever in 
    // the background like clk, monitor, driver, etc
    #500 $finish;
  end
  
  // Simulator dependent system tasks that can be used to 
  // dump simulation waves.
  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
endmodule



/*
Simulation Log:
---------------

ncsim> run
T=20 [Driver] starting ...
T=20 [Monitor] starting ...
T=30 [Driver] waiting for item ...
T=30 [Driver] addr=0xbe wr=1 wdata=0xbc7a rdata=0x0
T=50 [Driver] waiting for item ...
T=50 [Driver] addr=0xa9 wr=1 wdata=0x3d4c rdata=0x0
T=50 [Monitor] addr=0xbe wr=1 wdata=0xbc7a rdata=0x0
T=50 [Scoreboard] addr=0xbe wr=1 wdata=0xbc7a rdata=0x0
T=50 [Scoreboard] Store addr=0xbe wr=0x1 data=0xbc7a
T=70 [Driver] waiting for item ...
T=70 [Driver] addr=0x3e wr=1 wdata=0x27bd rdata=0x0
T=70 [Monitor] addr=0xa9 wr=1 wdata=0x3d4c rdata=0x0
T=70 [Scoreboard] addr=0xa9 wr=1 wdata=0x3d4c rdata=0x0
T=70 [Scoreboard] Store addr=0xa9 wr=0x1 data=0x3d4c
T=90 [Driver] waiting for item ...
T=90 [Driver] addr=0xc5 wr=1 wdata=0x39e0 rdata=0x0
T=90 [Monitor] addr=0x3e wr=1 wdata=0x27bd rdata=0x0
T=90 [Scoreboard] addr=0x3e wr=1 wdata=0x27bd rdata=0x0
T=90 [Scoreboard] Store addr=0x3e wr=0x1 data=0x27bd
T=110 [Driver] waiting for item ...
T=110 [Driver] addr=0x57 wr=0 wdata=0xfc0c rdata=0x0
T=110 [Monitor] addr=0xc5 wr=1 wdata=0x39e0 rdata=0x0
T=110 [Scoreboard] addr=0xc5 wr=1 wdata=0x39e0 rdata=0x0
T=110 [Scoreboard] Store addr=0xc5 wr=0x1 data=0x39e0
T=130 [Driver] waiting for item ...
T=130 [Driver] addr=0xb3 wr=0 wdata=0x7ba rdata=0x0
T=150 [Driver] wait until ready is high
T=150 [Monitor] addr=0x57 wr=0 wdata=0xfc0c rdata=0x1234
T=150 [Scoreboard] addr=0x57 wr=0 wdata=0xfc0c rdata=0x1234
T=150 [Scoreboard] PASS! First time read, addr=0x57 exp=1234 act=0x1234
T=170 [Driver] waiting for item ...
T=170 [Driver] addr=0xb8 wr=0 wdata=0xefb1 rdata=0x0
T=190 [Driver] wait until ready is high
T=190 [Monitor] addr=0xb3 wr=0 wdata=0x7ba rdata=0x1234
T=190 [Scoreboard] addr=0xb3 wr=0 wdata=0x7ba rdata=0x1234
T=190 [Scoreboard] PASS! First time read, addr=0xb3 exp=1234 act=0x1234
T=210 [Driver] waiting for item ...
T=210 [Driver] addr=0xea wr=0 wdata=0xf40d rdata=0x0
T=230 [Driver] wait until ready is high
T=230 [Monitor] addr=0xb8 wr=0 wdata=0xefb1 rdata=0x1234
T=230 [Scoreboard] addr=0xb8 wr=0 wdata=0xefb1 rdata=0x1234
T=230 [Scoreboard] PASS! First time read, addr=0xb8 exp=1234 act=0x1234
T=250 [Driver] waiting for item ...
T=250 [Driver] addr=0x99 wr=1 wdata=0x6ee6 rdata=0x0
T=270 [Driver] wait until ready is high
T=270 [Monitor] addr=0xea wr=0 wdata=0xf40d rdata=0x1234
T=270 [Scoreboard] addr=0xea wr=0 wdata=0xf40d rdata=0x1234
T=270 [Scoreboard] PASS! First time read, addr=0xea exp=1234 act=0x1234
T=290 [Driver] waiting for item ...
T=290 [Driver] addr=0x53 wr=0 wdata=0x73ce rdata=0x0
T=290 [Monitor] addr=0x99 wr=1 wdata=0x6ee6 rdata=0x0
T=290 [Scoreboard] addr=0x99 wr=1 wdata=0x6ee6 rdata=0x0
T=290 [Scoreboard] Store addr=0x99 wr=0x1 data=0x6ee6
T=310 [Driver] waiting for item ...
T=310 [Driver] addr=0x4a wr=0 wdata=0xb99a rdata=0x0
T=330 [Driver] wait until ready is high
T=330 [Monitor] addr=0x53 wr=0 wdata=0x73ce rdata=0x1234
T=330 [Scoreboard] addr=0x53 wr=0 wdata=0x73ce rdata=0x1234
T=330 [Scoreboard] PASS! First time read, addr=0x53 exp=1234 act=0x1234
T=350 [Driver] waiting for item ...
T=350 [Driver] addr=0xbb wr=1 wdata=0x85f6 rdata=0x0
T=370 [Driver] wait until ready is high
T=370 [Monitor] addr=0x4a wr=0 wdata=0xb99a rdata=0x1234
T=370 [Scoreboard] addr=0x4a wr=0 wdata=0xb99a rdata=0x1234
T=370 [Scoreboard] PASS! First time read, addr=0x4a exp=1234 act=0x1234
T=390 [Driver] waiting for item ...
T=390 [Driver] addr=0x41 wr=1 wdata=0xa426 rdata=0x0
T=390 [Monitor] addr=0xbb wr=1 wdata=0x85f6 rdata=0x0
T=390 [Scoreboard] addr=0xbb wr=1 wdata=0x85f6 rdata=0x0
T=390 [Scoreboard] Store addr=0xbb wr=0x1 data=0x85f6
T=410 [Driver] waiting for item ...
T=410 [Driver] addr=0xb6 wr=1 wdata=0xe267 rdata=0x0
T=410 [Monitor] addr=0x41 wr=1 wdata=0xa426 rdata=0x0
T=410 [Scoreboard] addr=0x41 wr=1 wdata=0xa426 rdata=0x0
T=410 [Scoreboard] Store addr=0x41 wr=0x1 data=0xa426
T=430 [Driver] waiting for item ...
T=430 [Driver] addr=0x60 wr=1 wdata=0xb9e8 rdata=0x0
T=430 [Monitor] addr=0xb6 wr=1 wdata=0xe267 rdata=0x0
T=430 [Scoreboard] addr=0xb6 wr=1 wdata=0xe267 rdata=0x0
T=430 [Scoreboard] Store addr=0xb6 wr=0x1 data=0xe267
T=450 [Driver] waiting for item ...
T=450 [Driver] addr=0x20 wr=1 wdata=0x6ef7 rdata=0x0
T=450 [Monitor] addr=0x60 wr=1 wdata=0xb9e8 rdata=0x0
T=450 [Scoreboard] addr=0x60 wr=1 wdata=0xb9e8 rdata=0x0
T=450 [Scoreboard] Store addr=0x60 wr=0x1 data=0xb9e8
T=470 [Driver] waiting for item ...
T=470 [Driver] addr=0xe0 wr=1 wdata=0x134f rdata=0x0
T=470 [Monitor] addr=0x20 wr=1 wdata=0x6ef7 rdata=0x0
T=470 [Scoreboard] addr=0x20 wr=1 wdata=0x6ef7 rdata=0x0
T=470 [Scoreboard] Store addr=0x20 wr=0x1 data=0x6ef7
T=490 [Driver] waiting for item ...
T=490 [Driver] addr=0x37 wr=0 wdata=0xd00d rdata=0x0
T=490 [Monitor] addr=0xe0 wr=1 wdata=0x134f rdata=0x0
T=490 [Scoreboard] addr=0xe0 wr=1 wdata=0x134f rdata=0x0
T=490 [Scoreboard] Store addr=0xe0 wr=0x1 data=0x134f
T=510 [Driver] waiting for item ...
T=510 [Driver] addr=0x29 wr=0 wdata=0x6496 rdata=0x0
Simulation complete via $finish(1) at time 520 NS + 0
./testbench.sv:363     #500 $finish;
ncsim> exit
*/
