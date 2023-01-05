module UartTx(
input[31:0]  PWDATA,//
input        Txstart,
input        PRESETn,
input        tick,
input        PCLK,
output reg   Txd,
output reg   TxD_done
);
  localparam IDLE         = 2'b00;
  localparam TX_START_BIT = 2'b01;
  localparam TX_DATA_BITS = 2'b10;
  localparam TX_STOP_BIT  = 2'b11;
 	reg [1:0]  STATE;
 	//-----------------------------------------
 	

  reg [3:0] r_Clock_Count;
  reg [4:0] r_Bit_Index;
  reg [31:0] r_TX_Data;

 	
 	//-------------------------------------------
 	
 	always@(posedge PCLK or negedge PRESETn)begin
 	  if(~PRESETn) STATE <= 2'b00;
 	  else begin
 	    TxD_done <= 1'b0;
 	    case(STATE)
 	      IDLE: begin
 	        Txd <= 1'b1;
 	        r_Clock_Count <= 0;
          r_Bit_Index   <= 0;
          if (Txstart == 1'b1) begin
            r_TX_Data   <= PWDATA;
            STATE   <= TX_START_BIT;
          end
          else
            STATE <= IDLE;
        end 
 //--------
      TX_START_BIT: begin
        Txd <= 1'b0;
        if(tick)begin
          if(r_Clock_Count == 15) begin
            r_Clock_Count <= 0;
            STATE <= TX_DATA_BITS;
          end 
          else begin
            r_Clock_Count <= r_Clock_Count + 1;
            STATE   <= TX_START_BIT;
          end
        end 
        else STATE   <= TX_START_BIT;
      end
//--------
      TX_DATA_BITS: begin
        Txd <= r_TX_Data[r_Bit_Index];
        if(tick)begin
          if(r_Clock_Count == 15) begin
            r_Clock_Count <= 0;
            if(r_Bit_Index == 31)begin//
              r_Bit_Index   <= 0;
              STATE   <= TX_STOP_BIT;
            end
            else begin
              r_Bit_Index <= r_Bit_Index + 1;
              STATE   <= TX_DATA_BITS;
            end
          end
          else begin
            r_Clock_Count <= r_Clock_Count + 1;
            STATE   <= TX_DATA_BITS;
          end
        end
        else STATE   <= TX_DATA_BITS;
      end
 //--------
      TX_STOP_BIT:  begin
        Txd <= 1'b1;
        if(tick)begin
          TxD_done <= 1'b1;
          STATE <= IDLE;
        end
        else STATE <= TX_STOP_BIT;
      end
 	   endcase
 	    
 	  end
 	 
 	end




endmodule
