//===============================================================================
// FPGA DONKEY KONG WAVE SOUND
//
// Version : 4.00
//
// Copyright(c) 2003 - 2004 Katsumi Degawa , All rights reserved
//
// Important !
//
// This program is freeware for non-commercial use. 
// An author does no guarantee about this program.
// You can use this under your own risk.
//
// 2004- 9 -7  Added Gorilla roar sound. K.degawa
// 2005- 2 -9  removed Gorilla roar sound. K.degawa
//             It was optimized to become the smallest.
//================================================================================


module dkong_wav_sound(

O_ROM_AB,
I_ROM_DB,

I_CLK,
I_RSTn,
I_SW

);

output [18:0]O_ROM_AB;
input  [7:0]I_ROM_DB;

input  I_CLK,I_RSTn;
input  [2:1]I_SW; 

parameter Sample_cnt = 2228;

parameter Wlk1_adr = 16'h0000; // 10000 - 107FF
parameter Wlk1_cnt = 16'h07d0; // 10000 - 107CF
parameter Wlk2_adr = 16'h0800; // 10800 - 10FFF
parameter Wlk2_cnt = 16'h07d0; // 10800 - 10FCF
parameter Wlk3_adr = 16'h4800; // 14800 - 14FFF
parameter Wlk3_cnt = 16'h07d0; // 14800 - 14FCF
parameter Jump_adr = 16'h1000; // 11000 - 12FFF
parameter Jump_cnt = 16'h1e20; // 11000 - 12E1F
parameter Foot_adr = 16'h3000; // 13000 - 14FFF
parameter Foot_cnt = 16'h1750; // 13000 - 1474F

reg   [11:0]sample;
reg   sample_pls;

always@(posedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn)begin
    sample <= 0;
    sample_pls <= 0;
  end else begin
    sample <= (sample == Sample_cnt - 1'b1) ? 12'b0 : sample+1'b1;
    sample_pls <= (sample == Sample_cnt - 1'b1)? 1'b1 : 1'b0 ;
  end
end

//-----------  WALK SOUND ------------------------------------------
reg    [2:0]status0;
reg    [2:0]status1;
reg    [15:0]ad_cnt;
reg    [15:0]end_cnt;
reg    [1:0]steps_cnt;
reg    old_foot_rq;
reg    old_jump_rq;
wire   foot_rq = I_SW[2];
wire   jump_rq = I_SW[1];

always@(posedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn)begin
    status0 <= 0;
    status1 <= 0;
    end_cnt <= Foot_cnt;
    ad_cnt  <= 0;
	steps_cnt <= 2'b01;
  end else begin
    status0[0] = ~old_foot_rq & foot_rq;
    old_foot_rq = foot_rq;
    status0[2] <= ~old_jump_rq & jump_rq;
    old_jump_rq = jump_rq;
    if(status0 > status1)begin
      if(status0[2])begin
        status1 <= 3'b111;
        ad_cnt <= Jump_adr;
        end_cnt <= Jump_cnt;
		steps_cnt <= 2'b01;
      end else if(status0[1])begin
        status1 <= 3'b011;
		case (steps_cnt)
			2'b01: begin
				ad_cnt <= Wlk1_adr;
				end_cnt <= Wlk1_cnt;
				steps_cnt <= 2'b10;
				end
			2'b10: begin
				ad_cnt <= Wlk2_adr;
				end_cnt <= Wlk2_cnt;
				steps_cnt <= 2'b11;
				end
			2'b11: begin
				ad_cnt <= Wlk3_adr;
				end_cnt <= Wlk3_cnt;
				steps_cnt <= 2'b01;
				end
		endcase
      end else begin
        status1 <= 3'b001;
        ad_cnt <= Foot_adr;
        end_cnt <= Foot_cnt;
		steps_cnt <= 2'b01;
      end
    end else begin
      if(sample_pls)begin
        if(!end_cnt)begin
          status1 <= 3'b000;
        end else begin
          end_cnt <= end_cnt-1;
		  ad_cnt <= ad_cnt+1;
        end
      end
    end
  end
end

assign O_ROM_AB  = {3'b001,ad_cnt};


endmodule
