// Тестовое окружение для проверки реализаций варианта 33
`timescale 1ns / 1ps
 
module lab1_tb;
 
    // Сигналы для подачи на входы модулей
    reg X, Y, Z, K, L, N;
   
    // Сигналы для съема выходов
    wire F_behav;    // Выход поведенческой модели
    wire F_struct;   // Выход структурной модели
 
    // Создаем экземпляры двух модулей
    lab1_behavioral uut_behav (
        .X(X), .Y(Y), .Z(Z), .K(K), .L(L), .N(N),
        .F(F_behav)
    );
 
    lab1_structural_lut uut_struct (
        .X(X), .Y(Y), .Z(Z), .K(K), .L(L), .N(N),
        .F(F_struct)
    );
 
    // Вспомогательные переменные для процесса тестирования
    integer i;
    integer errors;
 
    // Основной процесс тестирования
    initial begin
        // Инициализируем переменные
        errors = 0;
       
        $display("--- Начало тестирования варианта 33 ---");
        $display("Входы  | F_behav | F_struct | Результат");
        $display("-------------------------------------------------");
       
        // Перебираем все 2^6 = 64 комбинации
        for (i = 0; i < 64; i = i + 1) begin
            {X, Y, Z, K, L, N} = i;
            #10; // Задержка для стабилизации сигналов
           
            if (F_behav !== F_struct) begin
                $display("%b |    %b    |    %b     | ОШИБКА!", {X,Y,Z,K,L,N}, F_behav, F_struct);
                errors = errors + 1;
            end else begin
                $display("%b |    %b    |    %b     | OK", {X,Y,Z,K,L,N}, F_behav, F_struct);
            end
        end
 
        #20;
 
        if (errors == 0) begin
            $display("--- ТЕСТИРОВАНИЕ ПРОШЛО УСПЕШНО! ---");
        end else begin
            $display("--- ТЕСТИРОВАНИЕ ПРОВАЛЕНО! Найдено ошибок: %d ---", errors);
        end
       
        $stop;
    end
 
endmodule