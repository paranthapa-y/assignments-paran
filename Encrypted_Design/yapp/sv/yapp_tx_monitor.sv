
import uvm_pkg::*;
`include "uvm_macros.svh"

class yapp_tx_monitor extends uvm_monitor;
  `uvm_component_utils(yapp_tx_monitor)

  virtual yapp_if vif;
  // Collected Data handle
  yapp_packet packet_collected;

  // Count packets collected
  int num_pkt_col;

  // Analysis port to send collected packets to scoreboard/subscribers
  uvm_analysis_port #(yapp_packet) item_collected_port;

  // -------------------------
  // Coverage model
  // -------------------------
covergroup yapp_cg;
  length_cp: coverpoint packet_collected.length {
    bins MIN = {1};
//    bins MAX = {63};
    bins BABY = {[2 : 10]};
    bins TEENY = {[11 : 40]};
    bins GROWNUP = {[41 : 62]};
  }

  addr_cp: coverpoint packet_collected.addr { bins legal[] = {[0:3]}; bins illegal = default; }
  parity_cp: coverpoint (packet_collected.parity_type == BAD_PARITY) { bins err = {1}; bins noerr = {0}; }
//  sizeXaddrXerr : cross length_cp, addr_cp, parity_cp;
endgroup
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);

    // Create covergroup
    yapp_cg = new();
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "Start of simulation phase", UVM_HIGH);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!yapp_vif_config::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"vif not set for: ", get_full_name(), ".vif"})
  endfunction

  task run_phase(uvm_phase phase);
    packet_collected = yapp_packet::type_id::create("packet_collected", this);
    @(negedge vif.reset) `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)

    forever begin
      collect_packet();
    end
  endtask

  // Collect Packets
  task collect_packet();
    // Monitor looks at the bus on posedge (Driver uses negedge)
    @(posedge vif.in_data_vld);
    @(posedge vif.clock iff (!vif.in_suspend))
      void'(this.begin_tr(
          packet_collected, "Monitor_YAPP_Packet"
      ));

    `uvm_info(get_type_name(), "Collecting a packet", UVM_HIGH)

    // Collect Header {Length, Addr}
    {packet_collected.length, packet_collected.addr} = vif.in_data;
    packet_collected.payload = new[packet_collected.length];

    // Collect the Payload
    for (int i = 0; i < packet_collected.length; i++) begin
      @(posedge vif.clock iff (!vif.in_suspend)) packet_collected.payload[i] = vif.in_data;
    end

    // Collect Parity and Compute Parity Type
    @(posedge vif.clock iff !vif.in_suspend) packet_collected.parity = vif.in_data;

    packet_collected.parity_type =
      (packet_collected.parity == packet_collected.calc_parity())
        ? GOOD_PARITY : BAD_PARITY;

    this.end_tr(packet_collected);

    `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", packet_collected.sprint()),
              UVM_LOW)

    num_pkt_col++;

    // Send to scoreboard/subscribers
    item_collected_port.write(packet_collected);

    // ✅ Sample coverage
    yapp_cg.sample();
  endtask : collect_packet

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col),
              UVM_LOW)
  endfunction : report_phase

endclass

