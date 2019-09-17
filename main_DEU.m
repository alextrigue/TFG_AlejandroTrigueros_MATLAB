close all
clear all
clc

%% Carga de datos archivo de texto
%matrices cuya segunda columna contiene los timestamp
% acc = load("acc_prueba.txt");%datos accelerometro
% gyr = load("gyr_prueba.txt");%datos giroscopio
% az =   load("az_prueba.txt");%datos projeccion acc lineal sobre gravedad
% gz =   load("gz_prueba.txt");%datos projecccion giroscoio
% orientation_data = load("orientation_prueba.txt"); % datos orientacion
% timestamp = orientation_data(:,4);
 
load prueba_5.mat

%% Interpolado de los datos según el timestamp de la orientación
acc_fit = fit_ts(acc(:,1:3),acc(:,4),timestamp);

gz_fit = fit_ts(gz(:,1),gz(:,2),timestamp);

az_fit = fit_ts(az(:,1),az(:,2),timestamp);

%% Azimut rectificado en grados
azimuth = rad2deg(orientation_data(:,1));% azimuth en grados
azimuth_rect = rectAzimuth(azimuth);% azimuith en grados rectificado

%% Azimut rectificado en radianes
% prueba para implementacion en Android
azimuth_rad = orientation_data(:,1);% azimuth en radianes
azimuth_rect_rad = rectAzimuthRad(azimuth_rad);% azimuth en radianes rectificado

%% Recorte de los datos para mejor representación
% Al iniciar y finalizar el registro de datos hay demasiado ruido por la
% manipulación del dispositivo
% quitamos muestras al principio y al final de los datos

recorte = 100;
inicio = recorte;
final = length(timestamp) - recorte;

acc_fit = acc_fit(inicio:final);
az_fit = az_fit(inicio:final);
gz_fit = gz_fit(inicio:final);
azimuth = azimuth(inicio:final);
azimuth_rect = azimuth_rect(inicio:final);
orientation_data = orientation_data(inicio:final, :);
timestamp = timestamp(inicio:final);

% prueba para implementacion en Android
azimuth_rad = azimuth_rad(inicio:final);
azimuth_rect_rad = azimuth_rect_rad(inicio:final);


%% Representacion de los datos brutos
% pasamos eje de tiempos de nanosegundos a segundos
time_axis = (timestamp - timestamp(1))/1e9;

figure('Position', [300 300 600 600])

subplot(4,1,1)
plot(time_axis, az_fit, 'b');
xlabel('Tiempo(s)')
ylabel('m/s^2')
title('1. Proyección de aceleración.')

subplot(4,1,2)
plot(time_axis, gz_fit, 'r')
xlabel('Tiempo(s)')
ylabel('rad/s')
title('2. Proyección giroscopio.')

subplot(4,1,3)
plot(time_axis, azimuth, 'g')
xlabel('Tiempo(s)')
ylabel('Grados')
title('3. Azimut')

subplot(4,1,4)
plot(time_axis, azimuth_rect, 'm')
xlabel('Tiempo(s)')
ylabel('Grados')
title('4. Azimut rectificado.')

figure('Position', [300 300 600 400])
subplot(2,1,1)
plot(time_axis, azimuth, 'g')
xlabel('Tiempo(s)')
ylabel('Grados')
title('1. Azimut')

subplot(2,1,2)
plot(time_axis, azimuth_rect, 'm')
xlabel('Tiempo(s)')
ylabel('Grados')
title('2. Azimut rectificado.')

%% Prueba para implementacion en Android
figure('Position', [300 300 600 400])

subplot(2,1,1)
plot(time_axis, azimuth_rad, 'g')
xlabel('Tiempo(s)')
ylabel('Radianes')
title('1. Azimut (rad).')

subplot(2,1,2)
plot(time_axis, azimuth_rect_rad, 'm')
xlabel('Tiempo(s)')
ylabel('Radianes')
title('2. Azimut rectificado (rad/s).')

