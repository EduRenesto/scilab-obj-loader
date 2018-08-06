clear; clc;

exec('matrix_math.sci');

printf("Visualizador de Modelos .obj\n");
printf("Por Eduardo Renesto Estanquiere\n");
printf("Projeto final de BCC\n");
printf("Julho/2018 - Universidade Federal do ABC\n");

printf("\n");

WIDTH = 100;
HEIGHT = 100;

clf();
a = gca();
//a.data_bounds = [minX, minY; maxX, maxY];
a.data_bounds = [0, 0; WIDTH, HEIGHT];
a.auto_scale = "off";

filename = input("Digite o nome do arquivo: ", "string");

pAspectRatio = input("Digite o aspect ratio: ");
pFovy = (input("Digite o campo de visão (em graus): ") * %pi) / 180;

vEye = [input("Digite a posição X da câmera: ") input("Digite a posição Y da câmera: ") input("Digite a posição Z da câmera: ")];

vCenter = [input("Digite a posição X do alvo: ") input("Digite a posição Y do alvo: ") input("Digite a posição Z do alvo: ")];

viewMatrix = lookAt(vEye, vCenter, [0.0 1.0 0.0]);
projectionMatrix = perspective(pFovy, pAspectRatio, 0.001, 10000.0);

mvpMatrix = (projectionMatrix' * viewMatrix')'; // sem model matrix por enquanto

lines = mgetl(filename);
lineCount = length(length(lines));

vertices = [];

indexedVertices = [];

totalTriangles = 0;

minX = +%inf;
minY = +%inf;
maxX = -%inf;
maxY = -%inf;

trigXs = [];
trigYs = [];

function[vert] = vertexAt(arr, n)
    x = arr(((n - 1) * 3) + 1);
    y = arr(((n - 1) * 3) + 2);
    z = arr(((n - 1) * 3) + 3);

    vert = [x y z];
endfunction

for i = 1:lineCount
    if strindex(lines(i), "v ") == 1 then
        // strtok precisa ser chamado várias vezes:
        // a primeira vez define a string básica
        // as outras pegam os tokens

        strtok(lines(i), " ");
        x = strtod(strtok(" "));
        y = strtod(strtok(" "));
        z = strtod(strtok(" "));

        vertices = cat(2, vertices, [x y z]);
        //vertices = cat(2, vertices, [x y z 1.0] * mvpMatrix);
    end

    if strindex(lines(i), "f ") == 1 then
        strtok(lines(i), " ");
        str1 = strtok(" ");
        str2 = strtok(" ");
        str3 = strtok(" ");

        // por enquanto, ignoramos as normais e as coordenadas de texturas
        vert1 = strtod(strtok(str1, "/"));
        //vert1 = strtod(strtok("/"));

        vert2 = strtod(strtok(str2, "/"));
        //vert2 = strtod(strtok("/"));

        vert3 = strtod(strtok(str3, "/"));
        //vert3 = strtod(strtok("/"));

        newVerts = [vertexAt(vertices, vert1) vertexAt(vertices, vert2) vertexAt(vertices, vert3)];
        
        indexedVertices = cat(2, indexedVertices, newVerts);

        trigV1 = cat(2, vertexAt(vertices, vert1), 1.0) * mvpMatrix;
        trigV2 = cat(2, vertexAt(vertices, vert2), 1.0) * mvpMatrix;
        trigV3 = cat(2, vertexAt(vertices, vert3), 1.0) * mvpMatrix;

        // convertendo pra normalized device coordinates
        trigV1_ndc = trigV1 / trigV1(4);
        trigV2_ndc = trigV2 / trigV2(4);
        trigV3_ndc = trigV3 / trigV3(4);

        // convertendo para window space
        trigV1_ws = [((WIDTH/2)*trigV1_ndc(1) + trigV1(1) + WIDTH/2) ((HEIGHT/2)*trigV1_ndc(2) + trigV1(2) + HEIGHT/2)];
        trigV2_ws = [((WIDTH/2)*trigV2_ndc(1) + trigV2(1) + WIDTH/2) ((HEIGHT/2)*trigV2_ndc(2) + trigV2(2) + HEIGHT/2)];
        trigV3_ws = [((WIDTH/2)*trigV3_ndc(1) + trigV3(1) + WIDTH/2) ((HEIGHT/2)*trigV3_ndc(2) + trigV3(2) + HEIGHT/2)];

        //xs = [vertexAt(vertices, vert1)(1) vertexAt(vertices, vert2)(1) vertexAt(vertices, vert3)(1) vertexAt(vertices, vert1)(1)];
        //ys = [vertexAt(vertices, vert1)(2) vertexAt(vertices, vert2)(2) vertexAt(vertices, vert3)(2) vertexAt(vertices, vert1)(2)];
        //zs = [vertexAt(vertices, vert1)(3) vertexAt(vertices, vert2)(3) vertexAt(vertices, vert3)(3) vertexAt(vertices, vert1)(3)];

//        xs = [trigV1(1) trigV2(1) trigV3(1) trigV1(1)];
//        ys = [trigV1(2) trigV2(2) trigV3(2) trigV1(2)];        

        xs = [trigV1_ws(1) trigV2_ws(1) trigV3_ws(1) trigV1_ws(1)];
        ys = [trigV1_ws(2) trigV2_ws(2) trigV3_ws(2) trigV1_ws(2)];        

        mx = min(xs);
        my = min(ys);
        Mx = max(xs);
        My = max(ys);

        if(mx < minX)
            minX = mx;
        end
        if(my < minY)
            minY = my;
        end
        if(Mx > maxX)
            maxX = Mx;
        end
        if(My > maxY)
            maxY = My;
        end

        xpoly(xs, ys);
        totalTriangles = totalTriangles + 1;
    end
end

// plotX = [];
// plotY = [];
// plotZ = [];
// 
// for i=1:3:(length(indexedVertices) / 3)
//     plotX = cat(2, plotX, [indexedVertices(i)]);
//     plotY = cat(2, plotY, [indexedVertices(i+1)]);
//     plotZ = cat(2, plotZ, [indexedVertices(i+2)]);
// end

printf("Total de vertices: %i\n", length(indexedVertices));
printf("Total de triangulos: %i\n", totalTriangles);
