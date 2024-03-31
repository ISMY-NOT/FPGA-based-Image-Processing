/*
 * @Descripttion: 
 * @Author: ISMY
 * @contact: mingyu_shu@tju.edu.cn
 * @version: 
 * @Date: 2024-03-26 10:44:55
 * @LastEditors: ISMY
 * @LastEditTime: 2024-03-26 14:48:07
 */

module gaussian_filter(
    input             clk          ,
    input             rst_n        , 
    input             matrix_finish,
    input             pix_finish   ,
    input      [7:0]  matrix_p11  ,
    input      [7:0]  matrix_p12  , 
    input      [7:0]  matrix_p13  ,
    input      [7:0]  matrix_p21  , 
    input      [7:0]  matrix_p22  , 
    input      [7:0]  matrix_p23  ,
    input      [7:0]  matrix_p31  , 
    input      [7:0]  matrix_p32  , 
    input      [7:0]  matrix_p33  ,
    output reg        send_en     ,   
    output reg [7:0]  img_filted     
    );
    
    // the temp image to store the result of each step
    reg [12:0] img_temp1;      
    reg [12:0] img_temp2;      
    reg [12:0] img_temp3;  
    // the taps of final send_en    
    reg        send_en1;
    reg        send_en2;
        
    // the kernel of guassian filter
    //                                   
    //        [   1  2   1  ]    [   P11  P12   P13 ]
    //  1/16  [   2  4   2  ]    [   P21  P22   P23 ]
    //        [   1  2   1  ]    [   P31  P32   P33 ]
    
    //Step1 : clk1
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            img_temp1   <= 12'b0000_0000_0000;
            img_temp2   <= 12'b0000_0000_0000;
            img_temp3   <= 12'b0000_0000_0000;     
        end
        else if (matrix_finish) begin
            img_temp1 <= matrix_p11 + (matrix_p12 << 1) + matrix_p13;
            img_temp2 <= (matrix_p21 << 1) + (matrix_p22 << 2) + (matrix_p23 << 1);
            img_temp3 <= matrix_p31 + (matrix_p32 << 1) + matrix_p33;
        end
        else begin
            img_temp1 <= img_temp1;
            img_temp2 <= img_temp2;
            img_temp3 <= img_temp3;
        end
    end

    //Step2: clk2
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin 
            img_filted  <= 8'b0000_0000;    
        end
        else begin
            img_filted <= (img_temp1 + img_temp2 + img_temp3) >> 4;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin 
            send_en1  <= 1'b1;
            send_en2  <= 1'b0;
            send_en   <= 1'b0;
        end
        else if(pix_finish) begin
            send_en1 <= 1'b0    ;
            send_en2 <= send_en1;
            send_en  <= send_en2;
        end
        else begin
            send_en1 <= matrix_finish;
            send_en2 <= send_en1;
            send_en  <= send_en2;
        end
    end

endmodule