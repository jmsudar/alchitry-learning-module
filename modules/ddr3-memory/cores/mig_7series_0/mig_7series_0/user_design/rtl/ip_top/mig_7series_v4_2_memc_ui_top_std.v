//*****************************************************************************
// (c) Copyright 2023 Advanced Micro Devices, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : AMD
// \   \   \/     Version            : 3.6
//  \   \         Application        : MIG
//  /   /         Filename           : memc_ui_top_std.v
// /___/   /\     Date Last Modified : $Date: 2011/06/17 11:11:25 $
// \   \  /  \    Date Created       : Fri Oct 08 2010
//  \___\/\___\
//
// Device           : 7 Series
// Design Name      : DDR2 SDRAM & DDR3 SDRAM
// Purpose          :
//                   Top level memory interface block. Instantiates a clock and
//                   reset generator, the memory controller, the phy and the
//                   user interface blocks.
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1 ps / 1 ps

(* X_CORE_INFO = "mig_7series_v4_2_ddr3_7Series, mig_7series_0, 2018.3" , CORE_GENERATION_INFO = "ddr3_7Series,mig_7series_v4_2,{LANGUAGE=Verilog, SYNTHESIS_TOOL=Vivado, LEVEL=CONTROLLER, AXI_ENABLE=0, NO_OF_CONTROLLERS=1, INTERFACE_TYPE=DDR3, AXI_ENABLE=0, CLK_PERIOD=2500, PHY_RATIO=4, CLKIN_PERIOD=10000, VCCAUX_IO=1.8V, MEMORY_TYPE=COMP, MEMORY_PART=mt41k128m16jt-125, DQ_WIDTH=16, ECC=OFF, DATA_MASK=1, ORDERING=STRICT, BURST_MODE=8, BURST_TYPE=SEQ, CA_MIRROR=OFF, OUTPUT_DRV=HIGH, USE_CS_PORT=1, USE_ODT_PORT=1, RTT_NOM=60, MEMORY_ADDRESS_MAP=BANK_ROW_COLUMN, REFCLK_FREQ=200, DEBUG_PORT=OFF, INTERNAL_VREF=1, SYSCLK_TYPE=NO_BUFFER, REFCLK_TYPE=NO_BUFFER}" *)
module mig_7series_v4_2_memc_ui_top_std #
  (
   parameter TCQ                   = 100,
   parameter DDR3_VDD_OP_VOLT      = "135",     // Voltage mode used for DDR3
   parameter PAYLOAD_WIDTH         = 64,
   parameter ADDR_CMD_MODE         = "UNBUF",
   parameter AL                    = "0",     // Additive Latency option
   parameter BANK_WIDTH            = 3,       // # of bank bits
   parameter BM_CNT_WIDTH          = 2,       // Bank machine counter width
   parameter BURST_MODE            = "8",     // Burst length
   parameter BURST_TYPE            = "SEQ",   // Burst type
   parameter CA_MIRROR             = "OFF",   // C/A mirror opt for DDR3 dual rank
   parameter CK_WIDTH              = 1,       // # of CK/CK# outputs to memory
   parameter CL                    = 5,
   parameter COL_WIDTH             = 12,      // column address width
   parameter CMD_PIPE_PLUS1        = "ON",    // add pipeline stage between MC and PHY
   parameter CS_WIDTH              = 1,       // # of unique CS outputs
   parameter CKE_WIDTH             = 1,       // # of cke outputs
   parameter CWL                   = 5,
   parameter DATA_WIDTH            = 64,
   parameter DATA_BUF_ADDR_WIDTH   = 5,
   parameter DATA_BUF_OFFSET_WIDTH = 1,
   parameter DDR2_DQSN_ENABLE      = "YES",   // Enable differential DQS for DDR2
   parameter DM_WIDTH              = 8,       // # of DM (data mask)
   parameter DQ_CNT_WIDTH          = 6,       // = ceil(log2(DQ_WIDTH))
   parameter DQ_WIDTH              = 64,      // # of DQ (data)
   parameter DQS_CNT_WIDTH         = 3,       // = ceil(log2(DQS_WIDTH))
   parameter DQS_WIDTH             = 8,       // # of DQS (strobe)
   parameter DRAM_TYPE             = "DDR3",
   parameter DRAM_WIDTH            = 8,       // # of DQ per DQS
   parameter ECC                   = "OFF",
   parameter ECC_WIDTH             = 8,
   parameter ECC_TEST              = "OFF",
   parameter MC_ERR_ADDR_WIDTH     = 31,
   parameter MASTER_PHY_CTL        = 0,       // The bank number where master PHY_CONTROL resides
   parameter nAL                   = 0,       // Additive latency (in clk cyc)
   parameter nBANK_MACHS           = 4,
   parameter nCK_PER_CLK           = 2,       // # of memory CKs per fabric CLK
   parameter nCS_PER_RANK          = 1,       // # of unique CS outputs per rank
   parameter ORDERING              = "NORM",
   parameter IBUF_LPWR_MODE        = "OFF",
   parameter BANK_TYPE             = "HP_IO", // # = "HP_IO", "HPL_IO", "HR_IO", "HRL_IO"
   parameter DATA_IO_PRIM_TYPE     = "DEFAULT", // # = "HP_LP", "HR_LP", "DEFAULT"
   parameter DATA_IO_IDLE_PWRDWN   = "ON",  // "ON" or "OFF"
   parameter IODELAY_GRP0          = "IODELAY_MIG0",
   parameter IODELAY_GRP1          = "IODELAY_MIG1",
   parameter FPGA_SPEED_GRADE      = 1,
   parameter OUTPUT_DRV            = "HIGH",
   parameter REG_CTRL              = "OFF",
   parameter RTT_NOM               = "60",
   parameter RTT_WR                = "120",
   parameter STARVE_LIMIT          = 2,
   parameter tCK                   = 2500,         // pS
   parameter tCKE                  = 10000,        // pS
   parameter tFAW                  = 40000,        // pS
   parameter tPRDI                 = 1_000_000,    // pS
   parameter tRAS                  = 37500,        // pS
   parameter tRCD                  = 12500,        // pS
   parameter tREFI                 = 7800000,      // pS
   parameter tRFC                  = 110000,       // pS
   parameter tRP                   = 12500,        // pS
   parameter tRRD                  = 10000,        // pS
   parameter tRTP                  = 7500,         // pS
   parameter tWTR                  = 7500,         // pS
   parameter tZQI                  = 128_000_000,  // nS
   parameter tZQCS                 = 64,           // CKs
   parameter USER_REFRESH          = "OFF",        // Whether user manages REF
   parameter TEMP_MON_EN           = "ON",         // Enable/Disable tempmon
   parameter WRLVL                 = "OFF",
   parameter DEBUG_PORT            = "OFF",
   parameter CAL_WIDTH             = "HALF",
   parameter RANK_WIDTH            = 1,
   parameter RANKS                 = 4,
   parameter ODT_WIDTH             = 1,
   parameter ROW_WIDTH             = 16,       // DRAM address bus width
   parameter ADDR_WIDTH            = 32,
   parameter APP_MASK_WIDTH        = 8,
   parameter APP_DATA_WIDTH        = 64,
   parameter [3:0] BYTE_LANES_B0         = 4'b1111,
   parameter [3:0] BYTE_LANES_B1         = 4'b1111,
   parameter [3:0] BYTE_LANES_B2         = 4'b1111,
   parameter [3:0] BYTE_LANES_B3         = 4'b1111,
   parameter [3:0] BYTE_LANES_B4         = 4'b1111,
   parameter [3:0] DATA_CTL_B0           = 4'hc,
   parameter [3:0] DATA_CTL_B1           = 4'hf,
   parameter [3:0] DATA_CTL_B2           = 4'hf,
   parameter [3:0] DATA_CTL_B3           = 4'h0,
   parameter [3:0] DATA_CTL_B4           = 4'h0,
   parameter [47:0] PHY_0_BITLANES  = 48'h0000_0000_0000,
   parameter [47:0] PHY_1_BITLANES  = 48'h0000_0000_0000,
   parameter [47:0] PHY_2_BITLANES  = 48'h0000_0000_0000,

   // control/address/data pin mapping parameters
   parameter [143:0] CK_BYTE_MAP
     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00,
   parameter [191:0] ADDR_MAP
     = 192'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000,
   parameter [35:0] BANK_MAP   = 36'h000_000_000,
   parameter [11:0] CAS_MAP    = 12'h000,
   parameter [7:0] CKE_ODT_BYTE_MAP = 8'h00,
   parameter [95:0] CKE_MAP    = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] ODT_MAP    = 96'h000_000_000_000_000_000_000_000,
   parameter CKE_ODT_AUX = "FALSE",
   parameter [119:0] CS_MAP     = 120'h000_000_000_000_000_000_000_000_000_000,
   parameter [11:0] PARITY_MAP = 12'h000,
   parameter [11:0] RAS_MAP    = 12'h000,
   parameter [11:0] WE_MAP     = 12'h000,
   parameter [143:0] DQS_BYTE_MAP
     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00,
   parameter [95:0] DATA0_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA1_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA2_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA3_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA4_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA5_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA6_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA7_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA8_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA9_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA10_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA11_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA12_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA13_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA14_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA15_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA16_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter [95:0] DATA17_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter [107:0] MASK0_MAP  = 108'h000_000_000_000_000_000_000_000_000,
   parameter [107:0] MASK1_MAP  = 108'h000_000_000_000_000_000_000_000_000,

   parameter [7:0] SLOT_0_CONFIG         = 8'b0000_0001,
   parameter [7:0] SLOT_1_CONFIG         = 8'b0000_0000,
   parameter MEM_ADDR_ORDER        = "BANK_ROW_COLUMN",
   // calibration Address. The address given below will be used for calibration
   // read and write operations.
   parameter [15:0] CALIB_ROW_ADD         = 16'h0000, // Calibration row address
   parameter [11:0] CALIB_COL_ADD         = 12'h000,  // Calibration column address
   parameter [2:0] CALIB_BA_ADD          = 3'h0,     // Calibration bank address
   parameter SIM_BYPASS_INIT_CAL   = "OFF",
   parameter REFCLK_FREQ           = 300.0,
   parameter USE_CS_PORT           = 1,        // Support chip select output
   parameter USE_DM_PORT           = 1,        // Support data mask output
   parameter USE_ODT_PORT          = 1,        // Support ODT output
   parameter IDELAY_ADJ            = "ON",     //ON : IDELAY-1, OFF: No change
   parameter FINE_PER_BIT          = "ON",     //ON : Use per bit calib for complex rdlvl
   parameter CENTER_COMP_MODE      = "ON",     //ON: use PI stg2 tap compensation
   parameter PI_VAL_ADJ            = "ON",     //ON: PI stg2 tap -1 for centering
   parameter SKIP_CALIB            = "FALSE",
   parameter TAPSPERKCLK           = 56,
   parameter FPGA_VOLT_TYPE        = "N"
  )
  (
   // Clock and reset ports
   input                              clk,
   input                              clk_div2,
   input                              rst_div2,
   input [1:0]                        clk_ref,
   input                              mem_refclk ,
   input                              freq_refclk ,
   input                              pll_lock,
   input                              sync_pulse ,
   input                              mmcm_ps_clk,
   input                              poc_sample_pd,

   input                              rst,

   // memory interface ports
   inout [DQ_WIDTH-1:0]               ddr_dq,
   inout [DQS_WIDTH-1:0]              ddr_dqs_n,
   inout [DQS_WIDTH-1:0]              ddr_dqs,
   output [ROW_WIDTH-1:0]             ddr_addr,
   output [BANK_WIDTH-1:0]            ddr_ba,
   output                             ddr_cas_n,
   output [CK_WIDTH-1:0]              ddr_ck_n,
   output [CK_WIDTH-1:0]              ddr_ck,
   output [CKE_WIDTH-1:0]             ddr_cke,
   output [CS_WIDTH*nCS_PER_RANK-1:0] ddr_cs_n,
   output [DM_WIDTH-1:0]              ddr_dm,
   output [ODT_WIDTH-1:0]             ddr_odt,
   output                             ddr_ras_n,
   output                             ddr_reset_n,
   output                             ddr_parity,
   output                             ddr_we_n,

   output [BM_CNT_WIDTH-1:0]          bank_mach_next,

   // user interface ports
   input [ADDR_WIDTH-1:0]             app_addr,
   input [2:0]                        app_cmd,
   input                              app_en,
   input                              app_hi_pri,
   input [APP_DATA_WIDTH-1:0]         app_wdf_data,
   input                              app_wdf_end,
   input [APP_MASK_WIDTH-1:0]         app_wdf_mask,
   input                              app_wdf_wren,
   input                              app_correct_en_i,
   input [2*nCK_PER_CLK-1:0]          app_raw_not_ecc,
   output [2*nCK_PER_CLK-1:0]         app_ecc_multiple_err,
   output [2*nCK_PER_CLK-1:0]         app_ecc_single_err,
   output [APP_DATA_WIDTH-1:0]        app_rd_data,
   output                             app_rd_data_end,
   output                             app_rd_data_valid,
   output                             app_rdy,
   output                             app_wdf_rdy,

   input                              app_sr_req,
   output                             app_sr_active,
   input                              app_ref_req,
   output                             app_ref_ack,
   input                              app_zq_req,
   output                             app_zq_ack,

   // Ports to be used with SKIP_CALIB defined
   output                              calib_tap_req,
   input [6:0]                         calib_tap_addr,
   input                               calib_tap_load,
   input [7:0]                         calib_tap_val,
   input                               calib_tap_load_done,

   // temperature monitor ports
   input  [11:0]                      device_temp,
   //phase shift clock control
   output                             psen,
   output                             psincdec,
   input                              psdone,
   // debug logic ports
   input                              dbg_idel_down_all,
   input                              dbg_idel_down_cpt,
   input                              dbg_idel_up_all,
   input                              dbg_idel_up_cpt,
   input                              dbg_sel_all_idel_cpt,
   input [DQS_CNT_WIDTH-1:0]          dbg_sel_idel_cpt,
   output [6*DQS_WIDTH*RANKS-1:0]     dbg_cpt_first_edge_cnt,
   output [6*DQS_WIDTH*RANKS-1:0]     dbg_cpt_second_edge_cnt,
   output [DQS_WIDTH-1:0]             dbg_rd_data_edge_detect,
   output [2*nCK_PER_CLK*DQ_WIDTH-1:0] dbg_rddata,
   output [1:0]                       dbg_rdlvl_done,
   output [1:0]                       dbg_rdlvl_err,
   output [1:0]                       dbg_rdlvl_start,
   output [5:0]                       dbg_tap_cnt_during_wrlvl,
   output                             dbg_wl_edge_detect_valid,
   output                             dbg_wrlvl_done,
   output                             dbg_wrlvl_err,
   output                             dbg_wrlvl_start,
   output [6*DQS_WIDTH-1:0]           dbg_final_po_fine_tap_cnt,
   output [3*DQS_WIDTH-1:0]           dbg_final_po_coarse_tap_cnt,

   output                             init_calib_complete,
   input                              dbg_sel_pi_incdec,
   input                              dbg_sel_po_incdec,
   input [DQS_CNT_WIDTH:0]            dbg_byte_sel,
   input                              dbg_pi_f_inc,
   input                              dbg_pi_f_dec,
   input                              dbg_po_f_inc,
   input                              dbg_po_f_stg23_sel,
   input                              dbg_po_f_dec,
   output [6*DQS_WIDTH*RANKS-1:0]     dbg_cpt_tap_cnt,
   output [5*DQS_WIDTH*RANKS-1:0]     dbg_dq_idelay_tap_cnt,
   output                             dbg_rddata_valid,
   output [6*DQS_WIDTH-1:0]           dbg_wrlvl_fine_tap_cnt,
   output [3*DQS_WIDTH-1:0]           dbg_wrlvl_coarse_tap_cnt,
   output                             ref_dll_lock,
   input                              rst_phaser_ref,
   input                              iddr_rst,
   output [6*RANKS-1:0]               dbg_rd_data_offset,
   output [255:0]                     dbg_calib_top,
   output [255:0]                     dbg_phy_wrlvl,
   output [255:0]                     dbg_phy_rdlvl,
   output [99:0]                      dbg_phy_wrcal,
   output [255:0]                     dbg_phy_init,
   output [255:0]                     dbg_prbs_rdlvl,
   output [255:0]                     dbg_dqs_found_cal,
   output [5:0]                       dbg_pi_counter_read_val,
   output [8:0]                       dbg_po_counter_read_val,
   output                             dbg_pi_phaselock_start,
   output                             dbg_pi_phaselocked_done,
   output                             dbg_pi_phaselock_err,
   output                             dbg_pi_dqsfound_start,
   output                             dbg_pi_dqsfound_done,
   output                             dbg_pi_dqsfound_err,
   output                             dbg_wrcal_start,
   output                             dbg_wrcal_done,
   output                             dbg_wrcal_err,
   output [11:0]                      dbg_pi_dqs_found_lanes_phy4lanes,
   output [11:0]                      dbg_pi_phase_locked_phy4lanes,
   output [6*RANKS-1:0]               dbg_calib_rd_data_offset_1,
   output [6*RANKS-1:0]               dbg_calib_rd_data_offset_2,
   output [5:0]                       dbg_data_offset,
   output [5:0]                       dbg_data_offset_1,
   output [5:0]                       dbg_data_offset_2,
   output                             dbg_oclkdelay_calib_start,
   output                             dbg_oclkdelay_calib_done,
   output [255:0]                     dbg_phy_oclkdelay_cal,
   output [DRAM_WIDTH*16 -1:0]        dbg_oclkdelay_rd_data,
   output [6*DQS_WIDTH*RANKS-1:0]     dbg_prbs_final_dqs_tap_cnt_r,
   output [6*DQS_WIDTH*RANKS-1:0]     dbg_prbs_first_edge_taps,
   output [6*DQS_WIDTH*RANKS-1:0]     dbg_prbs_second_edge_taps,
   output [1023:0]                    dbg_poc

   );

  localparam IODELAY_GRP = (tCK <= 1500)? IODELAY_GRP1 : IODELAY_GRP0;

