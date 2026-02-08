// Модуль, описывающий функцию F на структурном уровне
module lab1_v33_structural_lut(
    input X, Y, Z, K, L, N, // Входные сигналы
    output F // Выходной сигнал
    );
    
    // Промежуточные сигналы для соединения LUT
    wire term_A, term_B;
    // Шаг 1: Реализуем term_A = (~X | ~Y) ^ Z с помощью одного LUT3
    // Входы: I2=Z, I1=Y, I0=X
    LUT3 #(.INIT(8'b10000111)) term_A_inst (
        .I0(X),
        .I1(Y),
        .I2(Z),
        .O(term_A)
    );
    
    // Шаг 2: Реализуем term_B = ~(K ^ ~L ^ ~N) с помощью одного LUT3
    LUT3 #(.INIT(8'b01101001)) term_B_inst (
        .I0(N),
        .I1(L),
        .I2(K),
        .O(term_B)
    );
    
    // Шаг 3: Реализуем F = term_A ^ term_B с помощью LUT2
    LUT2 #(.INIT(4'b0110)) final_F_inst (
        .I0(term_A),
        .I1(term_B),
        .O(F)
    );
endmodule
