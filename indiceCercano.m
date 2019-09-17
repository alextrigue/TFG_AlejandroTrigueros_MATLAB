function [pos] = indiceCercano(ts, x_ts)
% devuelve posicion de los datos x cuyo timestamp es parecido a ts
%x_ts : columna que contiene los timestamps de los datos
[~, pos] = min(abs(x_ts-ts)); 
end

