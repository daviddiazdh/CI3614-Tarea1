import std.stdio;
import std.conv;
import std.algorithm : all;
import core.stdc.stdlib : exit;

alias Matrix = int[][];

Matrix matrix_transpose_product(Matrix matrix){
    Matrix matrix_product;
    int N = matrix.length;

    // Verificar que la matriz es cuadrada
    bool matrix_nxn_verification = matrix.all!(x => x.length == N);
    if(!matrix_nxn_verification){
        writeln("Error: La matriz no es cuadrada.");
        exit(1);
    }

    // Crear la matriz inicializada con 0's
    matrix_product.length = N;
    foreach(i; 0..N){
        matrix_product[i].length = N;
    }

    // Iterador filas
    for (int i = 0; i < N; i++){
        // Iterador filas nuevamente
        for(int j = 0; j < N; j++){
            int sum = 0;
            // Iterador de productos
            for(int k = 0; k < N; k++){
                sum = sum + matrix[i][k] * matrix[j][k];
            }
            matrix_product[i][j] = sum;
        }
    }
    return(matrix_product);
}

void main(){

    Matrix matrix_product = matrix_transpose_product([[1, 2, 4],[1, 3, 5], [1, 2, 3]]);
    writeln(matrix_product);
    exit(0);
    
}   

unittest {

    Matrix m1 = [[1, 2, 4],
                 [1, 3, 5],
                 [1, 2, 3]];
    Matrix expected1 = [[21, 27, 17],
                        [27, 35, 22],
                        [17, 22, 14]];
    assert(matrix_transpose_product(m1) == expected1);

    Matrix m2 = [[1, 0],
                 [0, 1]];
    Matrix expected2 = [[1, 0],
                        [0, 1]];
    assert(matrix_transpose_product(m2) == expected2);

    Matrix m3 = [[2, 2],
                 [2, 2]];
    Matrix expected3 = [[8, 8],
                        [8, 8]];
    assert(matrix_transpose_product(m3) == expected3);

    Matrix m4 = [[1]];
    Matrix expected4 = [[1]];
    assert(matrix_transpose_product(m4) == expected4);

    // Matriz vacía
    Matrix m5 = [];
    assert(matrix_transpose_product(m5).length == 0);

    // Matriz no cuadrada (debería terminar con exit)
    // Nota: no se puede probar directamente con assert porque la función llama a exit(1)
    // Matrix m6 = [[1, 2, 3], [4, 5, 6]];
    // matrix_transpose_product(m6);

    writeln("¡Todos los tests pasaron correctamente!");
}