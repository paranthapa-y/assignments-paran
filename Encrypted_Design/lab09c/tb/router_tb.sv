
class router_tb extends uvm_component;
  `uvm_component_utils(router_tb)

  // Environment handles
  yapp_pkg::yapp_env env;
  channel_pkg::channel_env channel_env0;
  channel_pkg::channel_env channel_env1;
  channel_pkg::channel_env channel_env2;
  hbus_pkg::hbus_env hbus;

  // Virtual sequencer handle
  router_virtual_sequencer vseqr;

  // Router module env handle
  router_module_env r;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_config_int("*", "recording_detail", 1);
    super.build_phase(phase);

    // Create environments
    env = yapp_pkg::yapp_env::type_id::create("env", this);

    set_config_int("channel_env*", "has_rx", 1);
    set_config_int("channel_env*", "has_tx", 0);

    channel_env0 = channel_pkg::channel_env::type_id::create("channel_env0", this);
    channel_env1 = channel_pkg::channel_env::type_id::create("channel_env1", this);
    channel_env2 = channel_pkg::channel_env::type_id::create("channel_env2", this);

    set_config_int("hbus", "num_masters", 1);
    set_config_int("hbus", "num_slaves", 0);

    hbus = hbus_pkg::hbus_env::type_id::create("hbus", this);

    // Create virtual sequencer
    vseqr = router_virtual_sequencer::type_id::create("vseqr", this);

    // Create Router Module Environment
    r = router_module_env::type_id::create("r", this);
  endfunction
  function void connect_phase(uvm_phase phase);
    // Virtual Sequencer Connections
    vseqr.hbus_sequencer = hbus.masters[0].sequencer;
    vseqr.yapp_sequencer = env.agent.sequencer;

    // Connect the TLM ports from the YAPP and Channel UVCs to the scoreboard
    env.agent.monitor.item_collected_port.connect(r.router_yapp);
    channel_env0.rx_agent.monitor.item_collected_port.connect(r.router_chan0);
    channel_env1.rx_agent.monitor.item_collected_port.connect(r.router_chan1);
    channel_env2.rx_agent.monitor.item_collected_port.connect(r.router_chan2);
    hbus.masters[0].monitor.item_collected_port.connect(r.router_hbus);
  endfunction : connect_phase

endclass : router_tb
