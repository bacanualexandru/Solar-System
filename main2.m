clear; clc; close all;

%% ====== Initial conditions (m, m/s) - SSB, 2026-01-05 00:00 TDB ======

% Sun
r0_sun = [-4.545728382786301e8,  -8.276568449707576e8,   1.961830981850158e7];
v0_sun = [ 1.240794959337140e1,   3.715086392214070e-1, -2.355967972716934e-1];

% Mercury
r0_mercury = [-2.047126786295709e10, -6.756979520609458e10, -3.598782844601441e9];
v0_mercury = [ 3.688967406651244e4,  -1.156353647878473e4,  -4.327613920407869e3];

% Venus (din mesajul tău)
r0_venus = [ 2.466623144659562e10, -1.067050957545007e11, -2.884431896068119e9 ];
v0_venus = [ 3.385111623982429e4,   7.964606876781507e3,  -1.843302337195575e3 ];

% Earth
r0_earth = [-3.674819249611515e10,  1.417254602432050e11,  1.107419025086612e7];
v0_earth = [-2.932833813549416e4,  -7.454580586702656e3,   1.281451043023907e0];

% Mars (din mesajul tău)
r0_mars = [ 5.890058927525356e10, -2.054352265771336e11, -5.723569124599591e9 ];
v0_mars = [ 2.419929094973271e4,   8.833802656020515e3,  -4.082212224148574e2 ];

% Jupiter (din mesajul tău)
r0_jupiter = [-2.581961252492667e11,  7.352528153797697e11,  2.728530659276962e9 ];
v0_jupiter = [-1.248181988542958e4,  -3.708993617785039e3,  2.947542560818348e2 ];

% Saturn (din mesajul tău)
r0_saturn = [ 1.421542672516145e12,  4.105894930775417e10, -5.731339782395852e10 ];
v0_saturn = [-8.107263566690331e2,   9.634294046017345e3,  -1.351595637890171e2 ];

% Uranus (din mesajul tău)
r0_uranus = [ 1.475568135837173e12,  2.513500878676438e12, -9.781264245585561e9 ];
v0_uranus = [-5.923017455048701e3,   3.130224083387799e3,   8.819302135178497e1 ];

% Neptune (din mesajul tău)
r0_neptune = [ 4.468301631761783e12,  7.869380241690584e10, -1.045970773808444e11 ];
v0_neptune = [-1.307249534921656e2,   5.467047296925496e3,  -1.098437798074252e2 ];

% Pack to 9x3
R0 = [
    r0_sun
    r0_mercury
    r0_venus
    r0_earth
    r0_mars
    r0_jupiter
    r0_saturn
    r0_uranus
    r0_neptune
];

V0 = [
    v0_sun
    v0_mercury
    v0_venus
    v0_earth
    v0_mars
    v0_jupiter
    v0_saturn
    v0_uranus
    v0_neptune
];

%% ====== Simulation time ======
tsim = 88*24*3600;   

%% ====== Run Simulink model ======
mdl = 'solar3bodies';   % <-- schimbă cu numele .slx al tău (fără extensie)

assignin('base','R0',R0);
assignin('base','V0',V0);

load_system(mdl);
set_param(mdl,'StopTime',num2str(tsim));
out = sim(mdl);

%% ====== Plot XY ======
Rsim = out.Rsim;     % To Workspace trebuie să fie 'Rsim' (Timeseries)
D = Rsim.Data;
t = Rsim.Time;
T = numel(t);

% Convert to [T x 3 x N]
sz = size(D);
if ndims(D)==3
    if sz(1)==T
        R = D;
    elseif sz(3)==T
        R = permute(D,[3 2 1]);
    elseif sz(2)==T
        R = permute(D,[2 1 3]);
    else
        error('Nu pot identifica dimensiunea timpului în Rsim.Data.');
    end
