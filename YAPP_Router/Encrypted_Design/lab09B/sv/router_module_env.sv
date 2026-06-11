/*-----------------------------------------------------------------
File name     : router_module_env.sv
Description   : UVM environment router_module_env composing agents, scoreboards, and reference model
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

class router_module_env extends uvm_env;
    `uvm_component_utils(router_module_env)
    router_reference refer;
    router_scoreboard sb;

    function new(string name = "router_module_env", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        refer = router_reference::type_id::create("ref", this);
        sb = router_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        refer.yapp_prt.connect(sb.yapp_imp);
    endfunction
endclass