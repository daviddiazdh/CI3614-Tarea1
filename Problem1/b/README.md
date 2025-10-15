===============================================================
        PROYECTO PRODUCTO TRANSVERSAL DE MATRIZ
===============================================================

Lenguaje:
    D (Dlang)

Archivo principal:
    TMatrixProduct.d

----------------------------------------
Compilación:
    dmd TMatrixProduct.d -unittest

Ejecución normal:
    ./TMatrixProduct

Ejecución con tests unitarios:
    dmd -unittest -cov TMatrixProduct.d

----------------------------------------
Descripción:
    Calcula el producto de una matriz por su transpuesta (A * Aᵗ),
    retornando una nueva matriz cuadrada resultado de la operación.

----------------------------------------
Flujo del programa:

    1. Pide al usuario la dimensión n de la matriz (n x n).
    2. Solicita los elementos de la matriz fila por fila.
    3. Valida que cada fila tenga exactamente n valores numéricos.
    4. Calcula el producto transpuesto con:
            C[i][j] = Σ (A[i][k] * A[j][k]) para k = 0..n-1
    5. Muestra la matriz resultante por pantalla.