else
    if size(D,1)==T
        N = round(size(D,2)/3);
        R = reshape(D,[T 3 N]);
    else
        N = round(size(D,1)/3);
        R = reshape(D.',[T 3 N]);
    end
end

names = {'Sun','Mercury','Venus','Earth','Mars','Jupiter','Saturn','Uranus','Neptune'};

figure; grid on; hold on;
for k=1:9
    plot(R(:,1,k), R(:,2,k));
end

% soare mai vizibil (doar punct)
plot(R(1,1,1), R(1,2,1), 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'y', 'MarkerEdgeColor','k');

axis equal
legend(names,'Location','bestoutside');
xlabel('X [m]'); ylabel('Y [m]');
title('Traiectorii (plan XY) - Soare + 8 planete (SSB)');

%% cerinta 2
% Presupunem ca ai deja:
% R = [T x 3 x N] din Rsim.Data, exact ca in main-ul tau
% names = {'Sun','Mercury','Venus','Earth','Mars','Jupiter','Saturn','Uranus','Neptune'};

names = {'Sun','Mercury','Venus','Earth','Mars','Jupiter','Saturn','Uranus','Neptune'};
N = size(R,3);

x = squeeze(R(:,1,:));   % [T x N]
y = squeeze(R(:,2,:));   % [T x N]

figure; grid on; hold on;
axis equal
xlabel('X [m]'); ylabel('Y [m]');
title('Animatie - Soare + 8 planete (plan XY)');

% 1) traseaza orbitele (linie fina)
for i = 1:N
    plot(x(:,i), y(:,i));
end
legend(names,'Location','best');

% 2) puncte care se misca (marker)
h = gobjects(N,1);
for i = 1:N
    if i==1
        h(i) = plot(x(1,i), y(1,i), 'o', 'MarkerSize', 10); % Soarele mai mare
    else
        h(i) = plot(x(1,i), y(1,i), 'o', 'MarkerSize', 5);
    end
end

% 3) animatie
T = size(x,1);
step = max(1, floor(T/1000));  % limiteaza numarul de cadre (sa nu mearga prea greu)

for k = 1:step:T
    for i = 1:N
        set(h(i), 'XData', x(k,i), 'YData', y(k,i));
    end
    drawnow;
end
%%cerinta 3
%% Distanta fata de Soare (magnitudinea vectorului de pozitie relativa)

N = size(R,3);     % numar corpuri (Soare + planete)
T = size(R,1);     % numar pasi de timp

% coordonatele Soarelui
rS = R(:,:,1);     % [T x 3]

dist = zeros(T, N-1);   % distantele planetelor fata de Soare

for i = 2:N
    r_i = R(:,:,i);                 % pozitia planetei i
    dr  = r_i - rS;                 % vector relativ
    dist(:,i-1) = sqrt(sum(dr.^2,2));  % norma
end
figure; hold on; grid on;

plot(t/86400, dist(:,1), 'DisplayName','Mercury');
plot(t/86400, dist(:,2), 'DisplayName','Venus');
plot(t/86400, dist(:,3), 'DisplayName','Earth');
plot(t/86400, dist(:,4), 'DisplayName','Mars');
plot(t/86400, dist(:,5), 'DisplayName','Jupiter');
plot(t/86400, dist(:,6), 'DisplayName','Saturn');
plot(t/86400, dist(:,7), 'DisplayName','Uranus');
plot(t/86400, dist(:,8), 'DisplayName','Neptune');

xlabel('Timp [zile]');
ylabel('Distanța față de Soare [m]');
title('Distanța planetelor față de Soare în timp');
legend('Location','best');

%%cerinta 4
%% === 1) Ia pozitiile din out.Rsim (timeseries) si adu-le in format [T x 3 x N] ===
Rsim = out.Rsim;      % timeseries
D = Rsim.Data;
t = Rsim.Time;        % [s]
T = numel(t);

sz = size(D);

if ndims(D)==3
    if sz(1) == T
        R = D;                     % [T x 3 x N]
    elseif sz(3) == T
        R = permute(D,[3 2 1]);    % [N x 3 x T] -> [T x 3 x N]
    elseif sz(2) == T
        R = permute(D,[2 1 3]);    % [3 x T x N] -> [T x 3 x N]
    else
        disp('size(Rsim.Data)='); disp(sz);
        error('Nu pot identifica dimensiunea timpului in Rsim.Data.');
    end
