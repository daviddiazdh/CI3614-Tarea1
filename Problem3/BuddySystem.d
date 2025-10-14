import std.stdio;
import std.conv;
import std.array;
import std.string;

// Enum para representar los resultados de comandos
enum ResultCommand {
    OK = 0,          // Comando ejecutado sin errores
    ERROR = 1,       // Comando inválido o error de sintaxis
    END = 2          // Solicitud de salida del programa
}

// Estados posibles de un bloque en el Buddy System
enum State { LIBRE, OCUPADO, DIVIDIDO }

// Estructura que representa cada nodo (bloque de memoria)
struct Node {
    size_t size;       // Tamaño del bloque
    State state;       // Estado del bloque
    string name;       // Nombre del proceso o reserva
    Node* left;        // Hijo izquierdo
    Node* right;       // Hijo derecho
    Node* parent;      // Referencia al nodo padre
}

// Crea la raíz del árbol del buddy system
Node* crearBuddyTree(size_t size) {
    auto nodo = new Node;
    nodo.size = size;
    nodo.state = State.LIBRE;
    return nodo;
}

// Divide un nodo en dos nodos hijos (buddies)
void subdividir(Node* nodo) {
    if (nodo.size > 1) {
        nodo.state = State.DIVIDIDO;
        nodo.left = crearBuddyTree(nodo.size / 2);
        nodo.right = crearBuddyTree(nodo.size / 2);
        nodo.left.parent = nodo;
        nodo.right.parent = nodo;
    }
}

// Reserva un bloque de memoria del tamaño solicitado
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

// Intenta compactar los buddies si ambos están libres
void compactar(Node* parent) {
    if (parent is null) return;

    auto left = parent.left;
    auto right = parent.right;

    if (left.state == State.LIBRE && right.state == State.LIBRE) {
        // fusionar buddies
        parent.left = null;
        parent.right = null;
        parent.state = State.LIBRE;

        // seguir subiendo en el árbol
        compactar(parent.parent);
    }
}

// Libera un nodo específico
void liberar(Node* node){
    node.state = State.LIBRE;
    node.name = "";

    compactar(node.parent);
}

// Libera un bloque buscando por nombre
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

// Calcula la potencia de dos superior más cercana a n
size_t proximaPotenciaDeDos(size_t n){
    if( n <= 1 ) return 1;
    size_t p = 1;
    while(p < n){
        p = p * 2;
    }
    return p;
}

// Calcula la potencia de dos inferior más cercana a n
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

// Muestra visualmente el árbol del buddy system
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

// Validación de sintaxis para comando "reservar"
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

// Validación de sintaxis para comando "liberar"
bool validarLiberar(string[] entries_arr){
    return entries_arr.length == 2;
}

// Validación para comandos sin parámetros (mostrar, salir)
bool validarMonoCommands(string[] entries_arr){
    return entries_arr.length == 1;
}

// Procesa la ejecución de un comando según su tipo
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

// Analiza y valida la entrada del usuario (CLI)
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

// Valida los argumentos de inicio del programa
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

// Función principal
void main(string[] args){

    ResultCommand validate = memory_validator(args);

    if(validate == ResultCommand.END) return;

    size_t memory_size = to!size_t(args[1]);

    // Redondeamos a la potencia de dos inferior más cercana
    size_t power_buddy = anteriorPotenciaDeDos(memory_size); 
    writeln("La memoria disponible para el Buddy System es: ", power_buddy);

    Node* root = crearBuddyTree(power_buddy);

    // Ciclo principal de comandos
    while(true){
        write("> ");
        string entry = readln();

        int exit = procesarComando(root, entry);

        if (exit == ResultCommand.END) break;
    }
}

// --------------------- PRUEBAS UNITARIAS ---------------------

unittest {
    // Validación de entrada de memoria incorrecta
    assert(memory_validator(["programa", "holaaa"]) == ResultCommand.END);
    assert(memory_validator(["programa"]) == ResultCommand.END);
    assert(memory_validator(["programa", "holaaa", "holaa"]) == ResultCommand.END);

    size_t test_memory_size = 1056;
    size_t test_power_buddy = anteriorPotenciaDeDos(test_memory_size);
    assert(test_power_buddy == 1024);

    Node* test_root = crearBuddyTree(test_power_buddy);

    // Reservar y liberar
    assert(procesarComando(test_root, "reservar 32 nombre_1") == ResultCommand.OK);
    assert(procesarComando(test_root, "reservar 32 nombre_1") == ResultCommand.OK);
    assert(procesarComando(test_root, "liberar nombre_1") == ResultCommand.OK);
    assert(procesarComando(test_root, "liberar nombre_1") == ResultCommand.OK);
    assert(procesarComando(test_root, "liberar nombre_1") == ResultCommand.ERROR);

    // Casos con errores de sintaxis
    assert(procesarComando(test_root, "liberar nombre apellido") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "reservar 32 nombre 1") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "reservar 2046 proceso_1") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "reservar treinta proceso_1") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "reservar 25   ") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "mostrar 23") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "buscar 23") == ResultCommand.ERROR);
    assert(procesarComando(test_root, "salir 123") == ResultCommand.ERROR);

    // Mostrar árbol y salir
    assert(procesarComando(test_root, "mostrar") == ResultCommand.OK);
    assert(procesarComando(test_root, "reservar 502 proceso_1") == ResultCommand.OK);
    assert(procesarComando(test_root, "mostrar") == ResultCommand.OK);
    assert(procesarComando(test_root, "salir") == ResultCommand.END);

    // Subdivisión al reservar menos de la mitad
    Node* t = crearBuddyTree(64);
    assert(reservarNodo(t, "A", 8) == true);
    assert(t.state == State.DIVIDIDO);

    // Redondeo exacto
    assert(proximaPotenciaDeDos(128) == 128);

    writeln("¡Todos los tests pasaron correctamente!");
}
