/*
 * @Descripttion: 
 * @Author: ISMY
 * @contact: mingyu_shu@tju.edu.cn
 * @version: 
 * @Date: 2024-03-26 10:45:42
 * @LastEditors: ISMY
 * @LastEditTime: 2024-03-26 15:12:01
 */

module sobel_edge_detector
    #(
    parameter   SOBEL_THRESHOLD = 50 //Sobel threshold
    )
    (
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
    output reg [7:0]  img_edge      
    );

    //reg define 
    reg [9:0]  gx_temp2  ; //third column value
    reg [9:0]  gx_temp1  ; //first column values
    reg [8:0]  gx_data   ; //partial derivatives in the x-direction
    reg [9:0]  gy_temp1  ; //first row of values
    reg [9:0]  gy_temp2  ; //third row of values
    reg [8:0]  gy_data   ; //the partial derivatives in the y-direction
    reg        send_en1;
    reg        send_en2;
    reg        send_en3;
    
    //Sobel kernel
    //         gx                  gy                  pixel
    // [   -1  0   +1  ]   [   +1  +2   +1 ]     [   P11  P12   P13 ]
    // [   -2  0   +2  ]   [   0   0    0  ]     [   P21  P22   P23 ]
    // [   -1  0   +1  ]   [   -1  -2   -1 ]     [   P31  P32   P33 ]

    //Step1 Calculate the partial derivative in the x-direction: clk1 
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gy_temp1 <= 10'd0;
            gy_temp2 <= 10'd0;
        end
        else if (matrix_finish) begin
            gy_temp1 <= matrix_p13 + (matrix_p23 << 1) + matrix_p33; 
            gy_temp2 <= matrix_p11 + (matrix_p21 << 1) + matrix_p31; 
        end
        else begin 
            gy_temp1 <= gx_temp1;
            gy_temp2 <= gx_temp2;
        end
    end
    
    //Step2 Calculate the partial derivative in the x-direction: clk2 
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gy_data <=  9'd0;
        end
        else begin
            gy_data  <= (gy_temp1 >= gy_temp2) ? gy_temp1 - gy_temp2 : (gy_temp2 - gy_temp1);
        end
    end

    //Step1 Calculate the partial derivative in the y-direction: clk1 
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gx_temp1 <= 10'd0;
            gx_temp2 <= 10'd0;
        end
        else if (matrix_finish) begin
            gx_temp1 <= matrix_p11 + (matrix_p12 << 1) + matrix_p13;
            gx_temp2 <= matrix_p31 + (matrix_p32 << 1) + matrix_p33;
        end
        else begin 
            gx_temp1 <= gx_temp1;
            gx_temp2 <= gx_temp2;
        end
    end
    
    //Step2 Calculate the partial derivative in the y-direction: clk2 
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gx_data <=  9'd0;
        end
        else  begin
            gx_data  <= (gx_temp1 >= gx_temp2) ? gx_temp1 - gx_temp2 : (gx_temp2 - gx_temp1);
        end
    end

    //Step3 Estimated gradient value calculation: clk3
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            img_edge <= 1'b0; 
        end
        else begin
            img_edge <= ((gy_data+gx_data)>>1 >= SOBEL_THRESHOLD) ? (gy_data+gx_data)>>1 : 0;
        end
    end

    //Output Enable Signal
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin 
            send_en1  <= 1'b1;
            send_en2  <= 1'b0;
            send_en3  <= 1'b0;
            send_en   <= 1'b0;
        end
        else if(pix_finish) begin
            send_en1 <= 1'b0    ;
            send_en2 <= send_en1;
            send_en3 <= send_en2;
            send_en  <= send_en3;
        end
        else begin
            send_en1 <= matrix_finish;
            send_en2 <= send_en1;
            send_en3 <= send_en2;
            send_en  <= send_en3;
        end
    end

endmodule