elseif ismatrix(D)
    % [T x 3N] sau [(3N) x T]
    if sz(1) == T
        N = sz(2)/3;  N = round(N);
        R = reshape(D,[T 3 N]);
    elseif sz(2) == T
        N = sz(1)/3;  N = round(N);
        R = reshape(D.',[T 3 N]);
    else
        disp('size(Rsim.Data)='); disp(sz);
        error('Format 2D nerecunoscut pentru Rsim.Data.');
    end
else
    disp('size(Rsim.Data)='); disp(sz);
    error('Format nerecunoscut pentru Rsim.Data.');
end

%% === 2) Indicii pentru corpuri (ajusteaza daca ai alta ordine) ===
iMercury = 2;
iEarth   = 4;

rM = squeeze(R(:,:,iMercury));   % [T x 3]
rE = squeeze(R(:,:,iEarth));     % [T x 3]

%% === 3) Vector relativ Mercur fata de Pamant ===
rME = rM - rE;                    % [T x 3]
x = rME(:,1); y = rME(:,2); z = rME(:,3);
r = sqrt(x.^2 + y.^2 + z.^2);

%% === 4) Conversie in coordonate ecliptice sferice (lambda, beta) ===
lambda = atan2(y, x);            % rad, in [-pi, pi]
beta   = asin(z ./ r);           % rad, in [-pi/2, pi/2]

% in grade pentru plot
lambda_deg = rad2deg(lambda);
beta_deg   = rad2deg(beta);

% "unwrap" pe lambda ca sa fie continua in timp (pentru detectie retrograd)
lambda_unw = unwrap(lambda);              % rad
lambda_unw_deg = rad2deg(lambda_unw);     % deg continuu

%% === 5) Detectie retrograd: cand d(lambda)/dt < 0 ===
dl = diff(lambda_unw);           % rad/step
retro = [false; dl < 0];         % retrograd pe esantion (al doilea incolo)

%% === 6) Plot 1: Traiectoria aparenta pe sfera cereasca (beta vs lambda) ===
figure; grid on; hold on;

% Pentru reprezentare frumoasa pe cer, folosim lambda in [0, 360)
lambda_wrap = mod(lambda_deg, 360);

% traseu complet
plot(lambda_wrap, beta_deg, 'LineWidth', 1.2);

% puncte retrograde evidențiate
plot(lambda_wrap(retro), beta_deg(retro), '.', 'MarkerSize', 10);

xlabel('\lambda [deg]');
ylabel('\beta [deg]');
title('Mercur văzut de pe Pământ: traiectorie aparentă (ecliptic \lambda,\beta)');
legend('Traiectorie', 'Segmente retrograde', 'Location', 'best');

% Optional: daca vrei axa ca la "sfera cereasca" (lambda creste spre stanga)
% set(gca,'XDir','reverse');

%% === 7) Plot 2: Lambda in timp + evidentiere retrograd (super clar pentru profesor) ===
t_days = t / 86400;

figure; grid on; hold on;
plot(t_days, lambda_unw_deg, 'LineWidth', 1.2);
plot(t_days(retro), lambda_unw_deg(retro), '.', 'MarkerSize', 10);
xlabel('Timp [zile]');
ylabel('\lambda (unwrap) [deg]');
title('Detectie miscare retrograda: cand d\lambda/dt < 0');
legend('\lambda(t)', 'Retrograd (d\lambda/dt<0)', 'Location', 'best');

%% ================= CERINTA 6 – EROARE vs JPL HORIZONS =================

names = {'Sun','Mercury','Venus','Earth','Mars','Jupiter','Saturn','Uranus','Neptune'};

%% 1) Starea finala din simulare (deja ai R)
r_sim_tf = squeeze(R(end,:,:)).';   % [9 x 3] m

