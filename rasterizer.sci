clear; clc;

exec("matrix_math.sci");
exec("objLoad.sci");

// Ask these to the user
filename = "suzanne.obj";
width = 600;
height = 600;
zNear = 0.0001;
zFar = 10000.0;
fovy = %pi/4;
camera = [0 0 -3];
model = [0 0 0];

projectionMatrix = perspective(fovy, width/height,  zNear, zFar);
viewMatrix = lookAt(camera, model, [0.0 1.0 0.0]);

mvp = (projectionMatrix' * viewMatrix')';

[positions, normals, triangles] = loadObj(filename);

// ]----- RASTERIZADOR -----[
clearR = 0;
clearG = 0;
clearB = 0;
frame = ones(width, height) * color(clearR, clearG, clearB);
depthBuffer = ones(width, height) * -%inf;
source = [0 0 -1];

objectColor = [0.188 0.082 0.082];

lightPosition = [3 3 3];
lightIntensity = 2;
lightColor = [1 1 1];

function[dist] = edgeFunction(v1, v2, point)
    dist = ((point(1) - v1(1)) * (v2(2) - v1(2)) - (point(2) - v1(2)) * (v2(1) - v1(1)));
    //dist = ((v1(1) - v2(1)) * (point(2) - v1(2))) - ((v1(2) - v2(2)) * (point(1) - v1(1)));
endfunction

for i=1:size(triangles)(1) // triangles
    v1 = [positions(triangles(i, 1), :) 1.0];
    n1 = normals(triangles(i, 4), :);
    
    v2 = [positions(triangles(i, 2), :) 1.0];
    n2 = normals(triangles(i, 5), :);
    
    v3 = [positions(triangles(i, 3), :) 1.0];
    n3 = normals(triangles(i, 6), :);

    // convertendo para clip space
    cv1 = v1 * mvp;
    cv2 = v2 * mvp;
    cv3 = v3 * mvp;

    // convertendo para NDC
    ndcv1 = cv1 / cv1(4);
    ndcv2 = cv2 / cv2(4);
    ndcv3 = cv3 / cv3(4);

    // convertendo para window space
    wsv1 = [((width/2)*ndcv1(1) + v1(1) + width/2) ((height/2)*ndcv1(2) + v1(2) + height/2) ((zFar-zNear)/2)*ndcv1(3) + ((zFar+zNear)/2)];
    wsv2 = [((width/2)*ndcv2(1) + v2(1) + width/2) ((height/2)*ndcv2(2) + v2(2) + height/2) ((zFar-zNear)/2)*ndcv2(3) + ((zFar+zNear)/2)];
    wsv3 = [((width/2)*ndcv3(1) + v3(1) + width/2) ((height/2)*ndcv3(2) + v3(2) + height/2) ((zFar-zNear)/2)*ndcv3(3) + ((zFar+zNear)/2)];

    minX = floor(min(wsv1(1), wsv2(1), wsv3(1)));
    maxX = floor(max(wsv1(1), wsv2(1), wsv3(1)));
    minY = floor(min(wsv1(2), wsv2(2), wsv3(2)));
    maxY = floor(max(wsv1(2), wsv2(2), wsv3(2)));

    if(minX < 0 | minY < 0 | maxX > width | maxX > height)
        continue;
    end

//    xpoly([wsv1(1) wsv2(1) wsv3(1) wsv1(1)], [wsv1(2) wsv2(2) wsv3(2) wsv1(2)]);

    for x=minX:maxX
        for y=minY:maxY
            area = edgeFunction(wsv1, wsv2, wsv3);
            w0 = edgeFunction(wsv2, wsv3, [x y]);
            w1 = edgeFunction(wsv3, wsv1, [x y]);
            w2 = edgeFunction(wsv1, wsv2, [x y]);

            if ((w0 >= 0 & w1 >= 0 & w2 >= 0) | (w0 <= 0 & w1 <= 0 & w2 <= 0)) then
                w0 = w0/area;
                w1 = w1/area;
                w2 = w2/area;

                depth = (w0 * wsv1(3)) + (w1 * wsv2(3)) + (w2 * wsv3(3));

                if depthBuffer(x, y) < depth then
                    depthBuffer(x, y) = depth;

                    iPos = (w0 * v1) + (w1 * v2) + (w2 * v3);
                    iNormal = (w0 * n1) + (w1 * n2) + (w2 * n3);

                    lNorm = normalize(iNormal);
                    lightDir = normalize(lightPosition - iPos(:, 1:3));

                    diff = max(dot(lNorm, lightDir), 0.0);
                    diffuse = diff * lightColor * lightIntensity;
    
                    result = diffuse .* objectColor;
                    result = round(result * 255);

                    //frame(x, y) = color(round(abs(iNormal)(1) * 255), round(abs(iNormal)(2)) * 255, round(abs(iNormal)(3) * 255));
                    frame(x, y) = color(result(1), result(2), result(3));
                end
            end    

            clear area;
            clear w0;
            clear w1;
            clear w2;
        end
    end
    clear v1; clear v2; clear v3;
    clear cv1; clear cv2; clear cv3;
    clear ndcv1; clear ndcv2; clear ndcv3;
    clear wsv1; clear wsv2; clear wsv3;
end

Matplot(frame'($:-1:1, :));
