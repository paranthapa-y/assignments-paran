

typedef enum bit{'GOOD_PARITY', 'BAD_PARITY'} parity_t

class yapp_packet extends uvm_sequence_item;
    `uvm_object_utils(yapp_packet);

    function void new();
    endfunction

    rand bit [5:0] length ;
    rand bit [1:0] address ;
    rand bit [7:0] payload [];
    rand bit parity_t parity_type;

    bit [7:0] parity;

    function bit [7:0] calc_parity();
    endfunction

    function void post_randomize();
    parity = calc_parity();
    endfunction

    constraint address_constraint {address != b11};
    constraint length_const {}

endclass

