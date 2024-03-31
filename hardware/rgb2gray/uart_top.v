/*
 * @Descripttion: 
 * @Author: ISMY
 * @contact: mingyu_shu@tju.edu.cn
 * @version: 
 * @Date: 2024-03-26 10:32:59
 * @LastEditors: ISMY
 * @LastEditTime: 2024-03-26 15:01:14
 */

module uart_top(
    input           clk       ,      //外部50M时钟
    input           rst_n     ,      //外部复位信号，低有效
    //input           start     ,      //开始信号
    output          uart_txd  ,      //UART发送端口
    output          led
    );
    
    //parameter define
    parameter  CLK_FREQ = 50000000;         //定义系统时钟频率
    parameter  UART_BPS = 115200;           //定义串口波特率
    
    //wire define   
    wire [7:0] img_gray;               //灰度数据
    wire       uart_send_en;                //UART发送使能
    wire       uart_tx_busy;                //UART发送忙状态标志
    
    //串口发送模块    
    uart_send #(                          
        .CLK_FREQ       (CLK_FREQ),         //设置系统时钟频率
        .UART_BPS       (UART_BPS))         //设置串口发送波特率
    u_uart_send(                 
        .sys_clk        (clk),
        .sys_rst_n      (rst_n),
        
        .uart_en        (uart_send_en),
        .uart_din       (img_gray),
        .uart_tx_busy   (uart_tx_busy),
        .uart_txd       (uart_txd)
    );
    
    RGB2Gray u_RGB2Gray(
        .clk  (clk),
        .rst_n(rst_n),
        .tx_busy(uart_tx_busy),
        
        .send_en(uart_send_en),
        .pix_finish(pix_finish),
        .img_gray(img_gray)
    );
    
    assign led = pix_finish;
    
endmodule
