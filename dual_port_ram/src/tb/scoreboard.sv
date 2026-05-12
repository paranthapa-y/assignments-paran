class Scoreboard;

  mailbox mon2scb;
  Transaction tr;
  logic [3:0] ref_mem [0:15]; // Reference memory array
  logic [3:0] exp_douta, exp_doutb; // Expected output data

  logic w_valid[2:0];
  logic r_valid1[1:0];
  logic r_valid2[1:0];
  logic [3:0]w_data[2:0];
  logic [3:0]r_data1[1:0];
  logic [3:0]r_data2[1:0];
  virtual des_if vif;
  integer i;
  integer j;
  

  function new(mailbox mon2scb, virtual des_if vif);
  
    this.mon2scb = mon2scb;
    this.vif = vif;
    $display("new SCB");
    exp_douta = 0;
    foreach (ref_mem[k]) ref_mem[k] = 0;
    foreach (w_valid[k]) w_valid[k] = 0;
    foreach (r_valid1[k]) r_valid1[k] = 0;
    foreach (w_data[k])  w_data[k]  = 0;
    foreach (r_data1[k])  r_data1[k]  = 0;

  endfunction

  task run();
    
    
    
    forever begin : read_block
      mon2scb.get(tr);
      $display("inside SCB");
      $display(tr.douta);
      @(posedge vif.clk);
      if (this.r_valid1[1]) begin
        this.exp_douta = this.r_data1[1];
      end
      for ( i = 1; i>=0; i-- ) begin
        this.r_valid1[i] = this.r_valid1[i-1];
        this.r_data1[i] = this.r_data1[i-1];
      end
      if (!tr.wea && tr.en) begin
        this.r_data1[0] = this.ref_mem[tr.addra];
        this.r_valid1[0] = 1'b1;
      end
      else begin
        this.r_data1[0] = 4'b0;
        this.r_valid1[0] = 1'b0;
      end

      if (this.r_valid2[1]) begin
        this.exp_doutb = this.r_data2[1];
      end
      for ( i = 1; i>=0; i-- ) begin
        this.r_valid2[i] = this.r_valid2[i-1];
        this.r_data2[i] = this.r_data2[i-1];
      end
      if (!tr.wea && tr.en) begin
        this.r_data2[0] = this.ref_mem[tr.addrb];
        this.r_valid2[0] = 1'b1;
      end
      else begin
        this.r_data2[0] = 4'b0;
        this.r_valid2[0] = 1'b0;
      end
    
      if (this.w_valid[1]) begin
        this.ref_mem[tr.addra] = this.w_data[1];
      end
      for ( i = 2; i>=0; i-- ) begin
        this.w_valid[i] = this.w_valid[i-1];
        this.w_data[i] = this.w_data[i-1];
      end
      if (tr.wea && tr.en) begin
        this.w_data[0] = tr.dina;
        this.w_valid[0] = 1'b1;
      end
      else begin
        this.w_data[0] = 4'b0;
        this.w_valid[0] = 1'b0;
      end
    
    
      $display("time %0t: PORT A expected data: %b, actual data: %b", $time, this.exp_douta, tr.douta);
      $display("time %0t: PORT B expected data: %b, actual data: %b", $time, this.exp_doutb, tr.doutb);
      $display("time %0t: ref mem: %p", $time, this.ref_mem);
    end

  endtask
endclass