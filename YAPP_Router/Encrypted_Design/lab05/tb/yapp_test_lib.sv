class base_test extends uvm_test;

	
	`uvm_component_utils(base_test)
    yapp_env env;
	function new( string name = "base_test", uvm_component parent = null);
		super.new(name,parent);
		
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = yapp_env::type_id::create("env",this);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction
endclass

class test2 extends base_test;

    `uvm_component_utils(test2)

    function new( string name = "test2", uvm_component parent = null);
	    super.new(name,parent);
    endfunction

endclass

class short_packet_test extends base_test;

    `uvm_component_utils(short_packet_test)

    function new( string name = "short_packet_test", uvm_component parent = null);
	    super.new(name,parent);
    endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		set_type_override_by_type( yapp_packet::get_type(), short_yapp_packet::get_type());
	endfunction

endclass

class set_config_test extends base_test;

    `uvm_component_utils(set_config_test)

    function new( string name = "set_config_test", uvm_component parent = null);
	    super.new(name,parent);
    endfunction

	function void build_phase(uvm_phase phase);
		set_config_int(
         "env.agent",
         "is_active",
         UVM_PASSIVE
      );
		super.build_phase(phase);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

endclass

class short_incr_payload extends base_test;

	`uvm_component_utils(short_incr_payload)

	function new( string name = "short_incr_payload" , uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase", "default_sequence", yapp_incr_payload_seq::type_id::get());
		super.build_phase(phase);
		set_type_override_by_type( yapp_packet::get_type(), short_yapp_packet::get_type());
	endfunction
endclass

class exhaustive_seq_test extends base_test;
	`uvm_component_utils(exhaustive_seq_test)

	yapp_seq_lib seq_lib;

	function new(string name = "exhaustive_seq_test" , uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq_lib = yapp_seq_lib::type_id::create("seq_lib");
		seq_lib.selection_mode = UVM_SEQ_LIB_RANDC;
		seq_lib.min_random_count = 5;
      	seq_lib.max_random_count = 5;
		uvm_config_db #(uvm_sequence_base)::set(
         this,
         "env.agent.sequencer.run_phase",
         "default_sequence",
         seq_lib
      );
	  	set_type_override_by_type( yapp_packet::get_type(), short_yapp_packet::get_type());

	endfunction


	function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction
endclass


