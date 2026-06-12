//------------------------------------------------------------------------------
// File: yapp_test_lib.sv
// Description: Base test class for Lab03
//------------------------------------------------------------------------------

`ifndef YAPP_TEST_LIB_SV
`define YAPP_TEST_LIB_SV

`include "uvm_macros.svh"
import uvm_pkg::*;



//------------------------------------------------------------------------------
// Base Test Class
//------------------------------------------------------------------------------
class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  // Handle for environment
  yapp_env env;

  // Constructor
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Construct environment
    env = yapp_env::type_id::create("env", this);
  endfunction

  // End of elaboration phase
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // Print the testbench hierarchy
    uvm_top.print_topology();
  endfunction

endclass : base_test

class test2 extends base_test;
  `uvm_component_utils(test2)

  function new(string name = "test2", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : test2

class short_packet_test extends base_test;
  `uvm_component_utils(short_packet_test)
  // Constructor
  function new(string name = "short_packet_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    // Override yapp_packet with short_yapp_packet for the whole testbench
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());

    super.build_phase(phase);
  endfunction

endclass : short_packet_test

//------------------------------------------------------------------------------
// CLASS: set_config_test
//------------------------------------------------------------------------------
class set_config_test extends base_test;

  `uvm_component_utils(set_config_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    set_config_int("env.agent", "is_active", UVM_PASSIVE);
    super.build_phase(phase);
  endfunction : build_phase

endclass : set_config_test

class short_incr_payload extends base_test;
  `uvm_component_utils(short_incr_payload)
  // Constructor
  function new(string name = "short_incr_payload", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase", "default_sequence",
                            yapp_incr_payload_seq::type_id::get());
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    super.build_phase(phase);

  endfunction : build_phase

endclass : short_incr_payload

class exhaustive_seq_test extends base_test;
  `uvm_component_utils(exhaustive_seq_test)
  // Constructor
  // Handle for the sequence library
  yapp_seq_lib seq_lib_h;

  function new(string name = "exhaustive_seq_test", uvm_component parent = null);
    super.new(name, parent);
    seq_lib_h = yapp_seq_lib::type_id::create("seq_lib_h");
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Configure selection mode: cyclic randomization
    seq_lib_h.selection_mode   = UVM_SEQ_LIB_RANDC;

    // Number of sequences in the sequence library
    seq_lib_h.min_random_count = 8;  // we added 8 sequences
    seq_lib_h.max_random_count = 8;

    // Set default sequence for YAPP sequencer
    uvm_config_db#(uvm_sequence_base)::set(
        this, "env.agent.sequencer.run_phase",  // adjust path to your YAPP sequencer
        "default_sequence", seq_lib_h);

    // Override yapp_packet with short_packet from Lab04
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);  // retains print_topology()
    seq_lib_h.print();  // print sequence library for debugging
  endfunction : end_of_elaboration_phase

endclass : exhaustive_seq_test



`endif  // YAPP_TEST_LIB_SV

