function [x_fit] = fit_ts(x_datos, x_ts,timestamp)
% Encaja los datos de un sensor en el timpstamp de otro
[~,n] = size(x_datos);

x_fit = zeros(length(timestamp),n); 
x_fit(1,:) = x_datos(1,:);
for i=2:(length(timestamp)-1)
    % escogemos los valores del sensor cuyo ts se parezca más al ts de la
    % matriz de rotacion
    ts = timestamp(i);
   
    p1 = indiceCercano(ts, x_ts);
    if p1 < 2
        p1 = 2;
    end
    t1 = x_ts(p1);
    
    if ts > t1
        % si ts >= t1, p2 es la posicion siguiente
        %disp('ts>t1')
        p2 = p1+1;
        if p2 > length(x_ts)
            p2 = length(x_ts);
        end
    elseif ts <= t1
        % si ts < t1, p2 es la posicion anterior
        p2 = p1-1;
        %disp('ts<t1')
    end
    t2 = x_ts(p2);
    
    alpha = 0.8;
    
    
    x_fit(i,:) = x_datos(p1,:).*alpha + x_datos(p2,:).*(1-alpha);%valores
end
end

