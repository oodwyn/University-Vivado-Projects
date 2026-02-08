`timescale 1ns / 1ps
 
module lab4_top_v45(
    input  clk_p,
    input  clk_n,
    input  [4:0] btns,
    output [7:0] leds,
   
    // Выходы на LCD
    output LCD_RS,
    output LCD_RW,
    output LCD_E,
    output [3:0] LCD_D
    );
 
    // MMCM (130 МГц для Варианта 45)
    wire clk_in_unbuf, clk_in;
    wire clk_a_130mhz;
    wire mmcm_locked, mmcm_fb;
 
    IBUFDS ibufds_inst (.I(clk_p), .IB(clk_n), .O(clk_in_unbuf));
    BUFG bufg_inst (.I(clk_in_unbuf), .O(clk_in));
 
    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"), .CLKOUT4_CASCADE("FALSE"), .STARTUP_WAIT("FALSE"),
        .DIVCLK_DIVIDE(10),
        .CLKFBOUT_MULT_F(39.0),
        .CLKIN1_PERIOD(5.0),
        .CLKOUT0_DIVIDE_F(6.0),
        .CLKOUT0_PHASE(0.0), .CLKOUT0_DUTY_CYCLE(0.5)
    ) mmcm_inst (
        .CLKIN1(clk_in), .CLKFBOUT(mmcm_fb), .CLKFBIN(mmcm_fb),
        .CLKOUT0(clk_a_130mhz), .LOCKED(mmcm_locked), .PWRDWN(1'b0), .RST(1'b0)
    );
 
    // Антидребезг (подстроен под 130 МГц внутри модулей)
    wire slow_clk;
    slow_clk_gen slow_clk_inst (.clk(clk_a_130mhz), .slow_clk(slow_clk));
 
    wire btn0_clean, btn1_clean, btn2_clean, btn4_pulse;
    // Кнопки для навигации (kn1, kn2, kn3)
    debounce db_btn0 (.clk(clk_a_130mhz), .slow_clk(slow_clk), .btn_in(btns[0]), .btn_out(btn0_clean));
    debounce db_btn1 (.clk(clk_a_130mhz), .slow_clk(slow_clk), .btn_in(btns[1]), .btn_out(btn1_clean));
    debounce db_btn2 (.clk(clk_a_130mhz), .slow_clk(slow_clk), .btn_in(btns[2]), .btn_out(btn2_clean));
    // Переключение режима
    debounce db_btn4 (.clk(clk_a_130mhz), .slow_clk(slow_clk), .btn_in(btns[4]), .btn_out(btn4_pulse));
 
    reg mode_lab3 = 0;
    always @(posedge clk_a_130mhz) if (btn4_pulse) mode_lab3 <= ~mode_lab3;
 
    // Логика ЛР2 (Счетчик для 130 МГц)
    // 130М / 0.5 Гц = 260,000,000
    reg [27:0] cnt_lr2_slow = 0;
    reg tick_lr2 = 0;
    reg [5:0] counter_lr2 = 0;
   
    always @(posedge clk_a_130mhz) begin
        if (cnt_lr2_slow == 259_999_999) begin
            cnt_lr2_slow <= 0;
            tick_lr2 <= 1;
        end else begin
            cnt_lr2_slow <= cnt_lr2_slow + 1;
            tick_lr2 <= 0;
        end
        if (tick_lr2) counter_lr2 <= counter_lr2 + 1;
    end
 
    wire func_result_lr2;
    lab1_v33_structural_lut lab1_inst (
        .X(counter_lr2[5]), .Y(counter_lr2[4]), .Z(counter_lr2[3]),
        .K(counter_lr2[2]), .L(counter_lr2[1]), .N(counter_lr2[0]),
        .F(func_result_lr2)
    );
   
    wire [7:0] leds_lr2;
    assign leds_lr2[0] = func_result_lr2;
    assign leds_lr2[6:1] = counter_lr2;
    assign leds_lr2[7] = mmcm_locked;
 
    // Логика ЛР3 (FSM Вариант 45)
    wire [7:0] leds_lr3;
    wire [2:0] fsm_state_out;
   
    fsm_controller_v45 fsm_inst (
        .clk(clk_a_130mhz),
        .reset(~mmcm_locked),
        .btn1(btn0_clean),
        .btn2(btn1_clean),
        .btn3(btn2_clean),
        .leds(leds_lr3),
        .state_out(fsm_state_out)
    );
 
    assign leds = mode_lab3 ? leds_lr3 : leds_lr2;
 
    // Дисплей (ЛР4)
    wire [7:0] txt_data;
    wire txt_wr, txt_show;
   
    text_generator_v45 text_gen_inst (
        .clk(clk_a_130mhz),
        .fsm_state(fsm_state_out),
        .cnt_val(counter_lr2),
        .func_res(func_result_lr2),
        .lcd_data(txt_data),
        .lcd_wr(txt_wr),
        .lcd_show(txt_show)
    );
   
    lcd162_st #(
        .cycles_per_us(130)
    ) lcd_driver_inst (
        .clk(clk_a_130mhz),
        .RS(LCD_RS), .RW(LCD_RW), .E(LCD_E), .D(LCD_D),
        .data(txt_data), .data_wr(txt_wr), .show_on_disp(txt_show)
    );
 
endmodule