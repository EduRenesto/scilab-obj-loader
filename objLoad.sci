function[positions, normals, triangles] = loadObj(file)
    positions = [];
    normals = [];
    triangles = [];

    lines = mgetl(file);
    for i=1:length(length(lines))
        line = lines(i);
        
        if strindex(line, "v ") == 1 then
            strtok(line, "  ");

            x = strtod(strtok("  "));
            y = strtod(strtok("  "));
            z = strtod(strtok("  "));

            positions = cat(1, positions, [x y z]);
        elseif strindex(line, "vn ") == 1 then
            strtok(line, "  ");

            x = strtod(strtok("  "));
            y = strtod(strtok("  "));
            z = strtod(strtok("  "));

            normals = cat(1, normals, [x y z]);
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

            triangles = cat(1, triangles, [pos1 pos2 pos3 norm1 norm2 norm3]);
        else 
            // nop best opcode
        end
    end
endfunction
