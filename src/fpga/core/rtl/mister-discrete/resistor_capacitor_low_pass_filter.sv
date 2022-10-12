/********************************************************************************\
 * 
 *  MiSTer Discrete resistor_capacitor_low_pass filter
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *         
 *  based on https://en.wikipedia.org/wiki/Low-pass_filter
 *  and https://zipcpu.com/dsp/2017/08/19/simple-filter.html
 * 
 ********************************************************************************/
module resistor_capacitor_low_pass_filter #(
    parameter SAMPLE_RATE = 48000,
    parameter R = 47000,
    parameter C_35_SHIFTED = 1615 // 0.000000047 farads <<< 35 
) ( 
    input clk,
    input I_RSTn,
    input audio_clk_en,
    input signed[15:0] in,
    output reg signed[15:0] out = 0
);
    localparam longint DELTA_T_32_SHIFTED = (1 <<< 32) / SAMPLE_RATE;
    localparam longint R_C_32_SHIFTED = R * C_35_SHIFTED >>> 3;
    localparam longint SMOOTHING_FACTOR_ALPHA_16_SHIFTED = (DELTA_T_32_SHIFTED <<< 16) / (R_C_32_SHIFTED + DELTA_T_32_SHIFTED);

    always@(posedge clk, negedge I_RSTn) begin
        if(!I_RSTn)begin
            out <= 0;
        end else if(audio_clk_en)begin
            out <= out + (SMOOTHING_FACTOR_ALPHA_16_SHIFTED * (in - out) >>> 16);
        end
    end
    
endmodule