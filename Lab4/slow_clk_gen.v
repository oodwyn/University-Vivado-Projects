`timescale 1ns / 1ps

module slow_clk_gen(
    input clk,          // Входная частота 90 МГц
    output reg slow_clk // Выходная частота ~20 Гц
    );

    integer counter = 0;
    
    // Считаем до 2_250_000, чтобы переключить сигнал
    always @(posedge clk) begin
        if (counter >= 2250000) begin
            counter <= 0;
            slow_clk <= ~slow_clk;
        end else begin
            counter <= counter + 1;
        end
    end
    
    initial slow_clk = 0;
    
endmodule
