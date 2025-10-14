import std.stdio;
import std.conv;
import std.array;
import std.string;

enum ResultCommand {
    OK = 0,          // Comando ejecutado sin errores
    ERROR = 1,       // Comando inválido o error de sintaxis
    END = 2        // Solicitud de salida
}

// Manejar diferentes estados
enum State { LIBRE, OCUPADO, DIVIDIDO }

// Estructura nodo para la implementación de un árbol
struct Node {
    size_t size;      
    State state;       
    string name;     
    Node* left;        
    Node* right;
    Node* parent;       
}

// Inicializador de un nodo
Node* crearBuddyTree(size_t size) {
    auto nodo = new Node;
    nodo.size = size;
    nodo.state = State.LIBRE;
    return nodo;
}

// Función que crea dos nodos hijos para un nodo que pretende ser dividido
void subdividir(Node* nodo) {
    if (nodo.size > 1) {
        nodo.state = State.DIVIDIDO;
        nodo.left = crearBuddyTree(nodo.size / 2);
        nodo.right = crearBuddyTree(nodo.size / 2);
        nodo.left.parent = nodo;
        nodo.right.parent = nodo;
    }
}

// Función para reservar un nodo de memoria
bool reservarNodo(Node* node, string name, size_t size){
    if(node is null) return false;

    if(node.size < size) return false;

    if(node.size == size && node.state == State.LIBRE){
        node.name = name;
        node.state = State.OCUPADO;
        return true;
    }

    if(node.size > size && node.state == State.LIBRE){
        subdividir(node);
        
        if(node.left is null || node.right is null) return false;

        bool reserveLeft = reservarNodo(node.left, name, size);
        if(reserveLeft) return true;

        return reservarNodo(node.right, name, size);
    }

    if (node.size > size && node.state == State.DIVIDIDO) {
        bool reserveLeft = reservarNodo(node.left, name, size);
        if (reserveLeft) return true;

        return reservarNodo(node.right, name, size);
    }

    return false;

}

void compactar(Node* parent) {
    if (parent is null) return;

    auto left = parent.left;
    auto right = parent.right;

    if (left.state == State.LIBRE && right.state == State.LIBRE) {
        // fusionar buddies
        parent.left = null;
        parent.right = null;
        parent.state = State.LIBRE;

        // y seguir subiendo
        compactar(parent.parent);
    }
}

void liberar(Node* node){
    node.state = State.LIBRE;
    node.name = "";

    compactar(node.parent);
}

// Función para liberar el espacio reservado en un nodo basado en el nombre
bool liberarNodo(Node* node, string name){
    if(node is null) return false;

    if(node.name == name && node.state == State.OCUPADO){
        liberar(node);
        return true;
    }

    bool freeLeft = liberarNodo(node.left, name);
    if (freeLeft) return true;
    
    return liberarNodo(node.right, name);

}

// Función para redondear un número a la potencia de dos superior más cercana
size_t proximaPotenciaDeDos(size_t n){
    if( n <= 1 ) return 1;
    size_t p = 1;
    while(p < n){
        p = p * 2;
    }
    return p;
}

// Función para redondear un número a la potencia de dos inferior más cercana
size_t anteriorPotenciaDeDos(size_t n){
    size_t power_iter = 2;
    size_t power_buddy;
    while(true){
        power_buddy = power_iter;
        power_iter = power_iter * 2;
        if(power_iter > n){
            break;
        }
    }
    return power_buddy;
}

void mostrarBuddyTree(Node* nodo, size_t nivel = 0){
    if (nodo is null) return;
    
    if(nodo.state != State.OCUPADO){
        writeln(" ".replicate(nivel * 2), "- Tamano: ", nodo.size, " | Estado: ", nodo.state);
    } else{
        writeln(" ".replicate(nivel * 2), "- Tamano: ", nodo.size, " | Estado: ", nodo.state, " | Nombre del espacio: ", nodo.name);
    }

    if (nodo.state == State.DIVIDIDO) {
        mostrarBuddyTree(nodo.left, nivel + 1);
        mostrarBuddyTree(nodo.right, nivel + 1);
    }
}


bool validarReservar(string[] entries_arr){
    if(entries_arr.length != 3) return false;
    try{    
        int blocks = to!size_t(entries_arr[1]);
    } catch(ConvException e){
        return false;
    }

    if(strip(entries_arr[2]) == ""){
        return false;
    }

    return true;
}

bool validarLiberar(string[] entries_arr){
    return entries_arr.length == 2;
}

bool validarMonoCommands(string[] entries_arr){
    return entries_arr.length == 1;
}


ResultCommand proccessInput(int option, Node* root, size_t parameter_blocks = 0, string parameter_name = ""){

    switch(option){
        case 1:

            // Redondeamos a la próxima potencia de dos
            parameter_blocks = proximaPotenciaDeDos(parameter_blocks);

            if(reservarNodo(root, parameter_name, parameter_blocks)){
                writeln("Memoria reservada con exito.");
                return ResultCommand.OK;
            } else {
                writeln("Error: No se pudo reservar la memoria.");
                return ResultCommand.ERROR;
            }

        case 2:

            if(liberarNodo(root, parameter_name)){
                writeln("Bloque de memoria liberado con exito.");
                return ResultCommand.OK;
            } else{
                writeln("No se consiguió el bloque de memoria");
                return ResultCommand.ERROR;
            }

        case 3:
            mostrarBuddyTree(root);
            break;
            
        case 4:
            writeln("Saliendo...");
            return ResultCommand.END;

        default: break; 

    }
    return ResultCommand.OK;
}


