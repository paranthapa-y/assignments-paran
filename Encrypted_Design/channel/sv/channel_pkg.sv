/*-----------------------------------------------------------------
File name     : channel_pkg.sv
Description   : This creates a package for the channel OVC
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`ifndef CHANNEL_PKG_SV
`define CHANNEL_PKG_SV

package channel_pkg;

  // Import UVM
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import the YAPP packet package so channel can use yapp_packet
  import yapp_pkg::*;

  // Include channel definitions
  `include "channel.svh"

endpackage : channel_pkg

`endif  // CHANNEL_PKG_SV

