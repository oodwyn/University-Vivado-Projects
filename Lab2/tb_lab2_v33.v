`timescale 1ns / 1ps

module tb_lab2_v33;

    reg clk_p = 1;
    reg clk_n = 0;
    wire [7:0] leds;
    
    always #2.5 {clk_p, clk_n} = ~{clk_p, clk_n};

    lab2_top_v33 uut (
        .clk_p(clk_p),
        .clk_n(clk_n),
        .leds(leds)
    );

    initial begin
        #20000; // 20 us должно быть достаточно для lock
        $stop;
    end

endmodule