% viteza (ideal Vsim)
if isfield(out,'Vsim')
    Vsim = out.Vsim.Data;
    v_sim_tf = squeeze(Vsim(end,:,:)).';   % m/s
else
    % fallback numeric
    tR = Rsim.Time;
    v_num = zeros(size(R));
    for k = 1:9
        for ax = 1:3
            v_num(:,ax,k) = gradient(R(:,ax,k), tR);
        end
    end
    v_sim_tf = squeeze(v_num(end,:,:)).';
end

%% 2) VALORI JPL HORIZONS la tf = 2026-APR-03 00:00:00 (SSB)
% !!! AICI PUI TU VALORILE COPIATE DIN HORIZONS !!!

r_jpl_tf = [   % [km]
%   X              Y              Z
  -3.616003227749719E+05, -8.192423808450673E+05,  1.778708357190009E+04      % Sun
  -2.028082985558694E+07, -6.759144756871383E+07, -3.612099836878795E+06      % Mercury
   4.811462572871421E+07,  9.560269671181457E+07, -1.454561905026384E+06      % Venus
  -1.461431252278180E+08, -3.416746724293388E+07,  2.090734304756112E+04      % Earth
   1.949880837152146E+08, -6.807925475825010E+07, -6.181866486145157E+06      % Mars
  -3.507794993240795E+08,  7.012146368169739E+08,  4.941629827973813E+06      % Jupiter
   1.413475903980711E+09,  1.142257336030921E+08, -5.826491325496256E+07      % Saturn
   1.430307839394412E+09,  2.536909400166550E+09, -9.108048161879420E+06      % Uranus
   4.467109674878343E+09,  1.202539467436051E+08, -1.054254661131802E+08      % Neptune
];

v_jpl_tf = [   % [km/s]
%   VX             VY             VZ
   1.199969690492604E-02,  1.875178447095301E-03, -2.435006393185419E-04       % Sun
   3.691006741069901E+01, -1.149347776136536E+01, -4.323886504027616E+00       % Mercury
   -3.139114555388979E+01,  1.557352174451042E+01,  2.025636990220985E+00      % Venus
  6.166716592132496E+00, -2.913697830786867E+01,  2.270145697339743E-03       % Earth
   8.827346511391589E+00,  2.498350147678883E+01,  3.071218025594025E-01       % Mars
  -1.184271712142686E+01, -5.228344341582996E+00,  2.866089711755848E-01       % Jupiter
  -1.311462456005964E+00,  9.607499338600075E+00, -1.149433813232608E-01       % Saturn
  -5.982546239657426E+00,  3.027135949170359E+00,  8.858974502157868E-02       % Uranus
  -1.812803286836775E-01,  5.466025960987224E+00, -1.085477526075893E-01       % Neptune
];

% Conversie in SI
r_jpl_tf = r_jpl_tf * 1000;   % km -> m
v_jpl_tf = v_jpl_tf * 1000;   % km/s -> m/s

%% 3) Erori
er = r_sim_tf - r_jpl_tf;
ev = v_sim_tf - v_jpl_tf;

er_norm = vecnorm(er,2,2);    % [m]
ev_norm = vecnorm(ev,2,2);    % [m/s]

Rez = table(names(:), er_norm, ev_norm, ...
    'VariableNames', {'Body','pos_err_m','vel_err_mps'});

disp(Rez);
writetable(Rez,'erori_tf_88zile.csv');

%% Plot pentru raport
figure; bar(er_norm);
set(gca,'XTickLabel',names,'XTickLabelRotation',45);
ylabel('||e_r|| [m]');
title('Eroare pozitie vs JPL Horizons (tf=88 zile)');
%% cerinta 5
%% cerinta_RK4_compare.m
% RK4 fix-step pentru Soare + 8 planete, comparat cu "punctul 1" (Simulink)
clear; clc; close all;

%% ====== Constante si mase (kg) ======
G = 6.67430e-11;  % [m^3/(kg*s^2)]

names = {'Sun','Mercury','Venus','Earth','Mars','Jupiter','Saturn','Uranus','Neptune'};

