module UartTB();
  //-------APB BUS SIGNALS-----------
  reg PCLK = 1'b1;
  reg PRESETn;
  reg[31:0] PADDR;
  reg PWRITE;
  reg PSEL;
  reg PENABLE;
  reg[31:0] PWDATA;
  reg PREADY;
  wire[31:0] PRDATA;
  //-------------TX SIGNALS---------
  wire tx;
  wire Tx_Done;
  reg Tx_Start = 1'b0;
  //--------------------------------

  
  parameter c_CLOCK_PERIOD_NS = 40;
  wire tick;
  BaudRate ss(PCLK,tick);
            
  UartTx  uarttx(.PWDATA(PWDATA),
                 .Txstart(Tx_Start),
                 .PRESETn(PRESETn),
                 .tick(tick),
                 .PCLK(PCLK),
                 .Txd(tx),  
                 .TxD_done(Tx_Done)); 

always
    #(c_CLOCK_PERIOD_NS/2) PCLK <= !PCLK;
  initial begin
      @(posedge PCLK);
      PADDR <= 32'h0001;
      PWRITE <= 1'b1;
      PSEL <= 1'b1;
      PWDATA = 32'h010e;
      @(posedge PCLK);
      PENABLE <= 1'b1;
      PREADY <=1'b1;
      @(posedge PCLK);
      PRESETn <= 1'b0;
      @(posedge PCLK);
      @(posedge PCLK);
      PRESETn <= 1'b1;
      //------------TX----------
      @(posedge PCLK);
      @(posedge PCLK);
      Tx_Start <= 1'b1;
      @(posedge PCLK);
      @(posedge PCLK);
      Tx_Start <= 1'b0;
      @(posedge Tx_Done);
      PSEL <= 1'b0;
      PENABLE <= 1'b0;
      PREADY <=1'b0;
      PWRITE <= 1'b0;
      //----------------------
end
endmodule