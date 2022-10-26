//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1 

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable, 

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,
 
///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus 

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,
    
output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
// 
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [15:0]  cont1_key,
input   wire    [15:0]  cont2_key,
input   wire    [15:0]  cont3_key,
input   wire    [15:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig
    
);

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
assign cart_tran_bank3 = 8'hzz;
assign cart_tran_bank3_dir = 1'b0;
assign cart_tran_bank2 = 8'hzz;
assign cart_tran_bank2_dir = 1'b0;
assign cart_tran_bank1 = 8'hzz;
assign cart_tran_bank1_dir = 1'b0;
assign cart_tran_bank0 = 4'hf;
assign cart_tran_bank0_dir = 1'b1;
assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
assign cart_tran_pin30_dir = 1'bz;
assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
assign cart_tran_pin31 = 1'bz;      // input
assign cart_tran_pin31_dir = 1'b0;  // input

// link port is input only
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign dram_a = 'h0;
assign dram_ba = 'h0;
assign dram_dq = {16{1'bZ}};
assign dram_dqm = 'h0;
assign dram_clk = 'h0;
assign dram_cke = 'h0;
assign dram_ras_n = 'h1;
assign dram_cas_n = 'h1;
assign dram_we_n = 'h1;

assign sram_a = 'h0;
assign sram_dq = {16{1'bZ}};
assign sram_oe_n  = 1;
assign sram_we_n  = 1;
assign sram_ub_n  = 1;
assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;


// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
    default: begin
        bridge_rd_data <= 0;
    end
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    endcase
    if (bridge_addr[31:28] == 4'h2) begin
      bridge_rd_data <= sd_read_data;
    end
end


//
// host/target command handler
//
    wire            reset_n;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;
    
// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked; 
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_allcomplete;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;
    
    wire            osnotify_inmenu;
    wire    [31:0]  osnotify_rtc;

// bridge target commands
// synchronous to clk_74a


// bridge data slot access

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),
    
    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),
    .osnotify_rtc           ( osnotify_rtc ),
    
    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q ),

);

///////////////////////////////////////////////
// System
///////////////////////////////////////////////

wire osnotify_inmenu_s;

synch_3 OSD_S (osnotify_inmenu, osnotify_inmenu_s, clk_sys);

///////////////////////////////////////////////
// ROM
///////////////////////////////////////////////

reg         ioctl_download = 0;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
reg   [7:0] ioctl_index = 0;

always @(posedge clk_74a) begin
    if (dataslot_requestwrite)     ioctl_download <= 1;
    else if (dataslot_allcomplete) ioctl_download <= 0;
end

data_loader #(
    .ADDRESS_MASK_UPPER_4(4'h1),
    .ADDRESS_SIZE(25)
) rom_loader (
    .clk_74a(clk_74a),
    .clk_memory(clk_sys),

    .bridge_wr(bridge_wr),
    .bridge_endian_little(bridge_endian_little),
    .bridge_addr(bridge_addr),
    .bridge_wr_data(bridge_wr_data),

    .write_en(ioctl_wr),
    .write_addr(ioctl_addr),
    .write_data(ioctl_dout)
);

///////////////////////////////////////////////
// High Score
///////////////////////////////////////////////

wire [31:0] sd_read_data;

wire sd_rd;
wire sd_wr;

wire [15:0] sd_buff_addr = sd_wr ? sd_buff_addr_in : sd_buff_addr_out;
wire [15:0] sd_buff_addr_in;
wire [15:0] sd_buff_addr_out;
wire [7:0]  sd_buff_din;
wire [7:0]  sd_buff_dout;

wire [15:0] hs_address;
wire  [7:0] hs_data_in;
wire  [7:0] hs_data_out;
wire        hs_write_enable;
wire        hs_access_read;
wire        hs_access_write;
wire        hs_pause;
wire        hs_configured;

pause #(4,4,4,25) pause (
  .clk_sys(clk_sys),
  .reset(~reset_n),
  .OSD_STATUS(osnotify_inmenu_s),
  .pause_cpu(pause_cpu)
);

