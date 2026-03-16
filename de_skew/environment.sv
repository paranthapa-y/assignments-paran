

class Environment;
  
  Generator gen;
  Driver drv;
  Monitor mon;
  Scoreboard scb;
  
  mailbox gen2drv;
  mailbox mon2scb;
  
  function new( virtual des_if vif);
    
    gen2drv =new();
    mon2scb =new();
    
    gen = new(gen2drv );
    drv = new(gen2drv , vif);
    mon = new(mon2scb, vif);
    scb = new(mon2scb);
    
  endfunction
    
    task run();
      
      fork
        gen.run();
        drv.run();
        mon.run();
        scb.run();
      join_any
    endtask
      
endclass
