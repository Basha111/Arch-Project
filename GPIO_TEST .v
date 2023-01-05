module TB_GPIO();
    reg   PCLK = 1'b1;
    wire transfer = 1'b1;
    reg  PENABLE =1'b0;
    reg PSEL1 = 1'b0;
    reg PSEL2 = 1'b0;
    reg PWRITE = 1'b0;
    reg PRESETn = 1'b1;
    wire[31:0] written_data_to_gpio; 
    reg[31:0] PWDATA ;
    reg[31:0] write_address = 32'b00001000111111110001000011111111;
    reg[31:0] write_direction = 32'b00001000111111110001000011111111;
    reg[31:0] read_direction= 32'b00001000111111110001000011111111;
    reg[31:0] read_address = 32'h0000;
    reg[31:0] gpio_in=32'hcfe0fefe;
    wire PREADY=1'b0;
    reg [31:0] PADDR;
    reg[3:0] pstrb = 4'b1010;
    reg [31:0] dir;
    wire[31:0] PRDATA;


    Gpio gpio(.PCLK(PCLK), .PRESETn(PRESETn), .PSEL1(PSEL1), .PENABLE(PENABLE),.PADDR(PADDR), .direction(dir),
              .PWRITE(PWRITE),.PWDATA(PWDATA), .PSTRB(pstrb),.gpio_in(gpio_in),
              .gpio_read_data(written_data_to_gpio), .PRDATA(PRDATA),.PREADY(PREADY) ); 

    always
    #5 PCLK <= ~PCLK;
/*
    initial begin
    #100
    $monitor("[written_data_to_gpio] is %b [PWDATA] is %b", written_data_to_gpio, PWDATA);
    end



    initial begin
        #100
        $monitor("[gpio_in] is %b [PRDATA] is %b", gpio_in, PRDATA);

    end

*/
reg [2:0] state, next_state;
localparam IDLE = 3'b001, SETUP = 3'b010, ACCESS = 3'b100 ;

always @(posedge PCLK)
 
  begin
	   if(!PRESETn) 
            state = IDLE;
	   else
       begin
	      case(state)
		      IDLE:
		       begin 
		         PENABLE =0;
                 PSEL1=0;
                 PSEL2=0;
		         if(transfer)
                        state =  SETUP;
	             else
                         state = IDLE;
	         end
	        SETUP:
	         begin
			       PENABLE =0;
                   PSEL1=1'b1;
			       if(PWRITE)
			         begin 
			           PADDR = write_address;
                       pstrb=4'b1010;
                       write_direction=32'hffff00ff;
                       dir=write_direction;
			         end  
			       else 
			        begin   
                        PADDR = read_address;
                        pstrb = 4'b1000;
                        read_direction=32'hf0ffff00;
                        dir=read_direction;
				      end
			      if(PSEL1 || PSEL2) 
                        state = ACCESS;	 
			     
		       end
 
		      ACCESS:
		       begin
		         if(PSEL1 || PSEL2)
		           begin
		             PENABLE =1;
		             if(!PREADY)
		               begin
		             state = ACCESS;
		               end
		             else 
                     begin
                      if(PWRITE)
			         begin     
                       PWDATA = 32'hb1f0fefa;
			         end 
                        if(transfer)
		                    state = SETUP;
                        else 
                            state = IDLE;
		             end
		            end
		         else state = IDLE;
		        end
 
			    default: state = IDLE; 
			  endcase
			end
 end


endmodule

