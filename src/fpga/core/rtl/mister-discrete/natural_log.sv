/********************************************************************************\
 * 
 *  MiSTer Discrete natural log core
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module natural_log(input clk, input[23:0] in_8_shifted, input I_RSTn, output reg[11:0] out_8_shifted);
    
    localparam RATIO_16_SHIFTED = 45426; // 1 / log2(e)

    wire[11:0] log2_x;

    // TODO: use more precise implementation of log2
    Log2highacc log2(
        .DIN_8_shifted(in_8_shifted < 24'h104 ? 24'h104 : in_8_shifted), //This implementation of log2 doesn't support input 1 or smaller
        .clk(clk),
        .DOUT_8_shifted(log2_x)
    );

    always_ff @( posedge clk, negedge I_RSTn ) begin : blockName
        if(!I_RSTn)begin
            out_8_shifted <= 0;
        end else if(log2_x)begin
            out_8_shifted <= RATIO_16_SHIFTED * log2_x >> 16; 
        end
    end

endmodule