hiscore #(
	.HS_ADDRESSWIDTH(16),
	.HS_SCOREWIDTH(8),			// 241 bytes
	.CFG_ADDRESSWIDTH(4),		// 8 entries
	.CFG_LENGTHWIDTH(2)
) hi (
	.clk(clk_sys),
	.paused(pause_cpu),
    .reset(~reset_n),
	.autosave(1),

    .ioctl_upload(sd_rd),
    .ioctl_upload_req(),
    .ioctl_download(ioctl_download),
    .ioctl_wr(sd_wr),
    .ioctl_addr(sd_buff_addr),
    .ioctl_index(bridge_addr[31:28] == 4'h2 ? 3 : 4),

    .OSD_STATUS(osnotify_inmenu_s),

	.data_from_hps(sd_buff_dout),
    .data_from_ram(hs_data_out),

	.ram_address(hs_address),

	.data_to_hps(sd_buff_din),
    .data_to_ram(hs_data_in),

	.ram_write(hs_write_enable),
	.ram_intent_read(hs_access_read),
	.ram_intent_write(hs_access_write),

	.pause_cpu(hs_pause),
	.configured(hs_configured),
);

data_unloader #(
	.ADDRESS_MASK_UPPER_4(4'h2),
	.ADDRESS_SIZE(16)
) save_data_unloader (
	.clk_74a(clk_74a),
	.clk_memory(clk_sys),

	.bridge_rd(bridge_rd),
	.bridge_endian_little(bridge_endian_little),
	.bridge_addr(bridge_addr),
	.bridge_rd_data(sd_read_data),

	.read_en  (sd_rd),
	.read_addr(sd_buff_addr_out),
	.read_data(sd_buff_din)
);

data_loader #(
	.ADDRESS_MASK_UPPER_4(4'h2),
	.ADDRESS_SIZE(16)
) save_data_loader (
	.clk_74a(clk_74a),
	.clk_memory(clk_sys),

	.bridge_wr(bridge_wr),
	.bridge_endian_little(bridge_endian_little),
	.bridge_addr(bridge_addr),
	.bridge_wr_data(bridge_wr_data),

	.write_en  (sd_wr),
	.write_addr(sd_buff_addr_in),
	.write_data(sd_buff_dout)
);

reg [ 2:0] datatable_div = 0;
reg [31:0] rom_file_size = 0;

always @(posedge clk_74a or negedge pll_core_locked) begin
	if (~pll_core_locked) begin
		datatable_addr <= 0;
		datatable_data <= 0;
		datatable_wren <= 0;
	end else begin
		if (datatable_div > 4) begin
			// Write sram size half of the time
			datatable_wren <= 1;
			// sram_size is the size of the config value in the ROM. Convert to actual size
			datatable_data <= 32'd65536;
			// Data slot index 1, not id 1
			datatable_addr <= 1 * 2 + 1;
		end else begin
			datatable_wren <= 0;
			// Read ROM size rest of the time
			datatable_addr <= 1;
			if (datatable_div == 4) begin
				rom_file_size <= datatable_q;
			end
		end
		datatable_div <= datatable_div + 1;
	end
end

///////////////////////////////////////////////
// Video
///////////////////////////////////////////////

wire hblank_core, vblank_core;
wire hs_core_n, vs_core_n;
wire [3:0] r, g, b;

reg video_de_reg;
reg video_hs_reg;
reg video_vs_reg;
reg [23:0] video_rgb_reg;

reg hs_prev;
reg vs_prev;

assign video_rgb_clock = clk_core_6_1436;
assign video_rgb_clock_90 = clk_core_6_1436_90deg;

assign video_de = video_de_reg;
assign video_hs = video_hs_reg;
assign video_vs = video_vs_reg;
assign video_rgb = video_rgb_reg;
assign video_skip = 0;

always @(posedge clk_core_6_1436) begin
    video_de_reg <= 0;

    if (~(vblank_core || hblank_core)) begin
        video_de_reg <= 1;
        video_rgb_reg[23:16] <= {2{r}};
        video_rgb_reg[15:8]  <= {2{g}};
        video_rgb_reg[7:0]   <= {2{b}};
    end

    video_hs_reg <= ~hs_prev && ~hs_core_n;
    video_vs_reg <= ~vs_prev && ~vs_core_n;
    hs_prev <= ~hs_core_n;
    vs_prev <= ~vs_core_n;
end

assign hblank_core = hbl[8];

wire clk_pix;
wire hbl0;
reg [8:0] hbl;
always @(posedge clk_sys) begin
	reg old_pix;
	old_pix <= clk_pix;
	if(~old_pix & clk_pix) begin
		hbl <= (hbl<<1)|hbl0;
	end
end

///////////////////////////////////////////////
// Audio
///////////////////////////////////////////////

wire [15:0] audio;

sound_i2s #(
    .CHANNEL_WIDTH(15),
    .SIGNED_INPUT (0)
) sound_i2s (
    .clk_74a(clk_74a),
    .clk_audio(clk_sys),
    
    .audio_l(audio[15:1]),
    .audio_r(audio[15:1]),

    .audio_mclk(audio_mclk),
    .audio_lrck(audio_lrck),
    .audio_dac(audio_dac)
);

///////////////////////////////////////////////
// Control
///////////////////////////////////////////////

wire [15:0] joy;
wire [15:0] joy2;

synch_3 #(
    .WIDTH(16)
) cont1_key_s (
    cont1_key,
    joy,
    clk_sys
);

synch_3 #(
    .WIDTH(16)
) cont2_key_s (
    cont2_key,
    joy2,
    clk_sys
);

wire m_up_2     = joy2[0];
wire m_down_2   = joy2[1];
wire m_left_2   = joy2[2];
wire m_right_2  = joy2[3];
wire m_fire_2   = joy2[4];

