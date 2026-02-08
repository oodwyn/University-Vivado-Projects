`timescale 1ns / 1ps

module tb_lab3_v33;
    reg clk_p = 1, clk_n = 0;
    reg [4:0] btns = 0;
    wire [7:0] leds;

    always #2.5 {clk_p, clk_n} = ~{clk_p, clk_n}; // 200 MHz input

    lab3_top_v33 uut (
        .clk_p(clk_p), .clk_n(clk_n), .btns(btns), .leds(leds)
    );

    task press_btn(input integer btn_idx);
        begin
            btns[btn_idx] = 1;
            #60000000; // Долгое нажатие
            btns[btn_idx] = 0;
            #60000000;
        end
    endtask

    initial begin
        #20000;
        
        // 1. Включаем режим ЛР3 (btn4)
        press_btn(4);
        
        // Сейчас мы в START (00001111)
        // 2. Жмем btn0 (kn1) -> Переход в LEFT
        press_btn(0);
        
        // Сейчас мы в LEFT.
        // 3. Жмем btn2 (kn3) -> Переход в ANIM
        press_btn(2);
        
        // Ждем анимацию
        #200000000;
        
        // 4. Жмем btn2 (kn3) -> Переход в RIGHT
        press_btn(2);
        
        // 5. Жмем btn0 (kn1) -> Переход в START
        press_btn(0);
        
        // --- Тест таймера ---
        // 6. Снова идем в LEFT
        press_btn(0);
        
        // 7. Ждем 5 секунд
        
        $stop;
    end
endmodule
