/*
 * @Descripttion: 
 * @Author: ISMY
 * @contact: mingyu_shu@tju.edu.cn
 * @version: 
 * @Date: 2024-03-26 10:45:42
 * @LastEditors: ISMY
 * @LastEditTime: 2024-03-26 15:13:25
 */

module uart_top(
    input           clk       ,      
    input           rst_n     ,      
    output          uart_txd  ,      
    output          led
    );
    

    wire       shift_en    ;
    wire [7:0] matrix_p11  ;
    wire [7:0] matrix_p12  ;
    wire [7:0] matrix_p13  ;
    wire [7:0] matrix_p21  ;
    wire [7:0] matrix_p22  ;
    wire [7:0] matrix_p23  ;
    wire [7:0] matrix_p31  ;
    wire [7:0] matrix_p32  ;
    wire [7:0] matrix_p33  ;
    wire       pix_finish  ;
    
    
    wire [7:0] img_edge    ;
    wire       uart_send_en;

    //parameter define
    parameter  CLK_FREQ = 50000000;         
    parameter  UART_BPS = 115200;           
    
    //wire define   
    wire       uart_tx_busy;           
    reg        uart_tx_busy_reg0;
    reg        uart_tx_busy_reg1;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            uart_tx_busy_reg0 <= 1'b0;
            uart_tx_busy_reg1 <= 1'b0;
        end
        else begin
            uart_tx_busy_reg0 <= uart_tx_busy;
            uart_tx_busy_reg1 <= uart_tx_busy_reg0;       
        end
    end

    assign shift_en = uart_tx_busy_reg1 & (~uart_tx_busy_reg0);

    
    //ä¸²å£å‘é?æ¨¡å?    
    uart_send #(                          
        .CLK_FREQ       (CLK_FREQ),        
        .UART_BPS       (UART_BPS))        
    u_uart_send(                 
        .sys_clk        (clk         ),
        .sys_rst_n      (rst_n       ),       
        .uart_en        (uart_send_en),
        .uart_din       (img_edge    ),
        .uart_tx_busy   (uart_tx_busy),
        .uart_txd       (uart_txd    )
    );

    matrix_generate_3x3 matrix_generate_3x3_init(
        .clk          (clk          ), 
        .rst_n        (rst_n        ),
        .shift_en     (shift_en     ),
        .matrix_p11   (matrix_p11   ),
        .matrix_p12   (matrix_p12   ),
        .matrix_p13   (matrix_p13   ),
        .matrix_p21   (matrix_p21   ),
        .matrix_p22   (matrix_p22   ),
        .matrix_p23   (matrix_p23   ),
        .matrix_p31   (matrix_p31   ),
        .matrix_p32   (matrix_p32   ),
        .matrix_p33   (matrix_p33   ),
        .matrix_finish(matrix_finish),
        .pix_finish   (pix_finish    )  
    );
    
    assign led = pix_finish;

    sobel_edge_detector sobel_edge_detector_init(
        .clk          (clk          ),
        .rst_n        (rst_n        ), 
        .matrix_finish(matrix_finish),
        .pix_finish   (pix_finish   ),
        .matrix_p11   (matrix_p11   ),
        .matrix_p12   (matrix_p12   ), 
        .matrix_p13   (matrix_p13   ),
        .matrix_p21   (matrix_p21   ), 
        .matrix_p22   (matrix_p22   ), 
        .matrix_p23   (matrix_p23   ),
        .matrix_p31   (matrix_p31   ), 
        .matrix_p32   (matrix_p32   ), 
        .matrix_p33   (matrix_p33   ),
        .send_en      (uart_send_en ),   
        .img_edge     (img_edge     )    
    );

    
endmodule
