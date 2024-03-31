/*
 * @Descripttion: 
 * @Author: ISMY
 * @contact: mingyu_shu@tju.edu.cn
 * @version: 
 * @Date: 2024-03-26 10:32:59
 * @LastEditors: ISMY
 * @LastEditTime: 2024-03-26 14:52:10
 */

module RGB2Gray(
    input             clk         ,
    input             rst_n       ,
    input             tx_busy     ,  //accept busy status flag   
    output reg        send_en     ,  //send enable signal
    output            pix_finish  ,  //all pixels are processed signal
    output reg [7:0]  img_gray       //data after grayscale processing
    );
    
    reg gray_finish;
    reg tx_busy_reg0;
    reg tx_busy_reg1;
    
    
    reg  [17:0] addra   ;     //rom address
    wire         addra_flag;  //address plus one enable
    wire  [15:0] img565 ;     //RGB565 data
    wire [23:0] R    ;
    wire [23:0] G    ;
    wire [23:0] B    ;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tx_busy_reg0 <= 1'b0;
            tx_busy_reg1 <= 1'b0;
        end
        else begin
            tx_busy_reg0 <= tx_busy;
            tx_busy_reg1 <= tx_busy_reg0;       
        end
    end
    
    assign addra_flag = tx_busy_reg1 & (~tx_busy_reg0);
    
    assign R = img565[15:11];
    assign G = img565[10:5];
    assign B = img565[4:0];
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            img_gray <= 8'h0;
        end
        else if(!gray_finish) begin
            img_gray <= (R * 19595 + G * 38470 + B * 7471) >> 14; 
        end
        else begin
            img_gray <= img_gray;            
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            addra <= 18'h0;
            gray_finish <= 1'b1; 
            send_en <= 1'b0;
        end
        else if(addra_flag & addra < 18'b11_1111_1111_1111_1111) begin
            addra <= addra + 1'b1;
            gray_finish <= 1'b1;
            send_en <= gray_finish;
        end
        else begin
            addra <= addra;  
            gray_finish <= 1'b0;
            send_en <= gray_finish;         
        end
    end
    
    assign pix_finish = (addra == 18'b11_1111_1111_1111_1111) ? 1'b1 : 1'b0;
            
    
    Img_Rom16bit u_Img_Rom16bit (
        .clka (clk   ),      // input wire clka
        .ena  (1'b1  ),      // input wire ena
        .addra(addra ),      // input wire [17 : 0] addra
        .douta(img565)       // output wire [15 : 0] douta
    );
    
endmodule
