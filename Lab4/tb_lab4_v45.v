`timescale 1ns / 1ps

module tb_lab4_v45;

    // Входы для верхнего уровня
    reg clk_p = 1;
    reg clk_n = 0;
    reg [4:0] btns = 0;

    // Выходы
    wire [7:0] leds;
    wire LCD_RS, LCD_RW, LCD_E;
    wire [3:0] LCD_D;

    // Генерация входного дифференциального клока 200 МГц (период 5 нс)
    always #2.5 {clk_p, clk_n} = ~{clk_p, clk_n};

    // Подключение модуля 4-й лабы
    lab4_top_v45 uut (
        .clk_p(clk_p),
        .clk_n(clk_n),
        .btns(btns),
        .leds(leds),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_E(LCD_E),
        .LCD_D(LCD_D)
    );

    initial begin
        // Ожидание запуска MMCM и сброса
        #20000;
        
        // Имитация нажатия кнопки смены режима (ЛР2 -> ЛР3)
        btns[4] = 1; // Нажатие btn[4] (West)
        #60000000;   
        btns[4] = 0;
        
        #20000000;
        
        $stop;
    end

endmodule
