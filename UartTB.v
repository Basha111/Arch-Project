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
  //-------------RX SIGNALS---------
  reg rx;
  wire rx_Done;
  //--------------------------------
  parameter c_CLOCK_PERIOD_NS = 40;
  wire tick;
  
  BaudRate ss(PCLK,tick);
  
  UartRx  uartrx(.Rx(rx),
                 .PCLK(PCLK),
                 .PRESETn(PRESETn),
                 .tick(tick),
                 .PRDATA(PRDATA),
                 .RX_Done(rx_Done));
                 
                 
  always
    #(c_CLOCK_PERIOD_NS/2) PCLK <= !PCLK;
    
    
initial begin
      @(posedge PCLK);
      PADDR <= 32'h0002;
      PWRITE <= 1'b0;
      PSEL <= 1'b1;
      @(posedge PCLK);
      PENABLE <= 1'b1;
      PREADY <=1'b1;
      
      @(posedge PCLK);
      PRESETn <= 1'b0;
      @(posedge PCLK);
      @(posedge PCLK);
      PRESETn <= 1'b1;
      //---------------RX-------------
      @(posedge PCLK);
      rx <= 0;
      repeat(6)@(posedge PCLK);
      rx <= 1;
      repeat(80)@(posedge PCLK);
      rx<=0;

      
      @(posedge rx_Done);
      rx <= 1'b1;
      PSEL <= 1'b0;
      PENABLE <= 1'b0;
      PREADY <=1'b0;
      PWRITE <= 1'b0;

end
endmodule