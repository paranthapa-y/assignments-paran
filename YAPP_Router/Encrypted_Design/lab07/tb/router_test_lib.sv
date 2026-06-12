/*-----------------------------------------------------------------
File name     : router_test_lib.sv
Description   : Test sequence library defining stimulus and scenarios
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

class base_test extends uvm_test;

	`uvm_component_utils(base_test)
    //yapp_env env;
	router_tb r_tb;
	function new( string name = "base_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//env = yapp_env::type_id::create("env",this);
		r_tb = router_tb::type_id::create("r_tb", this);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

	task run_phase(uvm_phase phase);

      phase.phase_done.set_drain_time(this, 200ns);

   endtask
endclass

class simple_test extends base_test;
	`uvm_component_utils(simple_test)

	yapp_seq_lib seq_lib;

	function new(string name = "simple_test" , uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq_lib = yapp_seq_lib::type_id::create("seq_lib");
		seq_lib.selection_mode = UVM_SEQ_LIB_RANDC;
		seq_lib.min_random_count = 5;
      	seq_lib.max_random_count = 5;
		uvm_config_wrapper::set(this, "r_tb.env.agent.sequencer.run_phase","default_sequence",yapp_012_seq::type_id::get());
		uvm_config_wrapper::set(this,"r_tb.ch1.rx_agent.sequencer.run_phase","default_sequence",channel_rx_resp_seq::type_id::get());
		uvm_config_wrapper::set(this,"r_tb.ch2.rx_agent.sequencer.run_phase","default_sequence",channel_rx_resp_seq::type_id::get());
		uvm_config_wrapper::set(this,"r_tb.ch3.rx_agent.sequencer.run_phase","default_sequence",channel_rx_resp_seq::type_id::get());
	  	set_type_override_by_type( yapp_packet::get_type(), short_yapp_packet::get_type());

	endfunction


	function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction
endclass


