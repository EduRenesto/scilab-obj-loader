// Normaliza um vetor.
function[y] = normalize(vec)
    y = vec/norm(vec);
endfunction

// Calcula o produto escalar de dois vetores
function[y] = dot(a, b)
    y = 0;
    for i=1:length(a)
        y = y + (a(i)*b(i));
    end
endfunction

// Cria uma matriz de projecao perspectiva.
// Baseado na funcao glm::perspective, disponivel
// em https://github.com/g-truc/glm/blob/master/glm/gtc/matrix_transform.inl
//
// fovy = Campo de Visao (em radianos)
// aspect = Aspect Ratio (width / height)
// zNear = coordenada z do near clipping pane
// zFar = coordenada z do far clipping pane
function[mat] = perspective(fovy, aspect, zNear, zFar)
    tanHalfFovy = tan(fovy / 2.0);
    
    mat = zeros(4, 4);
    mat(1, 1) = 1.0 / (aspect * tanHalfFovy);
    mat(2, 2) = 1.0 / tanHalfFovy;
    mat(3, 3) = zFar / (zNear - zFar);
    mat(3, 4) = -1.0;
    mat(4, 3) = -(zFar * zNear) / (zFar - zNear);
endfunction

// Cria uma matriz de view.
// Baseado na funcao glm::lookAt, tambem
// disponivel no link acima.
//
// eye = posicao do observador
// center = alvo
// up = vetor cima (geralmente [0.0 1.0 0.0])
function[mat] = lookAt(eye, center, up)
    f = normalize(center - eye);
    s = normalize(cross(f, up));
    u = cross(s, f);

    mat = zeros(4, 4);
    mat(1, 1) = s(1);
    mat(2, 1) = s(2);
    mat(3, 1) = s(3);
    mat(1, 2) = u(1);
    mat(2, 2) = u(2);
    mat(3, 2) = u(3);
    mat(1, 3) = -f(1);
    mat(2, 3) = -f(2);
    mat(3, 3) = -f(3);
    mat(4, 1) = -dot(s, eye);
    mat(4, 2) = -dot(u, eye);
    mat(4, 3) = dot(f, eye);
    mat(4, 4) = 1;
endfunction