m = [ ...
    1.9885e30;      % Sun
    3.3011e23;      % Mercury
    4.8675e24;      % Venus
    5.97219e24;     % Earth
    6.4171e23;      % Mars
    1.89813e27;     % Jupiter
    5.6834e26;      % Saturn
    8.6813e25;      % Uranus
    1.02409e26      % Neptune
];

%% ====== Conditii initiale (m, m/s) - exact ca la tine ======
r0_sun = [-4.545728382786301e8,  -8.276568449707576e8,   1.961830981850158e7];
v0_sun = [ 1.240794959337140e1,   3.715086392214070e-1, -2.355967972716934e-1];

r0_mercury = [-2.047126786295709e10, -6.756979520609458e10, -3.598782844601441e9];
v0_mercury = [ 3.688967406651244e4,  -1.156353647878473e4,  -4.327613920407869e3];

r0_venus = [ 2.466623144659562e10, -1.067050957545007e11, -2.884431896068119e9 ];
v0_venus = [ 3.385111623982429e4,   7.964606876781507e3,  -1.843302337195575e3 ];

r0_earth = [-3.674819249611515e10,  1.417254602432050e11,  1.107419025086612e7];
v0_earth = [-2.932833813549416e4,  -7.454580586702656e3,   1.281451043023907e0];

r0_mars = [ 5.890058927525356e10, -2.054352265771336e11, -5.723569124599591e9 ];
v0_mars = [ 2.419929094973271e4,   8.833802656020515e3,  -4.082212224148574e2 ];

r0_jupiter = [-2.581961252492667e11,  7.352528153797697e11,  2.728530659276962e9 ];
v0_jupiter = [-1.248181988542958e4,  -3.708993617785039e3,  2.947542560818348e2 ];

r0_saturn = [ 1.421542672516145e12,  4.105894930775417e10, -5.731339782395852e10 ];
v0_saturn = [-8.107263566690331e2,   9.634294046017345e3,  -1.351595637890171e2 ];

r0_uranus = [ 1.475568135837173e12,  2.513500878676438e12, -9.781264245585561e9 ];
v0_uranus = [-5.923017455048701e3,   3.130224083387799e3,   8.819302135178497e1 ];

r0_neptune = [ 4.468301631761783e12,  7.869380241690584e10, -1.045970773808444e11 ];
v0_neptune = [-1.307249534921656e2,   5.467047296925496e3,  -1.098437798074252e2 ];

R0 = [r0_sun; r0_mercury; r0_venus; r0_earth; r0_mars; r0_jupiter; r0_saturn; r0_uranus; r0_neptune];
V0 = [v0_sun; v0_mercury; v0_venus; v0_earth; v0_mars; v0_jupiter; v0_saturn; v0_uranus; v0_neptune];

%% ====== Setari RK4 ======
h = 600;                 % pas fix [s] (ex cerinta)
Tsim = 7*24*3600;        % 1 saptamana
t = (0:h:Tsim).';
Nt = numel(t);
N = 9;

% stocare
Rrk = zeros(Nt,3,N);
Vrk = zeros(Nt,3,N);
Rrk(1,:,:) = permute(R0,[3 2 1]);   % [1 x 3 x N]
Vrk(1,:,:) = permute(V0,[3 2 1]);

%% ====== Integrare RK4 ======
% Stare y = [r1..rN v1..vN] (6N)
y = [R0(:); V0(:)];

for k = 1:Nt-1
    k1 = f_nbody(y, m, G, N);
    k2 = f_nbody(y + 0.5*h*k1, m, G, N);
    k3 = f_nbody(y + 0.5*h*k2, m, G, N);
    k4 = f_nbody(y + h*k3,     m, G, N);

    y = y + (h/6)*(k1 + 2*k2 + 2*k3 + k4);

    Rk = reshape(y(1:3*N), [N,3]);
    Vk = reshape(y(3*N+1:end), [N,3]);

    Rrk(k+1,:,:) = permute(Rk,[3 2 1]);
    Vrk(k+1,:,:) = permute(Vk,[3 2 1]);
end

