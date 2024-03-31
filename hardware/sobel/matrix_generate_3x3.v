/*
 * @Descripttion: 
 * @Author: ISMY
 * @contact: mingyu_shu@tju.edu.cn
 * @version: 
 * @Date: 2024-03-26 10:45:42
 * @LastEditors: ISMY
 * @LastEditTime: 2024-03-26 15:01:37
 */

module  matrix_generate_3x3(
    input             clk          ,  
    input             rst_n        ,
    input             shift_en     ,
    output reg [7:0]  matrix_p11   ,
    output reg [7:0]  matrix_p12   , 
    output reg [7:0]  matrix_p13   ,
    output reg [7:0]  matrix_p21   , 
    output reg [7:0]  matrix_p22   , 
    output reg [7:0]  matrix_p23   ,
    output reg [7:0]  matrix_p31   , 
    output reg [7:0]  matrix_p32   , 
    output reg [7:0]  matrix_p33   ,
    output reg        matrix_finish,
    output            pix_finish
    );

    parameter size = 512*512;
    parameter init = 512    ;
    reg  [17:0] addra        ;
    reg  [18:0] addra_counter;
    reg  [1:0]  y_counter    ;
    reg  [1:0]  y_counter_reg;
    reg         line_finish0 ;
    reg         line_finish  ;
    reg         matrix_finish0;

    reg [7:0]   row1_img ;
    reg [7:0]   row2_img ;
    reg [7:0]   row3_img ;
    wire [7:0]  img      ;

    // reg tx_busy_reg0;
    // reg tx_busy_reg1;
    // reg addra_flag0;
    // reg addra_flag1;
    // reg addra_flag2;


    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         tx_busy_reg0 <= 1'b0;
    //         tx_busy_reg1 <= 1'b0;
    //         addra_flag0  <= 1'b0;
    //         addra_flag1  <= 1'b0;
    //         addra_flag2  <= 1'b0;
    //     end
    //     else begin
    //         tx_busy_reg0 <= tx_busy;
    //         tx_busy_reg1 <= tx_busy_reg0;  
    //         addra_flag0  <= tx_busy_reg1 & (~tx_busy_reg0);     
    //         addra_flag1  <= addra_flag0;
    //         addra_flag2  <= addra_flag1;
    //     end
    // end
    // assign addra_flag = addra_flag0 | addra_flag1 | addra_flag2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y_counter <= 2'b00;
        end
        else case (y_counter) 
            2'b00: y_counter <= shift_en ? 2'b01 : 2'b00;
            2'b01: y_counter <= 2'b10;
            2'b10: y_counter <= 2'b00;
            default : y_counter <= 2'b00;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            y_counter_reg <= 2'b00;
        else 
            y_counter_reg <= y_counter;
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            addra_counter <= 18'h0;
        else if(y_counter == 2'b10 & addra_counter < 19'b100_0000_0000_0000_0000)
            addra_counter <= addra_counter + 1'b1;
        else
            addra_counter <= addra_counter;
    end

    assign pix_finish = (addra_counter == 19'b100_0000_0000_0000_0000) ? 1'b1 : 1'b0;

    always @(y_counter) begin
            addra = (addra_counter + y_counter*init < size) ? addra_counter + y_counter*init : addra;
    end

    always @(y_counter_reg) begin
        case(y_counter_reg)
            2'b00: row1_img = img;
            2'b01: row2_img = (addra_counter + y_counter*init < size) ? img : 0;
            2'b10: row3_img = (addra_counter + y_counter*init < size) ? img : 0;
                default: {row1_img, row2_img, row3_img} = {row1_img, row2_img, row3_img};
        endcase  
    end

    Img_Rom u_Img_Rom (
        .clka (clk  ),  // input wire clka
        .addra(addra),  // input wire [17 : 0] addra
        .douta(img  )   // output wire [7 : 0] douta
    );

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            line_finish  <= 1'b0;
            line_finish0 <= 1'b0;
        end
        else if(y_counter == 2'b10) begin
            line_finish0 <= 1'b1;
            line_finish  <= line_finish0;
        end
        else begin
            line_finish0 <= 1'b0;
            line_finish  <= line_finish0;
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
            {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
            {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
            // row1_img_dl <= 8'b0000_0000;
            matrix_finish0 <= 1'b0;
            matrix_finish  <= 1'b0;
        end
        else if(line_finish) begin
            // row1_img_dl <= row1_img;
            {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, row1_img};
            {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, row2_img};
            {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, row3_img};
            matrix_finish0 <= 1'b1;
            matrix_finish  <= matrix_finish0;
        end
        else begin
            {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p11, matrix_p12, matrix_p13};
            {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p21, matrix_p22, matrix_p23};
            {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p31, matrix_p32, matrix_p33};
            matrix_finish0 <= 1'b0;
            matrix_finish  <= matrix_finish0;
        end
    end

endmodule
