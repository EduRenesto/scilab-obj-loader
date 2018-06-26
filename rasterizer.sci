filename = input("Digite o nome do arquivo: ", "string");

lines = mgetl(filename);
lineCount = length(length(lines));

vertices = [];

indexedVertices = [];

function[vert] = vertexAt(arr, n)
    x = arr(((n - 1) * 3) + 1)
    y = arr(((n - 1) * 3) + 2)
    z = arr(((n - 1) * 3) + 3)

    vert = [x y z]
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

        disp([vert1 vert2 vert3]);

        newVerts = [vertexAt(vertices, vert1) vertexAt(vertices, vert2) vertexAt(vertices, vert3)];
        
        indexedVertices = cat(2, indexedVertices, newVerts);
    end
end

plotX = []
plotY = []

for i=1:3:(length(indexedVertices) / 3)
    plotX = cat(2, plotX, [indexedVertices(i)])
    plotY = cat(2, plotY, [indexedVertices(i+1)])
end
