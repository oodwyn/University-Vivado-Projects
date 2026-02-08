`timescale 1ns / 1ps

module fsm_controller_v45(
    input clk,
    input reset,
    input btn1,
    input btn2,
    input btn3,
    output reg [7:0] leds,
    output [2:0] state_out
    );

    // Коды состояний из Варианта 45
    localparam S_START      = 0;
    localparam S_LEFT       = 1;
    localparam S_RIGHT      = 2;
    localparam S_BOT_LEFT   = 3;
    localparam S_BOT_RIGHT  = 4;
    localparam S_ANIM       = 5;

    reg [2:0] state = S_START;
    assign state_out = state;

    // Таймеры
    reg [31:0] timer_cnt = 0;
    integer anim_wait_cnt = 0;
    reg [3:0] anim_frame = 0;

    always @(posedge clk) begin
        if (reset) begin
            state <= S_START;
            timer_cnt <= 0;
            anim_wait_cnt <= 0;
            anim_frame <= 0;
        end else begin
            case (state)
                S_START: begin
                    if (btn1 || btn2 || btn3) begin
                        state <= S_LEFT;
                        timer_cnt <= 0;
                    end
                end
                
                S_LEFT: begin
                    // 650,000,000 тактов = 5 секунд на 130 МГц
                    if (timer_cnt >= 650000000 || btn1) state <= S_RIGHT;
                    else if (btn2) state <= S_BOT_LEFT;
                    else if (btn3) state <= S_ANIM;
                    else timer_cnt <= timer_cnt + 1;
                end
                
                S_BOT_LEFT: begin
                    if (btn2) state <= S_BOT_RIGHT;
                end
                
                S_BOT_RIGHT: begin
                    if (btn2) state <= S_RIGHT;
                end
                
                S_ANIM: begin
                    if (btn3) state <= S_RIGHT;
                    
                    // Анимация 7
                    if (anim_wait_cnt >= 13000000) begin
                        anim_wait_cnt <= 0;
                        anim_frame <= anim_frame + 1; // Само переполнится (4 бита)
                    end else begin
                        anim_wait_cnt <= anim_wait_cnt + 1;
                    end
                end
                
                S_RIGHT: begin
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
                // Анимация 7: Поочередное встречное заполнение
                case (anim_frame)
                    0: leds = 8'b00000001; 1: leds = 8'b10000001;
                    2: leds = 8'b10000011; 3: leds = 8'b11000011;
                    4: leds = 8'b11000111; 5: leds = 8'b11100111;
                    6: leds = 8'b11101111; 7: leds = 8'b11111111;
                    // Очистка
                    8: leds = 8'b11111110; 9: leds = 8'b01111110;
                    10:leds = 8'b01111100; 11:leds = 8'b00111100;
                    12:leds = 8'b00111000; 13:leds = 8'b00011000;
                    14:leds = 8'b00010000; 15:leds = 8'b00000000;
                endcase
            end
            default: leds = 0;
        endcase
    end
endmodule
