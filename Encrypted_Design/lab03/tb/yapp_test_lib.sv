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
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase", "default_sequence",
                            yapp_5_packets::type_id::get());
    super.build_phase(phase);

    // Construct environment
    env = new("env", this);
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

`endif  // YAPP_TEST_LIB_SV

