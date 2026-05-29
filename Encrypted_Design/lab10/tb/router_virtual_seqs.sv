import uvm_pkg::*;

// include the UVM macros
`include "uvm_macros.svh"


class router_simple_vseq extends uvm_sequence;

  `uvm_object_utils(router_simple_vseq)
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  // YAPP packets sequences
  yapp_pkg::six_yapp_seq              six_yapp;
  yapp_pkg::yapp_012_seq              yapp_012;

  // HBUS sequences
  hbus_pkg::hbus_small_packet_seq     hbus_small_pkt_seq;
  hbus_pkg::hbus_read_max_pkt_seq     hbus_rd_seq;
  hbus_pkg::hbus_set_default_regs_seq hbus_large_pkt_seq;


  function new(string name = "router_simple_vseq");
    super.new(name);
  endfunction : new

  virtual task body();
    starting_phase.raise_objection(this, get_type_name());

    `uvm_info("router_simple_vseq", "Executing router_simple_vseq", UVM_LOW)
    // Configure for small packets
    `uvm_do_on(hbus_small_pkt_seq, p_sequencer.hbus_sequencer)
    // Read the YAPP MAXPKTSIZE register (address 0)
    `uvm_do_on(hbus_rd_seq, p_sequencer.hbus_sequencer)
    // send 6 consecutive packets to addresses 0,1,2, cycling the address
    `uvm_do_on(yapp_012, p_sequencer.yapp_sequencer)
    `uvm_do_on(yapp_012, p_sequencer.yapp_sequencer)
    // Configure for large packets (default)
    `uvm_do_on(hbus_large_pkt_seq, p_sequencer.hbus_sequencer)
    // Read the YAPP MAXPKTSIZE register (address 0)
    `uvm_do_on(hbus_rd_seq, p_sequencer.hbus_sequencer)
    // Send 5 random packets
    `uvm_do_on(six_yapp, p_sequencer.yapp_sequencer)
    starting_phase.drop_objection(this, get_type_name());

  endtask : body



endclass : router_simple_vseq


class router_yapp_cfg_seq extends uvm_sequence #(yapp_packet);
  `uvm_object_utils(router_yapp_cfg_seq)
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  // HBUS sequences (handles)
  hbus_pkg::hbus_set_yapp_regs_seq cfg_seq;
  hbus_pkg::hbus_read_max_pkt_seq rd_seq;

  // config read value
  int unsigned max_pkt_size;
  int unsigned upto;

  function new(string name = "router_yapp_cfg_seq");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;
    int k = 0;
    int N = 3;  // number of dynamic changes

    starting_phase.raise_objection(this, get_type_name());
    `uvm_info(get_type_name(), "=== Starting YAPP configuration sequence ===", UVM_LOW)

    // We'll do N iterations of dynamic max_pkt_size updates

    for (int iter = 0; iter < N; iter++) begin

      // -----------------------------------------------------------------
      // 1) Configure router registers via HBUS (update max_pkt_size)
      // -----------------------------------------------------------------
      cfg_seq = hbus_pkg::hbus_set_yapp_regs_seq::type_id::create($sformatf("cfg_seq_%0d", iter));
      // Example: random new max size in range [5, 25]
      cfg_seq.max_pkt_reg = $urandom_range(5, 25);
      `uvm_do_on(cfg_seq, p_sequencer.hbus_sequencer)

      // -----------------------------------------------------------------
      // 2) Read back current MAX packet size
      // -----------------------------------------------------------------
      rd_seq = hbus_pkg::hbus_read_max_pkt_seq::type_id::create($sformatf("rd_seq_%0d", iter));
      `uvm_do_on(rd_seq, p_sequencer.hbus_sequencer);
      max_pkt_size = rd_seq.max_pkt_reg;
      `uvm_info(get_type_name(), $sformatf(
                "Iteration %0d: Max packet size configured: %0d", iter, max_pkt_size), UVM_LOW)

      // -----------------------------------------------------------------
      // 3) Send packets (good, bad parity, bad size)
      // -----------------------------------------------------------------
      for (int size = max_pkt_size - 1; size <= max_pkt_size + 1; size++) begin
        for (int ch = 0; ch < 3; ch++) begin
          `uvm_do_on_with(pkt, p_sequencer.yapp_sequencer,
                          {
            addr   == ch[1:0];
            length == size;
          })
          k++;
          pkt.payload = new[size];
          if (k % 2) pkt.parity = pkt.calc_parity();  // good parity
          else pkt.parity = ~pkt.calc_parity();  // bad parity
        end
      end
    end

    starting_phase.drop_objection(this, get_type_name());
  endtask
