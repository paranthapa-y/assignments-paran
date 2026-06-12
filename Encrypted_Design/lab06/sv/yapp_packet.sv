import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum {
  GOOD_PARITY,
  BAD_PARITY
} parity_t;

class yapp_packet extends uvm_sequence_item;

  rand bit [5:0] length;
  rand bit [1:0] addr;
  rand byte payload[];  //Variable size for each transaction
  byte parity;
  rand parity_t parity_type;
  rand int packet_delay;

  //`uvm_object_utils(yapp_packet);
  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(length, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(parity, UVM_ALL_ON)
    `uvm_field_int(packet_delay, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "yapp_packet");
    super.new(name);
  endfunction

  function bit [7:0] calc_parity();
    //No function implementation
    byte p;
    p = {length, addr};
    foreach (payload[i]) p = p ^ payload[i];
    return p;
  endfunction

  function void post_randomize();
    if (parity_type == GOOD_PARITY) begin
      parity = calc_parity();
    end else begin
      parity = ~calc_parity();
      //Write an incorrect parity value to parity
    end
  endfunction

  constraint address_c {addr != 2'b11;}
  constraint length_c {length inside {[1 : 63]};}
  constraint parity_type_c {
    parity_type dist {
      GOOD_PARITY := 5,
      BAD_PARITY  := 1
    };
  }
  constraint payload_c {payload.size() == length;}
  constraint packet_delay_c {packet_delay inside {[0 : 20]};}
endclass













////////////////////////////short yapp packet////////////////
class short_yapp_packet extends yapp_packet;
  `uvm_object_utils(short_yapp_packet)

  function new(string name = "yapp_packet");
    super.new(name);
  endfunction

  constraint length_c1 {length < 15;}
  // constraint address_c1 {addr != 2'b01;}

endclass
