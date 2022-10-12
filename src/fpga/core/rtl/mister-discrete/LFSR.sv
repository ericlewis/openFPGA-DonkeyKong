module LFSR(
  input clk,
  input audio_clk_en,
  input I_RSTn,
  output reg [7:0] LFSR = 255   // put here the initial value
);

wire feedback = LFSR[7];

always @(posedge clk) begin
  if(!I_RSTn)begin
    LFSR <= 255;
  end else if(audio_clk_en) begin
    LFSR[0] <= feedback;
    LFSR[1] <= LFSR[0];
    LFSR[2] <= LFSR[1] ^ feedback;
    LFSR[3] <= LFSR[2] ^ feedback;
    LFSR[4] <= LFSR[3] ^ feedback;
    LFSR[5] <= LFSR[4];
    LFSR[6] <= LFSR[5];
    LFSR[7] <= LFSR[6];
  end
end
endmodule