/*-----------------------------------------------------------------
File name     : yapp_packet.sv
Description   : YAPP packet class used by both TX and RX.
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`ifndef YAPP_PACKET_SV
`define YAPP_PACKET_SV

// Import UVM library for uvm_sequence_item
import uvm_pkg::*;
// Include UVM macros
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// YAPP packet enums, parameters, and events
//------------------------------------------------------------------------------
typedef enum bit {
  GOOD_PARITY,
  BAD_PARITY
} parity_t;

//------------------------------------------------------------------------------
// CLASS: yapp_packet
//------------------------------------------------------------------------------
class yapp_packet extends uvm_sequence_item;

  // Physical Data
  rand bit      [5:0] length;  // payload length (1–63)
  rand bit      [1:0] addr;  // destination address (0–2 valid)
  rand bit      [7:0] payload                                    [];  // variable size payload
  bit           [7:0] parity;  // calculated in post_randomize()

  // Control Knobs
  rand parity_t       parity_type;  // control parity correctness
  rand int            packet_delay;  // delay cycles before TX

  // Constraints
  constraint length_c {length inside {[1 : 63]};}
  constraint addr_c {addr != 2'b11;}  // address 3 is illegal
  constraint payload_c {payload.size() == length;}
  constraint delay_c {packet_delay inside {[0 : 20]};}
  constraint parity_dist {
    parity_type dist {
      GOOD_PARITY := 5,
      BAD_PARITY  := 1
    };
  }

  // UVM automation macros
  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(length, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(parity, UVM_ALL_ON)
    `uvm_field_enum(parity_t, parity_type, UVM_ALL_ON)
    `uvm_field_int(packet_delay, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "yapp_packet");
    super.new(name);
  endfunction : new

  // Calculate even parity over header + payload
  function bit [7:0] calc_parity();
    bit [7:0] p;
    p = {length, addr};
    foreach (payload[i]) p ^= payload[i];
    return p;
  endfunction : calc_parity

  // Assign parity after randomization
  function void post_randomize();
    if (parity_type == GOOD_PARITY) parity = calc_parity();
    else begin
      do parity = $urandom; while (parity == calc_parity());  // ensure incorrect parity
    end
  endfunction : post_randomize

endclass : yapp_packet

class short_yapp_packet extends yapp_packet;
  `uvm_object_utils(short_yapp_packet)

  // Constructor
  function new(string name = "short_yapp_packet");
    super.new(name);
  endfunction

  // Constraints
  constraint short_length_c {length < 15;}  // limit payload length
  constraint no_addr_2_c {addr != 2;}  // exclude address value 2

endclass : short_yapp_packet



`endif  // YAPP_PACKET_SV

