function[positions, normals] = loadObj(file)
    positions = [];
    normals = [];

    unindexedVertices = [];
    unindexedNormals = [];

    lines = mgetl(file);
    for i=1:length(length(lines))
        line = lines(i);
        
        if strindex(line, "v ") == 1 then
            strtok(line, "  ");

            x = strtod(strtok("  "));
            y = strtod(strtok("  "));
            z = strtod(strtok("  "));

            unindexedVertices = cat(1, unindexedVertices, [x y z]);
        elseif strindex(line, "vn ") == 1 then
            strtok(line, "  ");

            x = strtod(strtok("  "));
            y = strtod(strtok("  "));
            z = strtod(strtok("  "));

            unindexedNormals = cat(1, unindexedNormals, [x y z]);
        elseif strindex(line, "f ") == 1 then
            strtok(line, "  ");
            t1 = strtok("  ");
            t2 = strtok("  ");
            t3 = strtok("  ");

            pos1 = strtod(strtok(t1, "/"));
            strtok("/");
            norm1 = strtod(strtok("/"));

            pos2 = strtod(strtok(t2, "/"));
            strtok("/");
            norm2 = strtod(strtok("/"));

            pos3 = strtod(strtok(t3, "/"));
            strtok("/");
            norm3 = strtod(strtok("/"));

            positions = cat(1, positions, [unindexedVertices(pos1, :), 1.0; unindexedVertices(pos2, :), 1.0; unindexedVertices(pos3, :) 1.0]);
            normals = cat(1, normals, [unindexedNormals(norm1, :) 1.0; unindexedNormals(norm2, :), 1.0; unindexedNormals(norm3, :), 1.0]);
        else 
            // nop best opcode
        end
    end
endfunction
