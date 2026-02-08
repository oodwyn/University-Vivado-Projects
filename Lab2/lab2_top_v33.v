`timescale 1ns / 1ps

module lab2_top_v33(
    input  clk_p,
    input  clk_n,
    output [7:0] leds
    );

    wire clk_in_unbuf;
    wire clk_in;
    wire clk_a_130mhz;
    wire clk_b_130mhz_neg20deg;
    wire clk_c_65mhz;
    wire clk_d_32_5mhz;
    wire clk_e_10mhz;
    wire mmcm_locked;
    wire mmcm_feedback;

    IBUFDS ibufds_inst (.I(clk_p), .IB(clk_n), .O(clk_in_unbuf));
    BUFG bufg_inst (.I(clk_in_unbuf), .O(clk_in));

    // --- Экземпляр MMCM с параметрами для варианта 33 ---
    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKOUT4_CASCADE("FALSE"),
        .STARTUP_WAIT("FALSE"),
        .DIVCLK_DIVIDE(10),       // D
        .CLKFBOUT_MULT_F(39.0),   // M
        .CLKIN1_PERIOD(5.0),
        // --- Выход A: 130 MHz ---
        .CLKOUT0_DIVIDE_F(6.0),    // O0
        .CLKOUT0_PHASE(0.0),
        .CLKOUT0_DUTY_CYCLE(0.5),
        // --- Выход B: 130 MHz -20 deg ---
        .CLKOUT1_DIVIDE(6),       // O1
        .CLKOUT1_PHASE(-22.5),
        .CLKOUT1_DUTY_CYCLE(0.5),
        // --- Выход C: 65 MHz ---
        .CLKOUT2_DIVIDE(12),      // O2
        // --- Выход D: 32.5 MHz ---
        .CLKOUT3_DIVIDE(24),      // O3
        // --- Выход E: 10 MHz ---
        .CLKOUT4_DIVIDE(78)       // O4
    )
    mmcm_inst (
        .CLKIN1(clk_in),
        .CLKFBOUT(mmcm_feedback),
        .CLKFBIN(mmcm_feedback),
        .CLKOUT0(clk_a_130mhz),
        .CLKOUT1(clk_b_130mhz_neg20deg),
        .CLKOUT2(clk_c_65mhz),
        .CLKOUT3(clk_d_32_5mhz),
        .CLKOUT4(clk_e_10mhz),
        .LOCKED(mmcm_locked),
        .PWRDWN(1'b0),
        .RST(1'b0)
    );

    // --- Медленный счётчик (делитель до 0.5 Гц) ---
    // Новый лимит: 130,000,000 / 0.5 = 260,000,000
    localparam DIVIDER_MAX = 260_000_000 - 1;
    reg [27:0] slow_clk_counter = 0; 
    reg slow_clk_tick = 0;

    always @(posedge clk_a_130mhz) begin
        if (!mmcm_locked) begin
            slow_clk_counter <= 0;
            slow_clk_tick <= 0;
        end else begin
            if (slow_clk_counter == DIVIDER_MAX) begin
                slow_clk_counter <= 0;
                slow_clk_tick <= 1'b1;
            end else begin
                slow_clk_counter <= slow_clk_counter + 1;
                slow_clk_tick <= 1'b0;
            end
        end
    end
    
    reg [5:0] main_counter = 0;

    always @(posedge clk_a_130mhz) begin
        if (slow_clk_tick) begin
            main_counter <= main_counter + 1;
        end
    end

    // --- Экземпляр модуля из ЛР№1 (Вариант 33) ---
    wire func_result;
    
    lab1_v33_structural_lut lab1_inst (
        .X(main_counter[5]), .Y(main_counter[4]), .Z(main_counter[3]),
        .K(main_counter[2]), .L(main_counter[1]), .N(main_counter[0]),
        .F(func_result)
    );

    // --- Вывод на светодиоды ---
    assign leds[0]   = func_result;
    assign leds[6:1] = main_counter;
    assign leds[7]   = mmcm_locked;

endmodule
