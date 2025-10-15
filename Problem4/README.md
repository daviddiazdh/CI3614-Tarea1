========================================
            Vector3D
========================================

Lenguaje:
    C++

Archivos:
    Vector3D.h
    Vector3D.cpp
    main.cpp   (archivo principal de prueba)

----------------------------------------
Compilación:
    g++ main.cpp Vector3D.cpp -o vector3d -std=c++17

Ejecución:
    ./Vector3d

----------------------------------------
Operadores implementados:

    +   → Suma de vectores:          v1 + v2
    -   → Resta de vectores:         v1 - v2
    *   → Producto cruzado:          v1 * v2
    %   → Producto punto:            v1 % v2
    &   → Magnitud (norma):          &v1
    +k  → Suma con escalar:          v1 + 3.5
    *k  → Multiplicación escalar:    v1 * 2.0
    <<  → Impresión del vector:      std::cout << v1