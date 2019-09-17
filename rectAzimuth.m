function [azimuth_rect] = rectAzimuth(azimuth)
%azimuth_rect = azimuth +180;
azimuth_rect = azimuth;
l = length(azimuth_rect);
for i=2:l
    % Se detecta discontinuidad
    % si hay una diferencia entre dos muestras consecutivas 
    % de 350 grados en valor ansoluto
    if azimuth_rect(i) - azimuth_rect(i-1) < -350
        %si el giro va hacia la izquierda
        azimuth_rect(i:l) = azimuth_rect(i:l) +360;
    end
    if azimuth_rect(i) - azimuth_rect(i-1) > 350
        %si el giro va hacia la derecha
        azimuth_rect(i:l) = azimuth_rect(i:l) -360;
    end
end
%azimuth_rect = azimuth_rect - 180;
end