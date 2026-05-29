class router_tb extends uvm_component;
    `uvm_component_utils(router_tb)
    yapp_env env;

    function new(string name = "router_tb",
             uvm_component parent = null);
    super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        uvm_config_db#(int)::set( null,"*","recording_detail",1 );
        super.build_phase(phase);
        env = yapp_env::type_id::create("env", this);
    endfunction
endclass