wire m_up     = joy[0];
wire m_down   = joy[1];
wire m_left   = joy[2];
wire m_right  = joy[3];
wire m_fire   = joy[4];

wire m_start1 =  joy[15];
wire m_start2 =  joy2[15];
wire m_coin   =  joy[14] | joy2[14];
wire m_pause   = joy[8] | joy2[8];

///////////////////////////////////////////////
// Instance
///////////////////////////////////////////////

wire pause_cpu;

reg mod_dk = 0; // unused
reg mod_dkjr = 0;
reg mod_dk3 = 0;
reg mod_radarscope = 1;
reg mod_pestplace = 0;

wire reset = ~reset_n | ioctl_download;

wire [15:0] main_rom_a;
wire [7:0] main_rom_do;
wire [11:0] sub_rom_a;
wire [7:0] sub_rom_do;
wire [18:0] wav_rom_a;
wire [7:0] wav_rom_do;

dpram #(15,8) cpu_rom (
	.clock_a(clk_sys),
	.address_a(main_rom_a[14:0]),
	.q_a(main_rom_do),

	.clock_b(clk_sys),
	.address_b(ioctl_addr[14:0]),
	.wren_b(ioctl_wr && ioctl_download && (ioctl_addr < 'd32768) && !ioctl_index),
	.data_b(ioctl_dout)
);

dpram #(12,8) snd_rom (
	.clock_a(clk_sys),
	.address_a(sub_rom_a[11:0]),
	.q_a(sub_rom_do),

	.clock_b(clk_sys),
	.address_b(ioctl_addr[11:0]),
	.wren_b(ioctl_wr && ioctl_download && (ioctl_addr < 'hF000 && ioctl_addr >= 'hE000) && !ioctl_index),
	.data_b(ioctl_dout)
);

dpram #(16,8) wav_rom (
    .clock_a(clk_sys),
    .address_a(wav_rom_a[15:0]),
    .q_a(wav_rom_do),

    .clock_b(clk_sys),
    .address_b(ioctl_addr[15:0]),
    .wren_b(ioctl_wr && ioctl_download && (ioctl_addr >= 'hFF00) && !ioctl_index),
    .data_b(ioctl_dout)
);

dkong_top dkong(				   
    .I_CLK_24576M(clk_sys),
    .I_RESETn(~reset),
    .I_U1(~m_up),
    .I_D1(~m_down),
    .I_L1(~m_left),
    .I_R1(~m_right),
    .I_J1(~m_fire),

    .I_U2(~m_up_2),
    .I_D2(~m_down_2),
    .I_L2(~m_left_2),
    .I_R2(~m_right_2),
    .I_J2(~m_fire_2),

    .I_S1(~m_start1),
    .I_S2(~m_start2),
    .I_C1(~m_coin),

    .I_DIP_SW(0),

    .I_DKJR(mod_dkjr|mod_pestplace|mod_dk3),
    .I_DK3B(mod_dk3),
    .I_RADARSCP(mod_radarscope),
    .I_PESTPLCE(mod_pestplace),

    .O_PIX(clk_pix),

    .flip_screen(0),
    .H_OFFSET(0),
    .V_OFFSET(0),

    .O_SOUND_DAT(audio),
    .O_VGA_R(r),
    .O_VGA_G(g),
    .O_VGA_B(b),
    .O_H_BLANK(hbl0),
    .O_V_BLANK(vblank_core),
    .O_VGA_H_SYNCn(hs_core_n),
    .O_VGA_V_SYNCn(vs_core_n),

    .DL_ADDR(ioctl_addr[15:0]),
    .DL_WR(ioctl_wr && ioctl_addr[23:16] == 0 && !ioctl_index),
    .DL_DATA(ioctl_dout),
    .MAIN_CPU_A(main_rom_a),
    .MAIN_CPU_DO(main_rom_do),
    .SND_ROM_A(sub_rom_a),
    .SND_ROM_DO(sub_rom_do),
    .WAV_ROM_A(wav_rom_a),
    .WAV_ROM_DO(wav_rom_do),

    .paused(pause_cpu),

    .hs_address(hs_address),
    .hs_data_in(hs_data_in),
    .hs_data_out(hs_data_out),
    .hs_write(hs_write_enable),
    .hs_access(hs_access_read|hs_access_write)
);

///////////////////////////////////////////////
// Clocks
///////////////////////////////////////////////

wire    clk_core_6_1436;
wire    clk_core_6_1436_90deg;
wire    clk_sys;

wire    pll_core_locked;
    
mf_pllbase mp1 (
    .refclk         ( clk_74a ),
    .rst            ( 0 ),

    .outclk_0       ( clk_core_6_1436 ),
    .outclk_1       ( clk_core_6_1436_90deg ),
    .outclk_2       ( clk_sys ),

    .locked         ( pll_core_locked )
);

    
endmodule
