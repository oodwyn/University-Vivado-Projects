`timescale 1ns / 1ps

module lab3_top_v33(
    input  clk_p,
    input  clk_n,
    input  [4:0] btns,
    output [7:0] leds
    );

    // --- 1. MMCM ---
    wire clk_in_unbuf, clk_in;
    wire clk_a_130mhz; 
    wire mmcm_locked, mmcm_fb;

    IBUFDS ibufds_inst (.I(clk_p), .IB(clk_n), .O(clk_in_unbuf));
    BUFG bufg_inst (.I(clk_in_unbuf), .O(clk_in));

    // Используем параметры из ЛР2
    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"), .CLKOUT4_CASCADE("FALSE"), .STARTUP_WAIT("FALSE"),
        .DIVCLK_DIVIDE(10),        // D
        .CLKFBOUT_MULT_F(39.0),    // M
        .CLKIN1_PERIOD(5.0),
        .CLKOUT0_DIVIDE_F(6.0),    // O = 6 -> 130 MHz
        .CLKOUT0_PHASE(0.0), .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT1_DIVIDE(6), 
        .CLKOUT1_PHASE(-22.5),     
        .CLKOUT1_DUTY_CYCLE(0.5)
    ) mmcm_inst (
        .CLKIN1(clk_in), .CLKFBOUT(mmcm_fb), .CLKFBIN(mmcm_fb),
        .CLKOUT0(clk_a_130mhz), .LOCKED(mmcm_locked), .PWRDWN(1'b0), .RST(1'b0)
    );

    // --- 2. Генератор медленного клока и Антидребезг ---
    wire slow_clk;
    // Делитель нужно немного подправить под 130 МГц, чтобы получить 20 Гц
    // 130М / 20 / 2 = 3,250,000. Но модуль slow_clk_gen у нас универсальный,
    // если там стоит старое число, частота просто будет чуть другой (не критично).
    slow_clk_gen slow_clk_inst (.clk(clk_a_130mhz), .slow_clk(slow_clk));

    wire btn0_clean, btn1_clean, btn2_clean, btn4_pulse;
    // Нам нужны 3 кнопки навигации и 1 смена режима
    debounce db_kn1 (.clk(clk_a_130mhz), .slow_clk(slow_clk), .btn_in(btns[0]), .btn_out(btn0_clean));
    debounce db_kn2 (.clk(clk_a_130mhz), .slow_clk(slow_clk), .btn_in(btns[1]), .btn_out(btn1_clean));
    debounce db_kn3 (.clk(clk_a_130mhz), .slow_clk(slow_clk), .btn_in(btns[2]), .btn_out(btn2_clean));
    debounce db_sw  (.clk(clk_a_130mhz), .slow_clk(slow_clk), .btn_in(btns[4]), .btn_out(btn4_pulse));

    reg mode_lab3 = 0; 
    always @(posedge clk_a_130mhz) begin
        if (btn4_pulse) mode_lab3 <= ~mode_lab3;
    end

    // --- 3. Логика Лабораторной №2 ---
    // 130 МГц / 0.5 Гц = 260,000,000
    localparam DIVIDER_MAX_LR2 = 260_000_000 - 1;
    reg [27:0] cnt_lr2_slow = 0;
    reg tick_lr2 = 0;
    reg [5:0] counter_lr2 = 0;
    
    always @(posedge clk_a_130mhz) begin
        if (cnt_lr2_slow == DIVIDER_MAX_LR2) begin
            cnt_lr2_slow <= 0;
            tick_lr2 <= 1;
        end else begin
            cnt_lr2_slow <= cnt_lr2_slow + 1;
            tick_lr2 <= 0;
        end
        if (tick_lr2) counter_lr2 <= counter_lr2 + 1;
    end

    wire func_result_lr2;
    // Используем модуль ЛР1
    lab1_v33_structural_lut lab1_inst (
        .X(counter_lr2[5]), .Y(counter_lr2[4]), .Z(counter_lr2[3]),
        .K(counter_lr2[2]), .L(counter_lr2[1]), .N(counter_lr2[0]),
        .F(func_result_lr2)
    );
    
    wire [7:0] leds_lr2;
    assign leds_lr2[0] = func_result_lr2;
    assign leds_lr2[6:1] = counter_lr2;
    assign leds_lr2[7] = mmcm_locked;

    // --- 4. Логика Лабораторной №3 ---
    wire [7:0] leds_lr3;
    fsm_controller_v33 fsm_inst (
        .clk(clk_a_130mhz),
        .reset(~mmcm_locked),
        .btn1(btn0_clean),
        .btn2(btn1_clean),
        .btn3(btn2_clean),
        .leds(leds_lr3)
    );

    // --- 5. Мультиплексор ---
    assign leds = mode_lab3 ? leds_lr3 : leds_lr2;

endmodule
