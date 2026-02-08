`timescale 1ns / 1ps
module slow_clk_gen(
    input clk,
    output reg slow_clk
    );
    integer counter = 0;
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