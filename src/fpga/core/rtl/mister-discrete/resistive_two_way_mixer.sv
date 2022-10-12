/********************************************************************************\
 * 
 *  MiSTer Discrete resistive two way mixer
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *   inputs[0]    inputs[1]
 *        V         V
 *        |         |       
 *        |         |       
 *        Z         Z
 *     R0 Z         Z R1
 *        Z         Z
 *        |         |
 *        '----,----'
 *             |
 *             |
 *             V
 *            out
 *          
 ********************************************************************************/
module resistive_two_way_mixer #(
    parameter longint R0 = 10000,
    parameter longint R1 = 10000
) ( 
    input clk,
    input I_RSTn,
    input audio_clk_en,
    input[15:0] inputs[1:0],
    output reg[15:0] out = 0
);
    localparam integer R0_RATIO_16_SHIFTED = ((R1 <<< 16) / R0);
    localparam integer R1_RATIO_16_SHIFTED = ((R0 <<< 16) / R1);
    localparam longint NORMALIZATION_RATIO_16_SHIFTED = (1 <<< 32)/(R0_RATIO_16_SHIFTED+R1_RATIO_16_SHIFTED);
    
    always@(posedge clk, negedge I_RSTn) begin
        if(!I_RSTn)begin
            out <= 0;
        end else if(audio_clk_en)begin
            out <= (R0_RATIO_16_SHIFTED * inputs[0] + R1_RATIO_16_SHIFTED * inputs[1]) * NORMALIZATION_RATIO_16_SHIFTED >>> 32;
        end
    end
endmodule