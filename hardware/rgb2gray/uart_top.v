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
    input           clk       ,      //�ⲿ50Mʱ��
    input           rst_n     ,      //�ⲿ��λ�źţ�����Ч
    //input           start     ,      //��ʼ�ź�
    output          uart_txd  ,      //UART���Ͷ˿�
    output          led
    );
    
    //parameter define
    parameter  CLK_FREQ = 50000000;         //����ϵͳʱ��Ƶ��
    parameter  UART_BPS = 115200;           //���崮�ڲ�����
    
    //wire define   
    wire [7:0] img_gray;               //�Ҷ�����
    wire       uart_send_en;                //UART����ʹ��
    wire       uart_tx_busy;                //UART����æ״̬��־
    
    //���ڷ���ģ��    
    uart_send #(                          
        .CLK_FREQ       (CLK_FREQ),         //����ϵͳʱ��Ƶ��
        .UART_BPS       (UART_BPS))         //���ô��ڷ��Ͳ�����
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
