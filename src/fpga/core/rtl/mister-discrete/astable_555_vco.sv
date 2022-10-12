/********************************************************************************\
 * 
 *  MiSTer Discrete invertor square wave oscilator test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *  Model taken from the equation on https://electronics.stackexchange.com/questions/101530/what-is-the-equation-for-the-555-timer-control-voltage
 *  
 *  th=C⋅(R1+R2)⋅ln(1+v_control/(2*(VCC−v_control)))
 *  tl=C⋅R2⋅ln(2)
 *
 *           v_pos
 *              V
 *              |
 *        .-----+---+-----------------------------.
 *        |         |                             |
 *        |         |                             |
 *        |         |                             |
 *        Z         |8                            |
 *     R1 Z     .---------.                       |
 *        |    7|  Vcc    |                       |
 *        +-----|Discharge|                       |
 *        |     |         |                       |
 *        Z     |   555   |3                      |
 *     R2 Z     |      Out|---> Output Node       |
 *        |    6|         |                       |
 *        +-----|Threshold|                       |
 *        |     |         |                       |
 *        +-----|Trigger  |                       |
 *        |    2|         |---< Control Voltage   |
 *        |     |  Reset  |5                      |
 *        |     '---------'                       |
 *       ---        4|                            |
 *     C ---         +----------------------------'
 *        |          |
 *        |          ^
 *       gnd       Reset
 * 
 *     Drawing based on a drawing from MAME discrete
 *
 ********************************************************************************/
module astable_555_vco#(
    parameter CLOCK_RATE = 50000000,
    parameter longint SAMPLE_RATE = 48000,
    parameter R1 = 47000,
    parameter R2 = 27000,
    parameter C_35_SHIFTED = 1134 // 33 nanofarad
) (
    input clk,
    input I_RSTn,
    input audio_clk_en,
    input signed[15:0] v_control,
    output signed[15:0] out
);
    localparam VCC = 16384;
    localparam ln2_16_SHIFTED = 45426;
    localparam[63:0] C_R2_ln2_27_SHIFTED = C_35_SHIFTED * R2 * ln2_16_SHIFTED >> 24;
    localparam[63:0] C_R1_R2_35_SHIFTED = C_35_SHIFTED * (R1 + R2);
    localparam[31:0] CYCLES_LOW = C_R2_ln2_27_SHIFTED * CLOCK_RATE >> 27;
    localparam[31:0] CLOCK_RATE_C_R1_R2 = C_R1_R2_35_SHIFTED * CLOCK_RATE >> 35;

    wire signed[15:0] v_control_safe;

    reg[15:0] v_control_divided_two_vcc_minus_vcontrol = 3000;
    reg[15:0] two_vcc_minus_vcontrol = 3000;
    
    wire [11:0] ln_vc_vcc_vc_8_shifted;
    reg[23:0] to_log_8_shifted = 1000;
    
    natural_log natlog(
        .in_8_shifted(to_log_8_shifted),
        .I_RSTn(I_RSTn),
        .clk(clk),
        .out_8_shifted(ln_vc_vcc_vc_8_shifted)
    );

    reg[32:0] WAVE_LENGTH;
    reg[31:0] CYCLES_HIGH = 1000;

    assign v_control_safe = v_control < 32767 ? v_control : 32766;

    assign WAVE_LENGTH = CYCLES_HIGH + CYCLES_LOW;

    reg[63:0] wave_length_counter = 0;

    reg signed[15:0] unfiltered_out = 0;

    rate_of_change_limiter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .MAX_CHANGE_RATE(200000)
    ) slew_rate (
        clk,
        I_RSTn,
        audio_clk_en,
        unfiltered_out,
        out
    );

    always @(posedge clk, negedge I_RSTn) begin
        if(!I_RSTn)begin
            unfiltered_out <= 0;
            to_log_8_shifted <= 0;
            wave_length_counter <= 0;
            CYCLES_HIGH <= 1000;
        end else begin
            v_control_divided_two_vcc_minus_vcontrol <= v_control_safe / (two_vcc_minus_vcontrol >> 8);
            two_vcc_minus_vcontrol <= (VCC << 1) - (v_control_safe << 1);
            to_log_8_shifted <= (1 << 8) + v_control_divided_two_vcc_minus_vcontrol;
            CYCLES_HIGH <= ((CLOCK_RATE_C_R1_R2 >> 4) * ln_vc_vcc_vc_8_shifted) >> 4; // C⋅(R1+R2)⋅ln(1+v_control/(2*(VCC−v_control)))

            if(wave_length_counter < WAVE_LENGTH)begin
            wave_length_counter <= wave_length_counter + 1;
            end else begin 
                wave_length_counter <= 0;
            end

            if(audio_clk_en)begin
                unfiltered_out <= wave_length_counter < CYCLES_HIGH ? 16384 : 0;
            end
        end
    end
endmodule