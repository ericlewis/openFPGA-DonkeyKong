/********************************************************************************\
 * 
 *  MiSTer Discrete resistor_capacitor_low_pass filter
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *         
 *  based on https://en.wikipedia.org/wiki/Low-pass_filter
 * 
 ********************************************************************************/
module resistor_capacitor_high_pass_filter #(
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
    localparam longint SMOOTHING_FACTOR_ALPHA_16_SHIFTED = (R_C_32_SHIFTED <<< 16) / (R_C_32_SHIFTED + DELTA_T_32_SHIFTED);
    
    wire[7:0] random_number;

    LFSR lfsr(
        .clk(clk),
        .audio_clk_en(audio_clk_en),
        .I_RSTn(I_RSTn),
        .LFSR(random_number)
    );

    reg signed[15:0] last_in = 0;
    always@(posedge clk, negedge I_RSTn) begin
        if(!I_RSTn)begin
            out <= 0;
            last_in <= 0;
        end else if(audio_clk_en)begin
            out <= SMOOTHING_FACTOR_ALPHA_16_SHIFTED * (out + in - last_in) >> 16;
            last_in <= in + ((random_number >>> 6) - 2); // add noise to help convergence to 0
        end
    end
    
endmodule