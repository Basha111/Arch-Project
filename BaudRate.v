module BaudRate(
  input   PCLK,
  output reg txClk
);
parameter CLOCK_RATE = 25000000;
parameter BAUD_RATE = 115200;
parameter Over_Sampling = 16;
parameter MAX_RATE_TX = CLOCK_RATE / (Over_Sampling * BAUD_RATE);
parameter TX_CNT_WIDTH = $clog2(MAX_RATE_TX);
reg [TX_CNT_WIDTH - 1:0] txCounter = 0;
initial begin
    txClk = 1'b0;
end
always @(posedge PCLK) begin
    if (txCounter == MAX_RATE_TX[TX_CNT_WIDTH-1:0]) begin
        txCounter <= 0;
        txClk <= ~txClk;
    end 
    else begin
        txCounter <= txCounter + 1'b1;
    end
end
endmodule