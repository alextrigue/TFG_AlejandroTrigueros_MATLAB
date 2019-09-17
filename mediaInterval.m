function [dat_interval] = media_interval(dat,ts,intervalo)
% Calcula la media en intervalos
% parametros: datos del sensor, timestamp, intervalo de calculo de medias
n = 1;
i0 =1;
for i1=1:length(dat)
    if (ts(i1)-ts(i0)) >= (intervalo-0)
        dat_interval(n) = mean(dat(i0:i1));
        n = n+1;
        i0 = i1;
    end
end
end