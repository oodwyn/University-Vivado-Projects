`timescale 1ns / 1ps

// Модуль из ЛР№1, вариант 33
module lab1_v33_structural_lut(
    input  X, Y, Z, K, L, N,
    output F
    );

    wire term_A, term_B;

    LUT3 #(.INIT(8'b10000111)) term_A_inst ( 
        .I0(X), 
        .I1(Y), 
        .I2(Z), 
        .O(term_A)
    );

    LUT3 #(.INIT(8'b01101001)) term_B_inst (
        .I0(N), 
        .I1(L), 
        .I2(K), 
        .O(term_B)
    );

    LUT2 #(.INIT(4'b0110)) final_F_inst (
        .I0(term_A), 
        .I1(term_B), 
        .O(F)
    );
endmodule