/*
 * @Descripttion: 
 * @Author: ISMY
 * @contact: mingyu_shu@tju.edu.cn
 * @version: 
 * @Date: 2024-03-26 10:32:59
 * @LastEditors: ISMY
 * @LastEditTime: 2024-03-26 15:01:05
 */

module uart_send(
    input	      sys_clk,                   //system clock
    input         sys_rst_n,                 //system reset, active low
    
    input         uart_en,                   //transmit enable signal
    input  [7:0]  uart_din,                  //data to be sent
    output        uart_tx_busy,              //transmit busy status flag      
    output  reg   uart_txd                   //UART transmit port
    );
    
//parameter define
parameter  CLK_FREQ = 50000000;             //system clock frequency
parameter  UART_BPS = 9600;                 //serial port baud rate
localparam  BPS_CNT  = CLK_FREQ/UART_BPS;   //to get the specified baud rate, count BPS_CNT times on the system clock

//reg define
reg        uart_en_d0; 
reg        uart_en_d1;  
reg [15:0] clk_cnt;                         //system clock counter
reg [ 3:0] tx_cnt;                          //send data counter
reg        tx_flag;                         //transmit process flag signal
reg [ 7:0] tx_data;                         //registering transmit data

//wire define
wire       en_flag;


assign uart_tx_busy = tx_flag;

assign en_flag = (~uart_en_d1) & uart_en_d0;

// delay the transmit enable signal uart_en by two clock cycles.
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        uart_en_d0 <= 1'b0;                                  
        uart_en_d1 <= 1'b0;
    end                                                      
    else begin                                               
        uart_en_d0 <= uart_en;                               
        uart_en_d1 <= uart_en_d0;                            
    end
end

// when the pulse signal en_flag arrives, the data to be sent is stored and the sending process is started.          
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin                                  
        tx_flag <= 1'b0;
        tx_data <= 8'd0;
    end 
    else if (en_flag) begin                 //transmit enable rising edge detected                    
            tx_flag <= 1'b1;                //entering the transmit process, flag bit tx_flag is pulled high
            tx_data <= uart_din;            //to register the data to be sent
        end
                                            //count to the end of the stop bit, stop sending process
        else if ((tx_cnt == 4'd9) && (clk_cnt == BPS_CNT -(BPS_CNT/16))) begin                                       
            tx_flag <= 1'b0;                //end of transmit process, flag bit tx_flag pulled low
            tx_data <= 8'd0;
        end
        else begin
            tx_flag <= tx_flag;
            tx_data <= tx_data;
        end 
end

// start the system clock counter after entering the sending process
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)                             
        clk_cnt <= 16'd0;                                  
    else if (tx_flag) begin                 //in the process of sending
        if (clk_cnt < BPS_CNT - 1)
            clk_cnt <= clk_cnt + 1'b1;
        else
            clk_cnt <= 16'd0;               //clear the system clock after counting up to one baud rate cycle
    end
    else                             
        clk_cnt <= 16'd0; 				    //end of the sending process
end

// the transmit data counter is activated when the transmit process is entered.
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)                             
        tx_cnt <= 4'd0;
    else if (tx_flag) begin                 //in the process of sending
        if (clk_cnt == BPS_CNT - 1)			//counting up to one baud rate cycle on the system clock
            tx_cnt <= tx_cnt + 1'b1;		//then the transmit data counter is incremented by 1
        else
            tx_cnt <= tx_cnt;       
    end
    else                              
        tx_cnt  <= 4'd0;				    //end of sending process
end

// assign a value to the uart transmit port based on the transmit data counter.
always @(posedge sys_clk or negedge sys_rst_n) begin        
    if (!sys_rst_n)  
        uart_txd <= 1'b1;        
    else if (tx_flag)
        case(tx_cnt)
            4'd0: uart_txd <= 1'b0;         //start Bit 
            4'd1: uart_txd <= tx_data[0];   //data bit lowest bit
            4'd2: uart_txd <= tx_data[1];
            4'd3: uart_txd <= tx_data[2];
            4'd4: uart_txd <= tx_data[3];
            4'd5: uart_txd <= tx_data[4];
            4'd6: uart_txd <= tx_data[5];
            4'd7: uart_txd <= tx_data[6];
            4'd8: uart_txd <= tx_data[7];   //data bit highest bit
            4'd9: uart_txd <= 1'b1;         //stop bit
            default: ;
        endcase
    else 
        uart_txd <= 1'b1;                   //transmit port is high when idle
end

endmodule	          