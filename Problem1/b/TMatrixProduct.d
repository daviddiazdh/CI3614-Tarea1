import std.stdio;
import std.conv;
import std.algorithm;
import core.stdc.stdlib : exit;
import std.string;
import std.array;

alias Matrix = double[][];

Matrix matrix_transpose_product(Matrix matrix){
    Matrix matrix_product;
    int N = matrix.length;
    
    // Crear la matriz inicializada con 0's
    matrix_product.length = N;
    foreach(i; 0..N){
        matrix_product[i].length = N;
    }

    // Iterador filas
    for (int i = 0; i < N; i++){
        // Iterador filas nuevamente
        for(int j = 0; j < N; j++){
            double sum = 0;
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

    int n;
    writeln("Introduce la dimensión n de la matriz (n x n): ");
    
    try{
        n = to!int(readln().strip());
    } catch(ConvException){
        writeln("Error: Debe enviar un valor numérico.");
        return;
    }

    double[][] matrix;
    matrix.length = n;

    writeln("Introduce los elementos de la matriz fila por fila:");
    foreach (i; 0 .. n) {
        auto line = readln().strip.split();
        try{
            matrix[i] = line.map!(to!double).array;
        } catch(ConvException e){
            writeln("Error: Debe enviar solo valores numéricos");
            return;
        }
        
        if (matrix[i].length != n) {
            writeln("Error: la fila debe tener exactamente ", n, " valores.");
            return;
        }
    }

    // Se debe colocar la matriz aquí
    Matrix matrix_product = matrix_transpose_product(matrix);
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

    writeln("¡Todos los tests pasaron correctamente!");
}