endclass : router_yapp_cfg_seq

class router_yapp_enable_disable_seq extends uvm_sequence #(yapp_packet);
  `uvm_object_utils(router_yapp_enable_disable_seq)
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  // HBUS sequences
  hbus_pkg::hbus_set_yapp_regs_seq cfg_seq;
  yapp_pkg::yapp_012_seq           yapp_012;

  function new(string name = "router_yapp_enable_disable_seq");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;
    int num_pkts;

    starting_phase.raise_objection(this, get_type_name());
    `uvm_info(get_type_name(), "=== Starting Enable/Disable DUT sequence ===", UVM_LOW)

    cfg_seq = hbus_pkg::hbus_set_yapp_regs_seq::type_id::create("enable_seq");

    `uvm_do_on_with(cfg_seq, p_sequencer.hbus_sequencer, { enable_reg == 1; })


    // --------------------------------------------------------
    // 1) Send 20–30 random packets
    // --------------------------------------------------------
    num_pkts = $urandom_range(7, 10);
    for (int i = 0; i < num_pkts; i++) begin
      `uvm_do_on(yapp_012, p_sequencer.yapp_sequencer)

    end
    `uvm_info(get_type_name(), $sformatf("Sent %0d packets before disabling DUT", num_pkts * 3),
              UVM_LOW)

    // --------------------------------------------------------
    // 2) Disable DUT (write enable_reg = 0)
    // --------------------------------------------------------
    cfg_seq = hbus_pkg::hbus_set_yapp_regs_seq::type_id::create("disable_seq");

    `uvm_do_on_with(cfg_seq, p_sequencer.hbus_sequencer, { enable_reg == 0; })
    `uvm_info(get_type_name(), "DUT disabled", UVM_LOW)

    num_pkts = $urandom_range(2, 4);
    for (int i = 0; i < 2; i++) begin
      `uvm_do_on(yapp_012, p_sequencer.yapp_sequencer)

    end
    `uvm_info(get_type_name(), $sformatf("Sent %0d packets after disabling DUT", num_pkts * 3),
              UVM_LOW)

    #1000ns;
    // --------------------------------------------------------
    // 4) Re-enable DUT (write enable_reg = 1)
    // --------------------------------------------------------
    cfg_seq = hbus_pkg::hbus_set_yapp_regs_seq::type_id::create("enable_seq");

    `uvm_do_on_with(cfg_seq, p_sequencer.hbus_sequencer, { enable_reg == 1; })
    `uvm_info(get_type_name(), "DUT re-enabled", UVM_LOW)

    // --------------------------------------------------------
    // 5) Send additional packets to verify DUT operation
    // --------------------------------------------------------
    num_pkts = $urandom_range(5, 10);

    for (int i = 0; i < num_pkts; i++) begin
      `uvm_do_on(yapp_012, p_sequencer.yapp_sequencer)
      // good parity
    end
    `uvm_info(get_type_name(), $sformatf("Sent %0d packets after re-enabling DUT", num_pkts * 3),
              UVM_LOW)

    starting_phase.drop_objection(this, get_type_name());
  endtask
endclass : router_yapp_enable_disable_seq

class router_yapp_dist_seq extends uvm_sequence #(yapp_packet);
  `uvm_object_utils(router_yapp_dist_seq)
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  // HBUS sequence handles
  hbus_pkg::hbus_set_yapp_regs_seq cfg_seq;
  hbus_pkg::hbus_read_max_pkt_seq rd_seq;

  // YAPP packet sequence handle
  yapp_packet pkt;

  int unsigned max_pkt_size;
  int N;  // total number of packets

  function new(string name = "router_yapp_dist_seq");
    super.new(name);
    N = $urandom_range(50, 100);  // total packets
  endfunction

  virtual task body();
    int num_lt    = (N*20)/100;  // < max-2
    int num_eqm1  = (N*30)/100;  // max-1
    int num_eq    = (N*30)/100;  // max
    int num_gt    = N - (num_lt + num_eqm1 + num_eq); // remaining > max

    // --------------------------------------------------------
    // 4) Build array of packet sizes
    // --------------------------------------------------------


    int unsigned pkt_sizes[$];
    starting_phase.raise_objection(this, get_type_name());
    `uvm_info(get_type_name(),
              $sformatf("=== Starting packet distribution sequence, N=%0d ===", N), UVM_LOW)
    //  ----------------------------------------------------
    // 1) Configure max packet size register
    // --------------------------------------------------------

    cfg_seq = hbus_pkg::hbus_set_yapp_regs_seq::type_id::create("enable_seq");

    `uvm_do_on_with(cfg_seq, p_sequencer.hbus_sequencer,
                    { enable_reg == 1; max_pkt_reg inside {[5:25]}; })
    `uvm_info(get_type_name(), "DUT re-enabled", UVM_LOW)



    // --------------------------------------------------------
    // 2) Read back max packet size
    // --------------------------------------------------------
    rd_seq = hbus_pkg::hbus_read_max_pkt_seq::type_id::create("rd_seq");
    `uvm_do_on(rd_seq, p_sequencer.hbus_sequencer)
    max_pkt_size = rd_seq.max_pkt_reg;
    `uvm_info(get_type_name(), $sformatf("Configured max packet size: %0d", max_pkt_size), UVM_LOW)

    // --------------------------------------------------------
    // 3) Precompute exact distribution counts
    // --------------------------------------------------------
    for (int i = 0; i < num_lt; i++) pkt_sizes.push_back($urandom_range(1, max_pkt_size - 2));
    for (int i = 0; i < num_eqm1; i++) pkt_sizes.push_back(max_pkt_size - 1);
    for (int i = 0; i < num_eq; i++) pkt_sizes.push_back(max_pkt_size);
    for (int i = 0; i < num_gt; i++) pkt_sizes.push_back(max_pkt_size + $urandom_range(1, 5));

    // --------------------------------------------------------
    // 5) Shuffle the array randomly
    // --------------------------------------------------------
    pkt_sizes.shuffle();

    // --------------------------------------------------------
    // 6) Send packets using the shuffled sizes
    // --------------------------------------------------------
    foreach (pkt_sizes[i]) begin
      `uvm_do_on_with(pkt, p_sequencer.yapp_sequencer,
                      {
        length == pkt_sizes[i];
        addr   inside {[0:2]};
      })
      pkt.payload = new[pkt.length];
      pkt.parity  = pkt.calc_parity();
    end

    `uvm_info(get_type_name(), $sformatf("Sent %0d packets according to distribution",
                                         pkt_sizes.size()), UVM_LOW)
    starting_phase.drop_objection(this, get_type_name());
  endtask

endclass : router_yapp_dist_seq


class hif_virtual_seq extends uvm_sequence #(hbus_transaction);
  `uvm_object_utils(hif_virtual_seq)
  `uvm_declare_p_sequencer(hbus_master_sequencer)

  hbus_transaction trans;

  function new(string name = "hif_virtual_seq");
    super.new(name);
  endfunction

  // -------------------------------
  // API for writing to HIF
  // -------------------------------
  task write_hif(bit [7:0] addr, bit [7:0] data);
    trans = hbus_transaction::type_id::create("trans");
    `uvm_do_with(trans, { trans.haddr == addr; trans.hdata == data; trans.hwr_rd == HBUS_WRITE; })
    `uvm_info(get_type_name(), $sformatf("HIF WRITE Addr:%0h Data:%0h", addr, data), UVM_MEDIUM)
  endtask

  // -------------------------------
  // API for reading from HIF
  // -------------------------------
  task read_hif(bit [7:0] addr, output bit [7:0] data);
    trans = hbus_transaction::type_id::create("trans");
    `uvm_do_with(trans, { trans.haddr == addr; trans.hwr_rd == HBUS_READ; })
    data = trans.hdata;
    `uvm_info(get_type_name(), $sformatf("HIF READ Addr:%0h Data:%0h", addr, data), UVM_MEDIUM)
  endtask



endclass : hif_virtual_seq


