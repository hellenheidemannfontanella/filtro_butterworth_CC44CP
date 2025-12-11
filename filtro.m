clc
clear

% impedância
R = 6;

% ordem do filtro
n = 2; 
freq_corte = 2600;
freq_corte_angular = freq_corte * 2 * pi;

% coeficientes do filtro passa-baixas (Cauer) (2.0) e (2.1)
for k=1:n
    if mod(k,2)==0
        Llp(k-1) = 2*sin((2*k-1)*pi/(2*n));
    else
        Clp(k) = 2*sin((2*k-1)*pi/(2*n));
    end
end

% transformação para passa-altas (4.0) e (4.1)
Lhp = 1./Clp;
Chp = 1./Llp;

% funções de escala (3.0) e (3.1)
escala_L = @(L) (L.*R)./(freq_corte_angular);
escala_C = @(C) (C)./(freq_corte_angular.*R);

Llp = escala_L(Llp);
Lhp = escala_L(Lhp);

Clp = escala_C(Clp);
Chp = escala_C(Chp);

% Partindo daqui, o código trata somente a resposta para um filtro de
% segunda ordem (funções de transferência de segunda ordem)

% funções de transferência (5.0) e (5.1)
y_lp_ideal = @(s) 1./(Llp(1).*Clp(1).*s.^2 + R.*Clp(1).*s + 1);
y_hp_ideal = @(s) Lhp(1).*Chp(1).*s.^2 ./ (Lhp(1).*Chp(1).*s.^2 + R.*Chp(1).*s + 1);

% grafico butterworth
x = linspace(20,20000,300);

% funções de butterworth (1.0) e (1.1)
butterworth_lp = @(x) 1 ./ (sqrt(1 + (x./freq_corte).^(2.*n)));
butterworth_hp = @(x) (x./freq_corte).^2 ./ (sqrt(1 + (x./freq_corte).^(2.*n)));

tabela_indutor = [
    0.10 0.12 0.15 0.18 0.22 0.27 ...
    0.33 0.39 0.47 0.56 0.68 0.82 ...
    1.0 1.2 1.5 1.8 2.2 2.7 ...
    3.3 3.9 4.7 5.6 6.8 8.2 ...
    10 12 15
];
tabela_indutor = tabela_indutor.*1e-03;

tabela_capacitor = [
    1.0 1.2 1.5 1.8 2.2 2.7 ...
    3.3 3.9 4.7 5.6 6.8 8.2 ...
    10 12 15 18 22 27 ...
    33 39 47 56 68 82 ...
    100 
];
tabela_capacitor = tabela_capacitor.*1e-06;
    
Llp_tabelado = interp1(tabela_indutor, tabela_indutor, Llp, 'nearest');
Clp_tabelado = interp1(tabela_capacitor, tabela_capacitor, Clp, 'nearest');

Lhp_tabelado = interp1(tabela_indutor, tabela_indutor, Lhp, 'nearest');
Chp_tabelado = interp1(tabela_capacitor, tabela_capacitor, Chp, 'nearest');

y_lp_tabelado = @(s) 1./(Llp_tabelado(1).*Clp_tabelado(1).*s.^2 + R.*Clp_tabelado(1).*s + 1);
y_hp_tabelado = @(s) Lhp_tabelado(1).*Chp_tabelado(1).*s.^2 ./ (Lhp_tabelado(1).*Chp_tabelado(1).*s.^2 + R.*Chp_tabelado(1).*s + 1);

% plot de butterworth
tiledlayout(1,2);
nexttile;
plot1 = semilogx(x, 20*log10(butterworth_lp(x)), '--k', x, 20*log10(butterworth_hp(x)), '--k');

hold on;
grid on;
axis([20 20000 -80 20])

% plot de RLC ideal
s = 1j * x * 2 * pi;
plot2 = semilogx(x, 20*log10(abs(y_lp_ideal(s))), 'r', x, 20*log10(abs(y_hp_ideal(s))), 'r');

xline(freq_corte,"--b","2600",'LabelOrientation','horizontal');
title("Gráfico de Bode dos filtros Crossover");
xlabel("Frequência (Hz)");
ylabel("Amplitude (dB)");

% plot de RLC tabelado
s = 1j * x * 2 * pi;
plot3 = semilogx(x, 20*log10(abs(y_lp_tabelado(s))), 'Color','#ff9000');
semilogx(x, 20*log10(abs(y_hp_tabelado(s))), 'Color','#ff9000');
legend([plot1(1), plot2(1), plot3(1)], ...
    {'Filtro de Butterworth','Filtro RLC Ideal', 'Filtro RLC Tabelado'}, ...
    'Location', 'southwest');

nexttile;
plot1 = semilogx(x, 20*log10(butterworth_lp(x)), '--k', x, 20*log10(butterworth_hp(x)), '--k');

hold on;
grid on;
axis([200 14000 -15 3])

% plot de RLC ideal
s = 1j * x * 2 * pi;
plot2 = semilogx(x, 20*log10(abs(y_lp_ideal(s))), 'r', x, 20*log10(abs(y_hp_ideal(s))), 'r');

xline(freq_corte,"--b","2600",'LabelOrientation','horizontal');
title("Gráfico de Bode dos filtros Crossover");
xlabel("Frequência (Hz)");
ylabel("Amplitude (dB)");

% plot de RLC tabelado
s = 1j * x * 2 * pi;
plot3 = semilogx(x, 20*log10(abs(y_lp_tabelado(s))), 'Color','#ff9000');
semilogx(x, 20*log10(abs(y_hp_tabelado(s))), 'Color','#ff9000');
legend([plot1(1), plot2(1), plot3(1)], ...
    {'Filtro de Butterworth','Filtro RLC Ideal', 'Filtro RLC Tabelado'}, ...
    'Location', 'southwest');

format shortEng;
disp("Indutor de passa-baixas idealizado: " + Llp);

disp("Capacitor de passa-baixas idealizado: " + Clp);

disp("Indutor de passa-altas idealizado: " + Lhp);

disp("Capacitor de passa-altas idealizado: " + Chp + newline);


disp("Indutor de passa-baixas real: " + Llp_tabelado);

disp("Capacitor de passa-baixas real: " + Clp_tabelado);

disp("Indutor de passa-altas real: " + Lhp_tabelado);

disp("Capacitor de passa-altas real: " + Chp_tabelado);


