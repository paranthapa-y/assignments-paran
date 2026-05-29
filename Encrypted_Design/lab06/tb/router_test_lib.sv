import uvm_pkg::*;
`include "uvm_macros.svh"


///////////////////////// base test /////////////////////////////
class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  router_tb tb;
  function new(string name = "base test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);

    tb = router_tb::type_id::create("tb", this);
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_5_packets::type_id::get());
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 200ns);
  endtask


  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(), "end of elabaration phase", UVM_HIGH);
    uvm_top.print_topology();
  endfunction

endclass



////////////////short_packet_test///////////////////////////
class short_packet_test extends base_test;
  `uvm_component_utils(short_packet_test)

  function new(string name = "short_packet_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // Use set_type_override to change the packet type to short_yapp_packet
    super.build_phase(phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
  endfunction
endclass


///////////////////////set_config_test////////////////
class set_config_test extends base_test;
  `uvm_component_utils(set_config_test)

  function new(string name = "set_config_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // Set the is_active flag of the yapp_tx_agent to UVM_PASSIVE
    super.build_phase(phase);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "tb.env.agent", "is_active", UVM_PASSIVE);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass



////////////////short_packet_test///////////////////////////
class short_incr_payload extends base_test;
  `uvm_component_utils(short_incr_payload)

  function new(string name = "short_incr_payload", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // Use set_type_override to change the packet type to short_yapp_packet
    super.build_phase(phase);
    /* uvm_config_db#(uvm_object_wrapper)::set(this, "tb.env.agent.sequencer.run_phase",
                                            "default_sequence", yapp_incr_payload_seq::get_type());*/
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_incr_payload_seq::type_id::get());
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
  endfunction
endclass


class exhaustive_seq_test extends base_test;
  `uvm_component_utils(exhaustive_seq_test)
  yapp_seq_lib seq_lib;  // Handle for your library

  function new(string name = "exhaustive_seq_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq_lib = yapp_seq_lib::type_id::create("seq_lib");
    seq_lib.selection_mode = UVM_SEQ_LIB_RANDC;  // RANDC = Random with no repeats
    seq_lib.min_random_count = 8;
    seq_lib.max_random_count = 8;

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.env.agent.sequencer.run_phase",
                                            "default_sequence", seq_lib.get_type());

    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
  endfunction
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(), "Printing sequence library contents:", UVM_LOW)
    seq_lib.print();
  endfunction
endclass
