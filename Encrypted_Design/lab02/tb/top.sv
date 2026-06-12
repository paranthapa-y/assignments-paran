//------------------------------------------------------------------------------
// File name   : top.sv
// Description : Top-level testbench for Lab 2 - UVC hierarchy check
//------------------------------------------------------------------------------

// Import UVM
import uvm_pkg::*;
`include "uvm_macros.svh"

// Include all YAPP UVC components
`include "../sv/yapp.svh"

module top;

  // Handle for environment
  yapp_env env;

  // Construct environment
  initial begin
    env = yapp_env::type_id::create("env", null);
  end

  // Run default test
  initial begin
    uvm_config_wrapper::set(null, "env.agent.sequencer.run_phase", "default_sequence",
                            yapp_5_packets::type_id::get());
    run_test();
  end
endmodule : top