ResultCommand procesarComando(Node* root, string entry){

    entry = entry.strip();
    if(entry.length == 0) {
        writeln("No existe dicho comando");
        return ResultCommand.ERROR;
    }

    auto entries_arr = entry.split(" ");
    if(entries_arr.length > 3){
        writeln("No existe dicho comando");
        return ResultCommand.ERROR;
    }

    switch(toLower(entries_arr[0])){
        case "reservar":
            if(!validarReservar(entries_arr)) {
                writeln("Error: Sintaxis de 'RESERVAR' incorrecta, se esperan dos parámetros.");
                return ResultCommand.ERROR;
            }
            return proccessInput(1, root, to!size_t(entries_arr[1]), entries_arr[2]);

        case "liberar":
            if(!validarLiberar(entries_arr)) {
                writeln("Error: Sintaxis de 'LIBERAR' incorrecta, se espera un parámetro.");
                return ResultCommand.ERROR;
            }
            return proccessInput(2, root, parameter_name: entries_arr[1]);

        case "mostrar":
            if(!validarMonoCommands(entries_arr)) {
                writeln("Error: Sintaxis de 'MOSTRAR' incorrecta, no se esperan parámetros.");
                return ResultCommand.ERROR;
            }
            return proccessInput(3, root);

        case "salir":
            if(!validarMonoCommands(entries_arr)) {
                writeln("Error: Sintaxis de 'SALIR' incorrecta, no se esperan parámetros.");
                return ResultCommand.ERROR;
            }
            return proccessInput(4, root);

        default:
            writeln("Error: No existe dicho comando");
            return ResultCommand.ERROR;
    }
}

ResultCommand memory_validator(string[] args){

    if(args.length < 2 || args.length > 2){
        writeln("Error: Debe enviar la cantidad de bloques");
        return ResultCommand.END;
    }

    size_t memory_size;
    string memory_size_txt = args[1];

    try{
        memory_size = to!size_t(memory_size_txt);
    } catch(ConvException e){   
        writeln("Error: No envió un valor numérico");
        return ResultCommand.END;
    }

    return ResultCommand.OK;
}

void main(string[] args){

    ResultCommand validate = memory_validator(args);

    if(validate == ResultCommand.END) return;

    size_t memory_size = to!size_t(args[1]);

    // Se debe redondear a la potencia de dos más cercana por debajo al valor dado
    size_t power_buddy = anteriorPotenciaDeDos(memory_size); 
    writeln("La memoria disponible para el Buddy System es: ", power_buddy);

    Node* root = crearBuddyTree(power_buddy);

    // Flujo de programa real
    while(true){
        write("> ");
        string entry = readln();

        int exit = procesarComando(root, entry);

        if (exit == ResultCommand.END) break;
    }

}




unittest {

    // Si ejecutan el codigo con un valor de memoria invalido o con menos o más parámetros
    assert(memory_validator(["programa", "holaaa"]) == ResultCommand.END);
    assert(memory_validator(["programa"]) == ResultCommand.END);
    assert(memory_validator(["programa", "holaaa", "holaa"]) == ResultCommand.END);


    size_t test_memory_size = 1056;
    size_t test_power_buddy = anteriorPotenciaDeDos(test_memory_size);

    assert(test_power_buddy == 1024);

    Node* test_root = crearBuddyTree(test_power_buddy);

    // Reservar bloque de código con nombre sin espacio
    assert(procesarComando(test_root, "reservar 32 nombre_1") == ResultCommand.OK);
    // Reservar un bloque de igual tamaño, para que tome su buddie, pero con mismo nombre
    assert(procesarComando(test_root, "reservar 32 nombre_1") == ResultCommand.OK);
    

    // Liberar ambos bloques para cubrir la compactación
    assert(procesarComando(test_root, "liberar nombre_1") == ResultCommand.OK);
    assert(procesarComando(test_root, "liberar nombre_1") == ResultCommand.OK);

    // Liberar un bloque no existente
    assert(procesarComando(test_root, "liberar nombre_1") == ResultCommand.ERROR);

    // Mala sintaxis de comando liberar
    assert(procesarComando(test_root, "liberar nombre apellido") == ResultCommand.ERROR);

    // Reservar bloque de código con nombre con espacio
    assert(procesarComando(test_root, "reservar 32 nombre 1") == ResultCommand.ERROR);

    // Reservar un bloque más grande que la memoria del sistema
    assert(procesarComando(test_root, "reservar 2046 proceso_1") == ResultCommand.ERROR);

    // Mostrar el árbol vacío
    assert(procesarComando(test_root, "mostrar") == ResultCommand.OK);

    // Mostrar el árbol con un proceso
    assert(procesarComando(test_root, "reservar 502 proceso_1") == ResultCommand.OK);
    assert(procesarComando(test_root, "mostrar") == ResultCommand.OK);

    // Tratar de reservar sin buen formato
    assert(procesarComando(test_root, "reservar treinta proceso_1") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "reservar 25   ") == ResultCommand.ERROR);

    // No manda comando
    assert(procesarComando(test_root, "") == ResultCommand.ERROR);

    // Errar comando mostrar
    assert(procesarComando(test_root, "mostrar 23") == ResultCommand.ERROR);

    // Comando desconocido
    assert(procesarComando(test_root, "buscar 23") == ResultCommand.ERROR);

    // Sintaxis errada de salir
    assert(procesarComando(test_root, "salir 123") == ResultCommand.ERROR);

    // Salir del programa
    assert(procesarComando(test_root, "salir") == ResultCommand.END);
    

    writeln("¡Todos los tests pasaron correctamente!");
}
