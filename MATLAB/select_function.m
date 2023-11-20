function w = select_function(z,zmin,zmax,t,weightingFnc)
    if weightingFnc == 1
        w = weight_uniform(z,zmin,zmax);
    elseif weightingFnc == 2
        w = weight_tent(z,zmin,zmax);
    elseif weightingFnc == 3
        w = weight_gaussian(z,zmin,zmax);
    elseif weightingFnc == 4
        w = weight_photon(z,zmin,zmax,t);
    else
        disp('weightingFnc must be an integer between 1 and 4.');
    end
end

function w = weight_uniform(z,zmin,zmax)
    index = z >= zmin & z <= zmax;
    w = index;
end

function w = weight_tent(z,zmin,zmax)
    index = z >= zmin & z <= zmax;
    [rows,cols] = size(z);
    tent = zeros(rows,cols);
    for i=1:rows
        for j=1:cols
            tent(i,j) = min([z(i,j),1-z(i,j)]);
        end
    end
    w = index.*tent;
end

function w = weight_gaussian(z,zmin,zmax)
    if max(z) > 1
        coef = 128;
    else
        coef = 0.5;
    end
    index = z >= zmin & z <= zmax;
    w = index.*exp(-4*((z-coef).^2/coef^2));
end

function w = weight_photon(z,zmin,zmax,t)
    index = z >= zmin & z <= zmax;
    w = index.*t;
end