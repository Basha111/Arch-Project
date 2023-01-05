module Gpio#(
  parameter PDATA_SIZE = 32  
)(
  input PCLK,
  input PRESETn,
  input PSEL1,
	input PENABLE,
	input [PDATA_SIZE-1:0]PADDR,
	input PWRITE,
	input [PDATA_SIZE-1:0]PWDATA, // write to gpio
  input [PDATA_SIZE/8-1:0] PSTRB,
	input [PDATA_SIZE-1:0]gpio_in, // value to be read from gpio and written to PRDATA (used in testbench to compare with PRDATA)in case of read data
  input [PDATA_SIZE-1:0] direction, // direction bits from master
	output reg [PDATA_SIZE-1:0]gpio_read_data, // final read value after strop (used in testbench to compare with PWDATA) in case of write data
	output reg [PDATA_SIZE-1:0]PRDATA, // read from gpio
	output reg PREADY
);


localparam in_adr = 32'h0000;
localparam out_adr = 32'b11110111000000001110111100000000;
localparam dir_adr = 32'b00001000111111110001000011111111;

reg [PDATA_SIZE-1:0]INPUT,OUTPUT,DIR;

integer i;


always @(posedge PCLK or negedge PRESETn)
  begin
    
    for(i=0; i<32; i=i+1)
      begin
      // Direction
      if(PADDR==out_adr)
              OUTPUT[i] <= direction[i]? 1'bz : PWDATA[i]; // write operation relative to master (dir == 1)
      else if(PADDR== dir_adr)
              DIR[i] = direction[i]? 1'bz : PWDATA[i]; // write operation relative to master (dir == 1)
      INPUT[i] <= direction[i] ? gpio_in[i] : 1'bz; // read operation rleative to master (dir == 0)
      end

      // PSTORB
      if(PADDR==out_adr)
      begin
      OUTPUT = get_read_value(OUTPUT);
      end
      else if(PADDR== dir_adr) 
      begin 
        DIR = get_read_value(DIR);
      end
      INPUT=get_read_value(INPUT);
      
    if (PSEL1 && PENABLE)
      begin
        PREADY=1'b1;
          if(PWRITE)
            begin
              if(PADDR == out_adr)
                begin
                  gpio_read_data<=OUTPUT;
                end
                else if(PADDR == dir_adr)
                  begin
                    gpio_read_data<=DIR; 
                  end
            end
            else
              begin
                if(PADDR == in_adr)
                  begin
                    PRDATA<=INPUT;
                  end
                if(PADDR == dir_adr)
                  begin
                    PRDATA<=DIR; 
                  end
              end
     end
  end
  

  function automatic [PDATA_SIZE-1:0] get_read_value (input [PDATA_SIZE-1:0] orig_val);
    integer n;
    for (n=0; n < PDATA_SIZE/8; n=n+1)begin
       get_read_value[n*8 +: 8] = PSTRB[n] ? orig_val[n*8 +: 8] : 8'bxxxxxxxx; 
    end
  endfunction

endmodule

