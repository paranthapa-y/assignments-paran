class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  router_tb route;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    route = router_tb::type_id::create("route", this);
    //  uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase", "default_sequence",
    //  yapp_pkg::yapp_5_packets::type_id::get());
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  virtual function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction : check_phase

  /*virtual task run_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 10000ns);
  endtask : run_phase*/

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this, "Starting base_test run_phase");

    // Let the simulation run for some time so default sequences can execute
    // (Or you can wait for some event, e.g., end-of-packets)
    #100000ns;

    phase.drop_objection(this, "Ending base_test run_phase");
  endtask : run_phase

endclass : base_test


class simple_test extends base_test;
  `uvm_component_utils(simple_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);



    // YAPP UVC default sequence
    uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_pkg::yapp_012_seq::type_id::get());

    // Channel UVC default sequences
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());

    // uvm_factory::get().print();



  endfunction

endclass : simple_test

//------------------------------------------------------------------------------
// test_uvc_integration
// Purpose: Demonstrates integration of HBUS + YAPP UVCs
//   - HBUS UVC programs router (MAXPKTSIZE=20, enable=1)
//   - YAPP UVC runs the all-channel sequence (1..22 payloads, 20% bad parity)
//------------------------------------------------------------------------------
class test_uvc_integration extends base_test;
  `uvm_component_utils(test_uvc_integration)

  function new(string name = "test_uvc_integration", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);


    // Channel UVC default sequences (for responses)
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    // HBUS first (program router)
    uvm_config_wrapper::set(this, "route.hbus.masters[0].sequencer.run_phase", "default_sequence",
                            hbus_pkg::hbus_small_packet_seq::type_id::get());

    // THEN YAPP stimulus
    uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_all_ch_incr_payload_seq::type_id::get());

  endfunction : build_phase

endclass : test_uvc_integration

class virtual_seq_test extends base_test;

  `uvm_component_utils(virtual_seq_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);

  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //route = router_tb::type_id::create("route", this);

    // Type override: force YAPP packets -> short_yapp_packet
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());

    // Set channel RX agents to always respond
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    // Default virtual sequencer sequence
    uvm_config_wrapper::set(this, "route.vseqr.run_phase", "default_sequence",
                            router_simple_vseq::type_id::get());


  endfunction : build_phase
endclass : virtual_seq_test

class test_router_yapp_cfg extends base_test;
  `uvm_component_utils(test_router_yapp_cfg)

  function new(string name = "test_router_yapp_cfg", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Channel RX agents (always respond)
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    // Run our YAPP config sequence on virtual sequencer
    uvm_config_wrapper::set(this, "route.vseqr.run_phase", "default_sequence",
                            router_yapp_cfg_seq::type_id::get());

  endfunction
endclass

//------------------------------------------------------------------------------
// test_router_yapp_full_flow
// Purpose:
//   - Runs the new virtual sequence that:
//       1. Configures the device
//       2. Sends packets (good parity, bad parity, bad size)
//       3. Dynamically changes max_packet_size and adapts
//       4. Sends 20–30 packets, disables DUT, waits, re-enables DUT
//------------------------------------------------------------------------------
class test_router_yapp_full_flow extends base_test;
  `uvm_component_utils(test_router_yapp_full_flow)

  function new(string name = "test_router_yapp_full_flow", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Channel RX agents (always respond)
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    // Run our NEW virtual sequence on virtual sequencer
    uvm_config_wrapper::set(this, "route.vseqr.run_phase", "default_sequence",
                            router_yapp_enable_disable_seq::type_id::get());
  endfunction
endclass

class test_router_yapp_dist extends base_test;
  `uvm_component_utils(test_router_yapp_dist)

  function new(string name = "test_router_yapp_dist", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Channel RX agents respond
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    // Run the YAPP packet distribution sequence on the virtual sequencer
    uvm_config_wrapper::set(this, "route.vseqr.run_phase", "default_sequence",
                            router_yapp_dist_seq::type_id::get());
  endfunction

endclass : test_router_yapp_dist


class test_hif_api extends base_test;
  `uvm_component_utils(test_hif_api)

  function new(string name = "test_hif_api", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual task run_phase(uvm_phase phase);
    hif_virtual_seq hif_seq;
    bit [7:0] rdata;

    phase.raise_objection(this, "run_phase");

    // Create the API sequence
    hif_seq = hif_virtual_seq::type_id::create("hif_seq");

    // Bind to sequencer (important!)
    hif_seq.start(route.hbus.masters[0].sequencer);

    // Now p_sequencer is valid, API calls will work
    hif_seq.write_hif(4'h0, 4'h1);
    #1000ns;
    hif_seq.read_hif(4'h0, rdata);

    phase.drop_objection(this, "run_phase");
  endtask
endclass : test_hif_api