//  wire [6*DQS_WIDTH*RANKS-1:0]     prbs_final_dqs_tap_cnt_r;
//  wire [6*DQS_WIDTH*RANKS-1:0]     dbg_prbs_first_edge_taps;
//  wire [6*DQS_WIDTH*RANKS-1:0]     dbg_prbs_second_edge_taps;

  wire                                   correct_en;
  wire [2*nCK_PER_CLK-1:0]               raw_not_ecc;
  wire [2*nCK_PER_CLK-1:0]               ecc_single;
  wire [2*nCK_PER_CLK-1:0]               ecc_multiple;
  wire [MC_ERR_ADDR_WIDTH-1:0]           ecc_err_addr;
  wire [DQ_WIDTH/8-1:0]                  fi_xor_we;
  wire [DQ_WIDTH-1:0]                    fi_xor_wrdata;

  wire [DATA_BUF_OFFSET_WIDTH-1:0]       wr_data_offset;
  wire                                   wr_data_en;
  wire [DATA_BUF_ADDR_WIDTH-1:0]         wr_data_addr;
  wire [DATA_BUF_OFFSET_WIDTH-1:0]       rd_data_offset;
  wire                                   rd_data_en;
  wire [DATA_BUF_ADDR_WIDTH-1:0]         rd_data_addr;
  wire                                   accept;
  wire                                   accept_ns;
  wire [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0] rd_data;
  wire                                   rd_data_end;
  wire                                   use_addr;
  wire                                   size;
  wire [ROW_WIDTH-1:0]                   row;
  wire [RANK_WIDTH-1:0]                  rank;
  wire                                   hi_priority;
  wire [DATA_BUF_ADDR_WIDTH-1:0]         data_buf_addr;
  wire [COL_WIDTH-1:0]                   col;
  wire [2:0]                             cmd;
  wire [BANK_WIDTH-1:0]                  bank;
  wire [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0] wr_data;
  wire [2*nCK_PER_CLK*PAYLOAD_WIDTH/8-1:0]  wr_data_mask;

  wire                                   app_sr_req_i;
  wire                                   app_sr_active_i;
  wire                                   app_ref_req_i;
  wire                                   app_ref_ack_i;
  wire                                   app_zq_req_i;
  wire                                   app_zq_ack_i;

  wire                                   rst_tg_mc;
  wire                                   error;
  wire                                   init_wrcal_complete;
  reg                                    reset /* synthesis syn_maxfan = 10 */;

  //***************************************************************************

  always @(posedge clk)
    reset <= #TCQ (rst | rst_tg_mc);


  assign fi_xor_we = {DQ_WIDTH/8{1'b0}} ;
  assign fi_xor_wrdata = {DQ_WIDTH{1'b0}} ;

  mig_7series_v4_2_mem_intfc #
     (
      .TCQ                   (TCQ),
      .DDR3_VDD_OP_VOLT      (DDR3_VDD_OP_VOLT),
      .PAYLOAD_WIDTH         (PAYLOAD_WIDTH),
      .ADDR_CMD_MODE         (ADDR_CMD_MODE),
      .AL                    (AL),
      .BANK_WIDTH            (BANK_WIDTH),
      .BM_CNT_WIDTH          (BM_CNT_WIDTH),
      .BURST_MODE            (BURST_MODE),
      .BURST_TYPE            (BURST_TYPE),
      .CA_MIRROR             (CA_MIRROR),
      .CK_WIDTH              (CK_WIDTH),
      .COL_WIDTH             (COL_WIDTH),
      .CMD_PIPE_PLUS1        (CMD_PIPE_PLUS1),
      .CS_WIDTH              (CS_WIDTH),
      .nCS_PER_RANK          (nCS_PER_RANK),
      .CKE_WIDTH             (CKE_WIDTH),
      .DATA_WIDTH            (DATA_WIDTH),
      .DATA_BUF_ADDR_WIDTH   (DATA_BUF_ADDR_WIDTH),
      .MASTER_PHY_CTL        (MASTER_PHY_CTL),
      .DATA_BUF_OFFSET_WIDTH (DATA_BUF_OFFSET_WIDTH),
      .DDR2_DQSN_ENABLE      (DDR2_DQSN_ENABLE),
      .DM_WIDTH              (DM_WIDTH),
      .DQ_CNT_WIDTH          (DQ_CNT_WIDTH),
      .DQ_WIDTH              (DQ_WIDTH),
      .DQS_CNT_WIDTH         (DQS_CNT_WIDTH),
      .DQS_WIDTH             (DQS_WIDTH),
      .DRAM_TYPE             (DRAM_TYPE),
      .DRAM_WIDTH            (DRAM_WIDTH),
      .ECC                   (ECC),
      .ECC_WIDTH             (ECC_WIDTH),
      .MC_ERR_ADDR_WIDTH     (MC_ERR_ADDR_WIDTH),
      .REFCLK_FREQ           (REFCLK_FREQ),
      .nAL                   (nAL),
      .nBANK_MACHS           (nBANK_MACHS),
      .nCK_PER_CLK           (nCK_PER_CLK),
      .ORDERING              (ORDERING),
      .OUTPUT_DRV            (OUTPUT_DRV),
      .IBUF_LPWR_MODE        (IBUF_LPWR_MODE),
      .BANK_TYPE             (BANK_TYPE),
      .DATA_IO_PRIM_TYPE     (DATA_IO_PRIM_TYPE),
      .DATA_IO_IDLE_PWRDWN   (DATA_IO_IDLE_PWRDWN),
      .IODELAY_GRP           (IODELAY_GRP),
      .FPGA_SPEED_GRADE      (FPGA_SPEED_GRADE),
      .REG_CTRL              (REG_CTRL),
      .RTT_NOM               (RTT_NOM),
      .RTT_WR                (RTT_WR),
      .CL                    (CL),
      .CWL                   (CWL),
      .tCK                   (tCK),
      .tCKE                  (tCKE),
      .tFAW                  (tFAW),
      .tPRDI                 (tPRDI),
      .tRAS                  (tRAS),
      .tRCD                  (tRCD),
      .tREFI                 (tREFI),
      .tRFC                  (tRFC),
      .tRP                   (tRP),
      .tRRD                  (tRRD),
      .tRTP                  (tRTP),
      .tWTR                  (tWTR),
      .tZQI                  (tZQI),
      .tZQCS                 (tZQCS),
      .USER_REFRESH          (USER_REFRESH),
      .TEMP_MON_EN           (TEMP_MON_EN),
      .WRLVL                 (WRLVL),
      .DEBUG_PORT            (DEBUG_PORT),
      .CAL_WIDTH             (CAL_WIDTH),
      .RANK_WIDTH            (RANK_WIDTH),
      .RANKS                 (RANKS),
      .ODT_WIDTH             (ODT_WIDTH),
      .ROW_WIDTH             (ROW_WIDTH),
      .SIM_BYPASS_INIT_CAL   (SIM_BYPASS_INIT_CAL),
      .BYTE_LANES_B0         (BYTE_LANES_B0),
      .BYTE_LANES_B1         (BYTE_LANES_B1),
      .BYTE_LANES_B2         (BYTE_LANES_B2),
      .BYTE_LANES_B3         (BYTE_LANES_B3),
      .BYTE_LANES_B4         (BYTE_LANES_B4),
      .DATA_CTL_B0           (DATA_CTL_B0),
      .DATA_CTL_B1           (DATA_CTL_B1),
      .DATA_CTL_B2           (DATA_CTL_B2),
      .DATA_CTL_B3           (DATA_CTL_B3),
      .DATA_CTL_B4           (DATA_CTL_B4),
      .PHY_0_BITLANES        (PHY_0_BITLANES),
      .PHY_1_BITLANES        (PHY_1_BITLANES),
      .PHY_2_BITLANES        (PHY_2_BITLANES),
      .CK_BYTE_MAP           (CK_BYTE_MAP),
      .ADDR_MAP              (ADDR_MAP),
      .BANK_MAP              (BANK_MAP),
      .CAS_MAP               (CAS_MAP),
      .CKE_ODT_BYTE_MAP      (CKE_ODT_BYTE_MAP),
      .CKE_MAP               (CKE_MAP),
      .ODT_MAP               (ODT_MAP),
      .CKE_ODT_AUX           (CKE_ODT_AUX),
      .CS_MAP                (CS_MAP),
      .PARITY_MAP            (PARITY_MAP),
      .RAS_MAP               (RAS_MAP),
      .WE_MAP                (WE_MAP),
      .DQS_BYTE_MAP          (DQS_BYTE_MAP),
      .DATA0_MAP             (DATA0_MAP),
      .DATA1_MAP             (DATA1_MAP),
      .DATA2_MAP             (DATA2_MAP),
      .DATA3_MAP             (DATA3_MAP),
      .DATA4_MAP             (DATA4_MAP),
      .DATA5_MAP             (DATA5_MAP),
      .DATA6_MAP             (DATA6_MAP),
      .DATA7_MAP             (DATA7_MAP),
      .DATA8_MAP             (DATA8_MAP),
      .DATA9_MAP             (DATA9_MAP),
      .DATA10_MAP            (DATA10_MAP),
      .DATA11_MAP            (DATA11_MAP),
      .DATA12_MAP            (DATA12_MAP),
      .DATA13_MAP            (DATA13_MAP),
      .DATA14_MAP            (DATA14_MAP),
      .DATA15_MAP            (DATA15_MAP),
      .DATA16_MAP            (DATA16_MAP),
      .DATA17_MAP            (DATA17_MAP),
      .MASK0_MAP             (MASK0_MAP),
      .MASK1_MAP             (MASK1_MAP),
      .SLOT_0_CONFIG         (SLOT_0_CONFIG),
      .SLOT_1_CONFIG         (SLOT_1_CONFIG),
      .CALIB_ROW_ADD         (CALIB_ROW_ADD),
      .CALIB_COL_ADD         (CALIB_COL_ADD),
      .CALIB_BA_ADD          (CALIB_BA_ADD),
      .STARVE_LIMIT          (STARVE_LIMIT),
      .USE_CS_PORT           (USE_CS_PORT),
      .USE_DM_PORT           (USE_DM_PORT),
      .USE_ODT_PORT          (USE_ODT_PORT),
      .IDELAY_ADJ            (IDELAY_ADJ),
      .FINE_PER_BIT          (FINE_PER_BIT),
      .CENTER_COMP_MODE      (CENTER_COMP_MODE),
      .PI_VAL_ADJ            (PI_VAL_ADJ),
      .TAPSPERKCLK           (TAPSPERKCLK),
      .SKIP_CALIB            (SKIP_CALIB),
      .FPGA_VOLT_TYPE        (FPGA_VOLT_TYPE)
      )
    mem_intfc0
     (
      .clk                              (clk),
      .clk_div2                         (clk_div2),
      .rst_div2                         (rst_div2),
      .clk_ref                          (tCK <= 1500 ? clk_ref[1] : clk_ref[0]),
      .mem_refclk                       (mem_refclk), //memory clock
      .freq_refclk                      (freq_refclk),
      .pll_lock                         (pll_lock),
      .sync_pulse                       (sync_pulse),
      .mmcm_ps_clk                      (mmcm_ps_clk),
      .poc_sample_pd                    (poc_sample_pd),
      .rst                              (rst),
      .error                            (error),
      .reset                            (reset),
      .rst_tg_mc                        (rst_tg_mc),

      .ddr_dq                           (ddr_dq),
      .ddr_dqs_n                        (ddr_dqs_n),
      .ddr_dqs                          (ddr_dqs),
      .ddr_addr                         (ddr_addr),
      .ddr_ba                           (ddr_ba),
      .ddr_cas_n                        (ddr_cas_n),
      .ddr_ck_n                         (ddr_ck_n),
      .ddr_ck                           (ddr_ck),
      .ddr_cke                          (ddr_cke),
      .ddr_cs_n                         (ddr_cs_n),
      .ddr_dm                           (ddr_dm),
      .ddr_odt                          (ddr_odt),
      .ddr_ras_n                        (ddr_ras_n),
      .ddr_reset_n                      (ddr_reset_n),
      .ddr_parity                       (ddr_parity),
      .ddr_we_n                         (ddr_we_n),

      .slot_0_present                   (SLOT_0_CONFIG),
      .slot_1_present                   (SLOT_1_CONFIG),

      .correct_en                       (correct_en),
      .bank                             (bank),
      .cmd                              (cmd),
      .col                              (col),
      .data_buf_addr                    (data_buf_addr),
      .wr_data                          (wr_data),
      .wr_data_mask                     (wr_data_mask),
      .rank                             (rank),
      .raw_not_ecc                      (raw_not_ecc),
      .row                              (row),
      .hi_priority                      (hi_priority),
      .size                             (size),
      .use_addr                         (use_addr),
      .accept                           (accept),
      .accept_ns                        (accept_ns),
      .ecc_single                       (ecc_single),
      .ecc_multiple                     (ecc_multiple),
      .ecc_err_addr                     (ecc_err_addr),
      .rd_data                          (rd_data),
      .rd_data_addr                     (rd_data_addr),
      .rd_data_en                       (rd_data_en),
      .rd_data_end                      (rd_data_end),
      .rd_data_offset                   (rd_data_offset),
      .wr_data_addr                     (wr_data_addr),
      .wr_data_en                       (wr_data_en),
      .wr_data_offset                   (wr_data_offset),
      .bank_mach_next                   (bank_mach_next),
      .init_calib_complete              (init_calib_complete),
      .init_wrcal_complete              (init_wrcal_complete),
      .app_sr_req                       (app_sr_req_i),
      .app_sr_active                    (app_sr_active_i),
      .app_ref_req                      (app_ref_req_i),
      .app_ref_ack                      (app_ref_ack_i),
      .app_zq_req                       (app_zq_req_i),
      .app_zq_ack                       (app_zq_ack_i),

       // skip calibration i/f
      .calib_tap_req                    (calib_tap_req),
      .calib_tap_load                   (calib_tap_load),
      .calib_tap_addr                   (calib_tap_addr),
      .calib_tap_val                    (calib_tap_val),
      .calib_tap_load_done              (calib_tap_load_done),

      .device_temp                      (device_temp),
      .psen                             (psen),
      .psincdec                         (psincdec),
      .psdone                           (psdone),
      .fi_xor_we                (fi_xor_we),
      .fi_xor_wrdata            (fi_xor_wrdata),



      .dbg_idel_up_all                  (dbg_idel_up_all),
      .dbg_idel_down_all                (dbg_idel_down_all),
      .dbg_idel_up_cpt                  (dbg_idel_up_cpt),
      .dbg_idel_down_cpt                (dbg_idel_down_cpt),
      .dbg_sel_idel_cpt                 (dbg_sel_idel_cpt),
      .dbg_sel_all_idel_cpt             (dbg_sel_all_idel_cpt),
      .dbg_calib_top                    (dbg_calib_top),
      .dbg_cpt_first_edge_cnt           (dbg_cpt_first_edge_cnt),
      .dbg_cpt_second_edge_cnt          (dbg_cpt_second_edge_cnt),
      .dbg_phy_rdlvl                    (dbg_phy_rdlvl),
      .dbg_phy_wrcal                    (dbg_phy_wrcal),
      .dbg_final_po_fine_tap_cnt        (dbg_final_po_fine_tap_cnt),
      .dbg_final_po_coarse_tap_cnt      (dbg_final_po_coarse_tap_cnt),
      .dbg_rd_data_edge_detect          (dbg_rd_data_edge_detect),
      .dbg_rddata                       (dbg_rddata),
      .dbg_rdlvl_done                   (dbg_rdlvl_done),
      .dbg_rdlvl_err                    (dbg_rdlvl_err),
      .dbg_rdlvl_start                  (dbg_rdlvl_start),
      .dbg_tap_cnt_during_wrlvl         (dbg_tap_cnt_during_wrlvl),
      .dbg_wl_edge_detect_valid         (dbg_wl_edge_detect_valid),
      .dbg_wrlvl_done                   (dbg_wrlvl_done),
      .dbg_wrlvl_err                    (dbg_wrlvl_err),
      .dbg_wrlvl_start                  (dbg_wrlvl_start),

      .dbg_sel_pi_incdec                (dbg_sel_pi_incdec),
      .dbg_sel_po_incdec                (dbg_sel_po_incdec),
      .dbg_byte_sel                     (dbg_byte_sel),
      .dbg_pi_f_inc                     (dbg_pi_f_inc),
      .dbg_pi_f_dec                     (dbg_pi_f_dec),
      .dbg_po_f_inc                     (dbg_po_f_inc),
      .dbg_po_f_stg23_sel               (dbg_po_f_stg23_sel),
      .dbg_po_f_dec                     (dbg_po_f_dec),
      .dbg_cpt_tap_cnt                  (dbg_cpt_tap_cnt),
      .dbg_dq_idelay_tap_cnt            (dbg_dq_idelay_tap_cnt),
      .dbg_rddata_valid                 (dbg_rddata_valid),
      .dbg_wrlvl_fine_tap_cnt           (dbg_wrlvl_fine_tap_cnt),
      .dbg_wrlvl_coarse_tap_cnt         (dbg_wrlvl_coarse_tap_cnt),
      .dbg_phy_wrlvl                    (dbg_phy_wrlvl),
      .dbg_pi_counter_read_val          (dbg_pi_counter_read_val),
      .dbg_po_counter_read_val          (dbg_po_counter_read_val),
      .ref_dll_lock                     (ref_dll_lock),
      .rst_phaser_ref                   (rst_phaser_ref),
      .iddr_rst                         (iddr_rst),
      .dbg_rd_data_offset               (dbg_rd_data_offset),
      .dbg_phy_init                     (dbg_phy_init),
      .dbg_prbs_rdlvl                   (dbg_prbs_rdlvl),
      .dbg_dqs_found_cal                (dbg_dqs_found_cal),
      .dbg_pi_phaselock_start           (dbg_pi_phaselock_start),
      .dbg_pi_phaselocked_done          (dbg_pi_phaselocked_done),
      .dbg_pi_phaselock_err             (dbg_pi_phaselock_err),
      .dbg_pi_dqsfound_start            (dbg_pi_dqsfound_start),
      .dbg_pi_dqsfound_done             (dbg_pi_dqsfound_done),
      .dbg_pi_dqsfound_err              (dbg_pi_dqsfound_err),
      .dbg_wrcal_start                  (dbg_wrcal_start),
      .dbg_wrcal_done                   (dbg_wrcal_done),
      .dbg_wrcal_err                    (dbg_wrcal_err),
      .dbg_pi_dqs_found_lanes_phy4lanes (dbg_pi_dqs_found_lanes_phy4lanes),
      .dbg_pi_phase_locked_phy4lanes    (dbg_pi_phase_locked_phy4lanes),
      .dbg_calib_rd_data_offset_1       (dbg_calib_rd_data_offset_1),
      .dbg_calib_rd_data_offset_2       (dbg_calib_rd_data_offset_2),
      .dbg_data_offset                  (dbg_data_offset),
      .dbg_data_offset_1                (dbg_data_offset_1),
      .dbg_data_offset_2                (dbg_data_offset_2),
      .dbg_phy_oclkdelay_cal            (dbg_phy_oclkdelay_cal),
      .dbg_oclkdelay_rd_data            (dbg_oclkdelay_rd_data),
      .dbg_oclkdelay_calib_start        (dbg_oclkdelay_calib_start),
      .dbg_oclkdelay_calib_done         (dbg_oclkdelay_calib_done),
      .prbs_final_dqs_tap_cnt_r         (dbg_prbs_final_dqs_tap_cnt_r),
      .dbg_prbs_first_edge_taps         (dbg_prbs_first_edge_taps),
      .dbg_prbs_second_edge_taps        (dbg_prbs_second_edge_taps),
      .dbg_poc                          (dbg_poc[1023:0])
      );

  mig_7series_v4_2_ui_top #
    (
     .TCQ                 (TCQ),
     .APP_DATA_WIDTH      (APP_DATA_WIDTH),
     .APP_MASK_WIDTH      (APP_MASK_WIDTH),
     .BANK_WIDTH          (BANK_WIDTH),
     .COL_WIDTH           (COL_WIDTH),
     .CWL                 (CWL),
     .DATA_BUF_ADDR_WIDTH (DATA_BUF_ADDR_WIDTH),
     .ECC                 (ECC),
     .ECC_TEST            (ECC_TEST),
     .nCK_PER_CLK         (nCK_PER_CLK),
     .ORDERING            (ORDERING),
     .RANKS               (RANKS),
     .RANK_WIDTH          (RANK_WIDTH),
     .ROW_WIDTH           (ROW_WIDTH),
     .MEM_ADDR_ORDER      (MEM_ADDR_ORDER)
    )
   u_ui_top
     (
      .wr_data_mask         (wr_data_mask[APP_MASK_WIDTH-1:0]),
      .wr_data              (wr_data[APP_DATA_WIDTH-1:0]),
      .use_addr             (use_addr),
      .size                 (size),
      .row                  (row),
      .raw_not_ecc          (raw_not_ecc),
      .rank                 (rank),
      .hi_priority          (hi_priority),
      .data_buf_addr        (data_buf_addr),
      .col                  (col),
      .cmd                  (cmd),
      .bank                 (bank),
      .app_wdf_rdy          (app_wdf_rdy),
      .app_rdy              (app_rdy),
      .app_rd_data_valid    (app_rd_data_valid),
      .app_rd_data_end      (app_rd_data_end),
      .app_rd_data          (app_rd_data),
      .app_ecc_multiple_err (app_ecc_multiple_err),
      .app_ecc_single_err   (app_ecc_single_err),
      .correct_en           (correct_en),
      .wr_data_offset       (wr_data_offset),
      .wr_data_en           (wr_data_en),
      .wr_data_addr         (wr_data_addr),
      .rst                  (reset),
      .rd_data_offset       (rd_data_offset),
      .rd_data_end          (rd_data_end),
      .rd_data_en           (rd_data_en),
      .rd_data_addr         (rd_data_addr),
      .rd_data              (rd_data[APP_DATA_WIDTH-1:0]),
      .ecc_multiple         (ecc_multiple),
      .ecc_single           (ecc_single),
      .clk                  (clk),
      .app_wdf_wren         (app_wdf_wren),
      .app_wdf_mask         (app_wdf_mask),
      .app_wdf_end          (app_wdf_end),
      .app_wdf_data         (app_wdf_data),
      .app_sz               (1'b1),
      .app_raw_not_ecc      (app_raw_not_ecc),
      .app_hi_pri           (app_hi_pri),
      .app_en               (app_en),
      .app_cmd              (app_cmd),
      .app_addr             (app_addr),
      .accept_ns            (accept_ns),
      .accept               (accept),
      .app_correct_en       (app_correct_en_i),
      .app_sr_req           (app_sr_req),
      .sr_req               (app_sr_req_i),
      .sr_active            (app_sr_active_i),
      .app_sr_active        (app_sr_active),
      .app_ref_req          (app_ref_req),
      .ref_req              (app_ref_req_i),
      .ref_ack              (app_ref_ack_i),
      .app_ref_ack          (app_ref_ack),
      .app_zq_req           (app_zq_req),
      .zq_req               (app_zq_req_i),
      .zq_ack               (app_zq_ack_i),
      .app_zq_ack           (app_zq_ack)
      );

endmodule

