`ifndef CFS_APB_DRIVER_SV
`define CFS_APB_DRIVER_SV

class cfs_apb_driver extends uvm_ext_driver #(
    .VIRTUAL_INTF(cfs_apb_vif),
    .ITEM_DRV(cfs_apb_item_drv)
);

  cfs_apb_agent_config agent_config;

  `uvm_component_utils(cfs_apb_driver)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    if ($cast(agent_config, super.agent_config) == 0) begin
      `uvm_fatal("ALGORITHM_ISSUE",
                 $sformatf("Could not cast %0s to %0s",
                           super.agent_config.get_type_name(),
                           "cfs_apb_agent_config"))
    end
  endfunction


  protected virtual task drive_transaction(cfs_apb_item_drv item);
    cfs_apb_vif vif = agent_config.get_vif();
    
    `uvm_info("ITEM_START",$sformatf("Driving \"%0s\": %0s",
                        item.get_full_name(),
                        item.convert2string()),
              UVM_LOW)

    // Optional pre-delay
    for (int i = 0; i < item.pre_drive_delay; i++) begin
      @(posedge vif.pclk);
    end

    ////////////////////////////////////////////////////
    // APB SETUP PHASE
    // PSEL=1, PENABLE=0
    ////////////////////////////////////////////////////
    vif.psel    <= 1;
    vif.penable <= 0;   // FIX #1
    vif.pwrite  <= bit'(item.dir);
    vif.paddr   <= item.addr;

    if (item.dir == CFS_APB_WRITE) begin
      vif.pwdata <= item.data;
    end

    @(posedge vif.pclk);

    ////////////////////////////////////////////////////
    // APB ACCESS PHASE
    // PENABLE goes high in next cycle
    ////////////////////////////////////////////////////
    vif.penable <= 1;   // FIX #2

    // Wait for slave ready
    while (vif.pready !== 1) begin
      @(posedge vif.pclk);
    end

    // Optional read data capture
    if (item.dir == CFS_APB_READ) begin
      item.data = vif.prdata;
    end

    ////////////////////////////////////////////////////
    // Return bus to idle
    ////////////////////////////////////////////////////
    @(posedge vif.pclk);

    vif.psel    <= 0;
    vif.penable <= 0;
    vif.pwrite  <= 0;
    vif.paddr   <= 0;
    vif.pwdata  <= 0;

    for (int i = 0; i < item.post_drive_delay; i++) begin
      @(posedge vif.pclk);
    end
  endtask


  virtual function void handle_reset(uvm_phase phase);
    cfs_apb_vif vif = agent_config.get_vif();

    super.handle_reset(phase);

    ////////////////////////////////////////////////////
    // APB idle state during reset
    ////////////////////////////////////////////////////
    vif.psel    <= 0;   // FIX #3
    vif.penable <= 0;   // FIX #3
    vif.pwrite  <= 0;
    vif.paddr   <= 0;
    vif.pwdata  <= 0;
  endfunction

endclass

`endif