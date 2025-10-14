import std.stdio;
import std.conv;

unittest {

    //Pruebas unitarias
    assert(rotate_text("hola", 0) == "hola");
    assert(rotate_text("hola", 1) == "olah");
    assert(rotate_text("hola", 2) == "laho");
    assert(rotate_text("hola", 3) == "ahol");
    assert(rotate_text("hola", 4) == "hola");
    assert(rotate_text("hola", 5) == "olah");
    
    //Casos bordes
    assert(rotate_text("", 2) == "");
    assert(main_function(["", "hola", "8"]) == "El texto rotado es: hola");
    assert(main_function(["", "hola"]) == "Error: Debe enviar dos argumentos");
    assert(main_function(["", "hola", "hola"]) == "Error: El segundo argumento debe ser un número.");

    writeln("¡Todos los tests pasaron correctamente!");
}

string rotate_text(string text, int n){  
    if(n==0 || text.length == 0){
        return text;
    }
    text = rotate_text(text[1 .. $] ~ text[0], n - 1);
    return text;
}

string main_function(string[] args){
    string text;
    int number;

    if(args.length < 3 || args.length > 3){
        return("Error: Debe enviar dos argumentos");
    }

    try{
        text = args[1];
        number = to!int(args[2]);
        string rotated_text = rotate_text(text, number);
        return "El texto rotado es: " ~ rotated_text;

    } catch (ConvException e){
        return "Error: El segundo argumento debe ser un número.";
    }
}

void main(string[] args){

    writeln(main_function(args));

}