%% ====== (PUNCTUL 1) Ruleaza Simulink pe 1 saptamana si esantioneaza la acelasi pas ======
mdl = 'solar3bodies';
assignin('base','R0',R0);
assignin('base','V0',V0);

load_system(mdl);
set_param(mdl,'StopTime',num2str(Tsim));

out = sim(mdl);           % trebuie out.Rsim (si ideal out.Vsim)
Rsim = out.Rsim;          % timeseries

% Convertim Rsim.Data la [T x 3 x N] ca la tine
D = Rsim.Data;
ts = Rsim.Time;
Tts = numel(ts);

% reformat
sz = size(D);
if ndims(D)==3
    if sz(1)==Tts, Rsim3 = D;
    elseif sz(3)==Tts, Rsim3 = permute(D,[3 2 1]);
    elseif sz(2)==Tts, Rsim3 = permute(D,[2 1 3]);
    else, error('Format Rsim.Data nerecunoscut.');
    end
else
    if sz(1)==Tts
        Ns = round(sz(2)/3);
        Rsim3 = reshape(D,[Tts 3 Ns]);
    else
        Ns = round(sz(1)/3);
        Rsim3 = reshape(D.',[Tts 3 Ns]);
    end
end

% esantionare la aceleasi momente t (0:h:Tsim)
Rref = zeros(Nt,3,N);
for i=1:N
    for ax=1:3
        Rref(:,ax,i) = interp1(ts, Rsim3(:,ax,i), t, 'pchip');
    end
end

%% ====== Comparatie: eroare RK4 vs referinta (punctul 1) ======
E = zeros(Nt,N);
for i=1:N
    dr = squeeze(Rrk(:,:,i)) - squeeze(Rref(:,:,i));
    E(:,i) = vecnorm(dr,2,2);   % [m]
end

% eroare finala dupa 1 saptamana
Eend = E(end,:).';

Rez = table(names(:), Eend, 'VariableNames', {'Body','pos_err_m'});
disp(Rez);

%% ====== Plot: orbite XY (RK4 vs ref) pentru cateva planete ======
idxShow = [1 2 3 4 5 6]; % Sun..Jupiter (ca sa se vada clar)
figure; grid on; hold on; axis equal;
for i = idxShow
    plot(Rref(:,1,i), Rref(:,2,i), '-', 'LineWidth', 1.2);      % referinta
    plot(Rrk(:,1,i),  Rrk(:,2,i),  '--', 'LineWidth', 1.2);     % RK4
end
xlabel('X [m]'); ylabel('Y [m]');
title(sprintf('Comparatie orbite XY (1 saptamana), RK4 h=%gs vs Referinta (punctul 1)', h));
legend([strcat(names(idxShow),' ref'), strcat(names(idxShow),' RK4')],'Location','bestoutside');

%% ====== Plot: eroare in timp (log) ======
figure; grid on; hold on;
for i = 2:N  % fara Soare daca vrei
    semilogy(t/86400, E(:,i));
end
xlabel('Timp [zile]');
ylabel('||r_{RK4} - r_{ref}|| [m]');
title(sprintf('Eroare pozitie RK4 (h=%gs) vs punctul 1, orizont 1 saptamana', h));
legend(names(2:end),'Location','bestoutside');

%% ==================== FUNCTII ====================
function dydt = f_nbody(y, m, G, N)
    % y = [r(:); v(:)] cu r,v in ordine pe corpuri (N x 3)
    r = reshape(y(1:3*N), [N,3]);
    v = reshape(y(3*N+1:end), [N,3]);

    a = zeros(N,3);
    for i=1:N
        ai = [0 0 0];
        ri = r(i,:);
        for j=1:N
            if j==i, continue; end
            rj = r(j,:);
            dr = (rj - ri);
            d  = norm(dr);
            ai = ai + G*m(j) * dr / (d^3 + eps);  % eps pt siguranta
        end
        a(i,:) = ai;
    end

    drdt = v;
    dvdt = a;

    dydt = [drdt(:); dvdt(:)];
end
