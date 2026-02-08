`timescale 1ns / 1ps

module fsm_controller_v33(
    input clk,
    input reset,
    input btn1, // kn1 (btns[0])
    input btn2, // kn2 (btns[1])
    input btn3, // kn3 (btns[2])
    output reg [7:0] leds
    );

    // Кодирование состояний
    localparam S_START      = 0; // 00001111
    localparam S_LEFT       = 1; // 11110000 (Таймер)
    localparam S_RIGHT      = 2; // 00110011
    localparam S_BOT_LEFT   = 3; // 11100111
    localparam S_BOT_RIGHT  = 4; // 11001100
    localparam S_ANIM       = 5; // Анимация

    reg [2:0] state = S_START;
    
    // Таймер 5 секунд (для частоты 130 МГц)
    // 130,000,000 * 5 = 650,000,000 тактов
    reg [31:0] timer_cnt = 0;
    
    // Таймер анимации (~0.1 сек на кадр для плавности)
    // 130 МГц * 0.1 = 13,000,000
    integer anim_wait_cnt = 0;
    reg [3:0] anim_frame = 0; // 16 кадров (8 заполнение + 8 очистка)

    always @(posedge clk) begin
        if (reset) begin
            state <= S_START;
            timer_cnt <= 0;
            anim_frame <= 0;
        end else begin
            case (state)
                // --- Start (00001111) ---
                S_START: begin
                    // Переход в LEFT по ЛЮБОЙ кнопке (кн1, кн2, кн3)
                    if (btn1 || btn2 || btn3) begin
                        state <= S_LEFT;
                        timer_cnt <= 0; // Сброс таймера при входе
                    end
                end

                // --- Left (11110000) - С ТАЙМЕРОМ ---
                S_LEFT: begin
                    // Логика таймера (5 сек) ИЛИ кн1 -> переход в Right
                    if (timer_cnt >= 650000000 || btn1) begin
                        state <= S_RIGHT;
                    end
                    else if (btn2) state <= S_BOT_LEFT; // кн2
                    else if (btn3) state <= S_ANIM;     // кн3
                    else begin
                        timer_cnt <= timer_cnt + 1;
                    end
                end
                
                // --- Bottom Left (11100111) ---
                S_BOT_LEFT: begin
                    if (btn2) state <= S_BOT_RIGHT; // кн2
                end

                // --- Bottom Right (11001100) ---
                S_BOT_RIGHT: begin
                    if (btn2) state <= S_RIGHT; // кн2
                end

                // --- Animation ---
                S_ANIM: begin
                    if (btn3) state <= S_RIGHT; // кн3 -> выход
                    
                    // Крутим кадры
                    if (anim_wait_cnt >= 13000000) begin
                        anim_wait_cnt <= 0;
                        anim_frame <= anim_frame + 1; // Само переполнится 15->0
                    end else begin
                        anim_wait_cnt <= anim_wait_cnt + 1;
                    end
                end

                // --- Right (00110011) ---
                S_RIGHT: begin
                    // Переход в START по ЛЮБОЙ кнопке
                    if (btn1 || btn2 || btn3) state <= S_START;
                end
            endcase
        end
    end

    // Вывод на светодиоды
    always @(*) begin
        case (state)
            S_START:     leds = 8'b00001111;
            S_LEFT:      leds = 8'b11110000;
            S_BOT_LEFT:  leds = 8'b11100111;
            S_BOT_RIGHT: leds = 8'b11001100;
            S_RIGHT:     leds = 8'b00110011;
            S_ANIM: begin
                // Поочередное встречное заполнение
                case (anim_frame)
                    // Заполнение
                    0:  leds = 8'b00000001; // R
                    1:  leds = 8'b10000001; // L
                    2:  leds = 8'b10000011; // R
                    3:  leds = 8'b11000011; // L
                    4:  leds = 8'b11000111; // R
                    5:  leds = 8'b11100111; // L
                    6:  leds = 8'b11101111; // R
                    7:  leds = 8'b11111111; // L (Полностью)
                    
                    // Поочередное исчезновение
                    8:  leds = 8'b11111110; // -R
                    9:  leds = 8'b01111110; // -L
                    10: leds = 8'b01111100; // -R
                    11: leds = 8'b00111100; // -L
                    12: leds = 8'b00111000; // -R
                    13: leds = 8'b00011000; // -L
                    14: leds = 8'b00010000; // -R
                    15: leds = 8'b00000000; // -L (Пусто)
                endcase
            end
            default: leds = 8'b00000000;
        endcase
    end
endmodule
