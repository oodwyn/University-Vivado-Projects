`timescale 1ns / 1ps
 
module debounce(
    input clk,         // Быстрый клок (90 МГц) для синхронизации
    input slow_clk,    // Медленный клок (~20 Гц) для сэмплирования
    input btn_in,      // "Грязный" сигнал с кнопки
    output reg btn_out // Чистый импульс (1 такт clk) при нажатии
    );
 
    reg [2:0] shift_reg; // Регистр сдвига для проверки стабильности
    reg btn_prev;        // Предыдущее состояние для детекции фронта
    reg slow_clk_prev;   // Для детекции фронта slow_clk
 
    always @(posedge clk) begin
        // Детекция фронта медленного клока
        slow_clk_prev <= slow_clk;
       
        // В момент, когда slow_clk меняется с 0 на 1 (раз в ~50мс)
        if (slow_clk && !slow_clk_prev) begin
            // Сдвиг регистра: вдвиг текущего состояния кнопки
            shift_reg <= {shift_reg[1:0], btn_in};
        end
       
        // Логика выдачи импульса
        // Если в регистре три единицы (кнопка стабильно нажата 3 цикла slow_clk)
        if (shift_reg == 3'b111) begin
            if (btn_prev == 0) begin
                btn_out <= 1;  // Выдача импульса
                btn_prev <= 1; // Запоминание, что уже выдано
            end else begin
                btn_out <= 0;
            end
        end else if (shift_reg == 3'b000) begin
            btn_prev <= 0;  // Сброс блокировки, когда кнопка отпущена
            btn_out <= 0;
        end else begin
            btn_out <= 0;
        end
    end
endmodule
