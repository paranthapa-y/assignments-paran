class Scoreboard;

  mailbox mon2scb;
  Transaction tr;

  // ----------------------------
  // Reference model signals
  // ----------------------------
 

  // ----------------------------
  function new(mailbox mon2scb);
  
    this.mon2scb = mon2scb;

  endfunction

  // ----------------------------
  task run();

  // MOVE DECLARATIONS HERE
  // forever begin
  //   mon2scb.get(tr);
  //   tr.display("SCB");
  //   // REFERENCE MODEL LOGIC HERE
  // end
  endtask
endclass