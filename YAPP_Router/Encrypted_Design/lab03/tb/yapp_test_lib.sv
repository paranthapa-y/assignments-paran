class base_test extends uvm_test;

	`uvm_component_utils(base_test)

	function void new( string name = "base_test", uvm_componrnt parent = null);
		super.new(name,parent);
		yapp_env env;
	endfunction

	function void build_phase(uvm_phase phase);
                uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase", "default_sequence", yapp_5_packets::type_id::get());
		super.build_phase(phase);
		env = yapp_env::type_id::create(env,this);
	endfunction

	function void end_of_elaboration(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
endclass