%% Media a trozos de 1 segundo
intervalo = 1; % 1 segundo
az_interval = mediaInterval(abs(az_fit), time_axis,intervalo);
gz_interval = mediaInterval(gz_fit, time_axis,intervalo);
azimuth_interval = mediaInterval(azimuth, time_axis,intervalo);
azimuth_interval_rect = mediaInterval(azimuth_rect, time_axis,intervalo);
speed_interval = mediaInterval(orientation_data(:,5), time_axis,intervalo);

ts_interval = zeros(1, length(azimuth_interval));
n = 1;
i0 =1;
for i1=1:length(time_axis)
    if (time_axis(i1)-time_axis(i0)) >= (intervalo-0)
        ts_interval(n) = time_axis(i1);
        n = n+1;
        i0 = i1;
    end
end

%% Cambio de angulo cada segundo

angle_change = zeros(size(azimuth_interval_rect));
angle_change(1)=0;
for i=2:length(angle_change)
    % Calculo de la variación de azimut cada segundo
    angle_change(i) = azimuth_interval_rect(i)-azimuth_interval_rect(i-1);
end
%% Radio de giro
% long = velocidad * tiempo;
% longitud arco = radio * angulo
% radio = long / angulo

radio_giro = zeros(1,length(ts_interval));
%media = mean(angle_change);
for i=2:length(radio_giro)
    umbral_azi = 6;% grados
    umbral_vel = 2;% km/h
    if speed_interval(i) > umbral_vel
        if abs(angle_change(i)) > umbral_azi
            % si es mayor de 5 grados
            % si el cambio de angulo es mayor a 5 grados
            % calculamos el radio de giro, para evitar ruido
            long = speed_interval(i) * ((ts_interval(i) - ts_interval(i-1))/(60*60));
            % tiempo en horas, velocidad en km/h, long en km
            radio_giro(i) = (long*1000) /deg2rad(abs(angle_change(i)));
            % angulo en radianes, long en metros
        end
    else
        radio_giro(i) = 0;
    end
end

%% Representacion de los datos en intervalos de X segundos
figure('Position', [300 300 600 600])

subplot(4,1,1)
plot(ts_interval, azimuth_interval_rect, 'm', 'LineWidth', 1.25)
xlabel('Tiempo(s)')
ylabel('Grados')
title('1. Azimut rectificado y promediado por segundo.')

subplot(4,1,2)
plot(ts_interval, angle_change, 'g', 'LineWidth', 1.25)
hold on
plot(ts_interval, zeros(1, length(ts_interval))+umbral_azi, 'k:')
plot(ts_interval, zeros(1, length(ts_interval))-umbral_azi, 'k:')
hold off
hold off
xlabel('Tiempo(s)')
ylabel('Grados')
title('2. Cambio de azimut por segundo.')


subplot(4,1,3)
plot(ts_interval, speed_interval, 'b', 'LineWidth', 1.25)
hold on
plot(ts_interval, zeros(1, length(ts_interval))+umbral_vel, 'k:')
hold off
xlabel('Tiempo(s)')
ylabel('km/h')
title('3. Velocidad media.')

subplot(4,1,4)
plot(ts_interval, radio_giro, 'r', 'LineWidth', 1.25)
xlabel('Tiempo(s)')
ylabel('Metros')
title('4. Radio de Giro.')

%%
A = ['Duración total de la prueba: ', num2str(ts_interval(length(ts_interval))), ' segundos'];
disp(A)
radio_giro_z = radio_giro(radio_giro~=0);
r_med = mean(radio_giro_z);
B = ['Radio de giro promedio: ', num2str(r_med), ' metros'];
disp(B)

ang_giro = 180-(max(azimuth_interval_rect) - min(azimuth_interval_rect));
%ang_giro = azimuth_interval_rect(7)- azimuth_interval_rect(18);
C = ['Ángulo de giro: ', num2str(round(ang_giro)), ' grados'];
disp(C)