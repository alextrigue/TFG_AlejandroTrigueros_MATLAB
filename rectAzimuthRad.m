function [azimuth_rect_rad] = rectAzimuthRad(azimuth_rad)
%azimuth_rect_rad = azimuth_rad + pi;% azimuth en radianes rectificado
azimuth_rect_rad = azimuth_rad ;
l = length(azimuth_rect_rad);
margen_rect = 6.10865;
for i=2:l
    if (azimuth_rect_rad(i) - azimuth_rect_rad(i-1)) < (- margen_rect)
        azimuth_rect_rad(i:l) = azimuth_rect_rad(i:l) + 2*pi;
    end
    if (azimuth_rect_rad(i) - azimuth_rect_rad(i-1)) > (margen_rect)
        azimuth_rect_rad(i:l) = azimuth_rect_rad(i:l) - 2*pi;
    end
end
%azimuth_rect_rad = azimuth_rect_rad - pi;
end
