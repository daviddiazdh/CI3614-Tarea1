import std.stdio;
import std.container;
import std.array;
import std.string;

// Resultado estándar de comandos
enum ResultCommand { OK = 0, ERROR = 1, END = 2 }

// Nodo del grafo (representa un lenguaje)
class Nodo {
    string nombre;
    Arista[] aristas;

    this(string nombre) {
        this.nombre = nombre;
        this.aristas = [];
    }
}

// Representa una arista entre lenguajes (INTERPRETE o TRADUCTOR)
class Arista {
    string tipo;
    Nodo destino;
    Nodo base; // en caso de traductor, se usa lenguaje base

    this(string tipo, Nodo destino, Nodo base = null) {
        this.tipo = tipo;
        this.destino = destino;
        this.base = base;
    }
}

// Diccionarios globales para almacenar los lenguajes y programas
Nodo[string] grafo;       
string[string] programas;

// Normaliza nombres de lenguajes (mayúsculas)
string norm(string s) {
    return s.toUpper();
}

// Crea un nodo si no existe, y lo devuelve
Nodo obtenerOCrearNodo(string nombre) {
    auto key = norm(nombre);
    if (!(key in grafo)) {
        grafo[key] = new Nodo(key);
    }
    return grafo[key];
}

// Agrega una relación de intérprete entre lenguajes
void agregarInterprete(string lenguaje, string lenguajeBase) {
    auto keyLeng = norm(lenguaje);
    auto keyBase = norm(lenguajeBase);

    // Crear los lenguajes si no existen
    if (!(keyLeng in grafo)) definirLenguaje(lenguaje);
    if (!(keyBase in grafo)) definirLenguaje(lenguajeBase);

    auto nodoLenguaje = grafo[keyLeng];
    auto nodoBase = grafo[keyBase];

    nodoLenguaje.aristas ~= new Arista("INTERPRETE", nodoBase);
}

// Agrega una relación de traductor entre lenguajes
void agregarTraductor(string lenguajeOrigen, string lenguajeDestino, string lenguajeBase) {
    auto kOrig = norm(lenguajeOrigen);
    auto kDest = norm(lenguajeDestino);
    auto kBase = norm(lenguajeBase);

    // Crear los lenguajes si no existen
    if (!(kOrig in grafo)) definirLenguaje(lenguajeOrigen);
    if (!(kDest in grafo)) definirLenguaje(lenguajeDestino);
    if (!(kBase in grafo)) definirLenguaje(lenguajeBase);

    auto nodoOrigen = grafo[kOrig];
    auto nodoDestino = grafo[kDest];
    auto nodoBase = grafo[kBase];

    nodoOrigen.aristas ~= new Arista("TRADUCTOR", nodoDestino, nodoBase);
}

// Determina si un lenguaje puede ejecutarse localmente
bool puedeEjecutar(Nodo nodo, bool[string]* visitados = null) {
    bool[string] local;
    if (visitados is null)
        visitados = &local;

    // Si ya se visitó el nodo, evitar ciclos
    if ((*visitados).get(nodo.nombre, false))
        return false;
    (*visitados)[nodo.nombre] = true;

    // Caso base: si es el lenguaje LOCAL
    if (nodo.nombre == norm("LOCAL"))
        return true;

    // Revisar aristas salientes
    foreach (ref arista; nodo.aristas) {
        if (arista.tipo == "INTERPRETE") {
            
            if (puedeEjecutar(arista.destino, visitados))
                return true;
        } else if (arista.tipo == "TRADUCTOR") {
            
            bool[string] copiaBase = (*visitados).dup;
            bool[string] copiaDestino = (*visitados).dup;
            if (puedeEjecutar(arista.base, &copiaBase) &&
                puedeEjecutar(arista.destino, &copiaDestino))
                return true;
        }
    }

    return false;
}

// Crea un nuevo lenguaje en el grafo
void definirLenguaje(string nombre) {
    auto key = norm(nombre);
    grafo[key] = new Nodo(key);
}

// Define un nuevo programa con su lenguaje asociado
bool definirPrograma(string nombre, string lenguaje) {
    if (nombre in programas) {
        writeln("Error: El programa ", nombre, " ya está definido.");
        return false;
    }

    auto keyLang = norm(lenguaje);

    // Crear el lenguaje si no existe
    if (!(keyLang in grafo)) {
        definirLenguaje(keyLang);
    }

    programas[nombre] = keyLang;
    return true;
}

// Comprueba si un programa puede ejecutarse localmente
bool programaEjecutable(string nombre) {
    if (!(nombre in programas)) {
        writeln("Error: programa ", nombre, " no definido.");
        return false;
    }

    string lenguaje = programas[nombre];
    auto nodo = grafo[lenguaje];
    return puedeEjecutar(nodo);
}

// Procesa los comandos del usuario
ResultCommand procesarLinea(string linea){
    linea = linea.strip();
    if (linea.length == 0)
        return ResultCommand.OK;

    auto partes = linea.split();
    if (partes.length == 0)
        return ResultCommand.OK;

    string comando = partes[0].toUpper();

    if (comando == "SALIR") {
        writeln("Saliendo...");
        return ResultCommand.END;
    }
    
    else if (comando == "DEFINIR") {
        if (partes.length < 2) {
            writeln("Uso: DEFINIR <tipo> [args]");
            return ResultCommand.ERROR;
        }

        string tipo = partes[1].toUpper();

        switch (tipo) {
            case "PROGRAMA":
                if (partes.length != 4) {
                    writeln("Uso: DEFINIR PROGRAMA <nombre> <lenguaje>");
                    return ResultCommand.ERROR;
                }
                return definirPrograma(partes[2], partes[3]) ?  ResultCommand.OK : ResultCommand.ERROR;

            case "INTERPRETE":
                if (partes.length != 4) {
                    writeln("Uso: DEFINIR INTERPRETE <lenguaje_base> <lenguaje>");
                    return ResultCommand.ERROR;
                }
                string base = partes[2];
                string lenguaje = partes[3];
                obtenerOCrearNodo(base);
                obtenerOCrearNodo(lenguaje);
                agregarInterprete(lenguaje, base);
                return ResultCommand.OK;

            case "TRADUCTOR":
                if (partes.length != 5) {
                    writeln("Uso: DEFINIR TRADUCTOR <lenguaje_base> <lenguaje_origen> <lenguaje_destino>");
                    return ResultCommand.ERROR;
                }
                string baseT = partes[2];
                string origen = partes[3];
                string destino = partes[4];
                obtenerOCrearNodo(baseT);
                obtenerOCrearNodo(origen);
                obtenerOCrearNodo(destino);
                agregarTraductor(origen, destino, baseT);
                return ResultCommand.OK;

            default:
                writeln("Tipo desconocido: ", tipo);
                return ResultCommand.ERROR;
        }
    }
    
    else if (comando == "EJECUTABLE") {
        if (partes.length != 2) {
            writeln("Uso: EJECUTABLE <nombre>");
            return ResultCommand.ERROR;
        }

        string nombre = partes[1];
        bool resultado = programaEjecutable(nombre);
        if(resultado){
            writeln("El programa ", nombre, " se ejecuto correctamente");
        } else {
            writeln("Error: El programa ", nombre, " no se pudo ejecutar correctamente");
            return ResultCommand.ERROR;
        }
        return ResultCommand.OK;
    }
    else {
        writeln("Comando desconocido: ", comando);
        return ResultCommand.ERROR;
    }
}

void main() {
    // Se define el lenguaje LOCAL desde el inicio
    definirLenguaje("LOCAL");

    string linea;
    while (true) {
        write("> ");
        linea = chomp(readln());

        ResultCommand result = procesarLinea(linea);
        if (result == ResultCommand.END) break;
    }
}

unittest {
    // Intérprete antes de la existencia de su lenguaje
    assert(procesarLinea("definir interprete local java") == ResultCommand.OK);

    // Programa en C sin ruta a LOCAL
    assert(procesarLinea("definir programa c1 c") == ResultCommand.OK);
    assert(procesarLinea("ejecutable c1") == ResultCommand.ERROR);

    // Traductor de C en base a JAVA hacia JAVA (permite ejecutar C)
    assert(procesarLinea("definir traductor java c java") == ResultCommand.OK);
    assert(procesarLinea("ejecutable c1") == ResultCommand.OK);

    // Programa en Python
    assert(procesarLinea("definir PROGRAMA p1 python") == ResultCommand.OK);
    assert(procesarLinea("definir interprete local PYTHON") == ResultCommand.OK);
    assert(procesarLinea("ejecutable p1") == ResultCommand.OK);

    // Programa duplicado
    assert(procesarLinea("definir PROGRAMA p1 C#") == ResultCommand.ERROR);

    // Programa inexistente
    assert(procesarLinea("ejecutable j1") == ResultCommand.ERROR);

    // Comandos vacíos o con espacios
    assert(procesarLinea("") == ResultCommand.OK);
    assert(procesarLinea("         ") == ResultCommand.OK);

    // Sintaxis inválida
    assert(procesarLinea("definir") == ResultCommand.ERROR);
    assert(procesarLinea("definir programa hola") == ResultCommand.ERROR);
    assert(procesarLinea("definir traductor hola python") == ResultCommand.ERROR);
    assert(procesarLinea("definir al_arco") == ResultCommand.ERROR);
    assert(procesarLinea("ejecutable") == ResultCommand.ERROR);
    assert(procesarLinea("ejecutable hola.py gol") == ResultCommand.ERROR);
    assert(procesarLinea("comando_que_no_existe") == ResultCommand.ERROR);

    // Cadena de traductores (c → d → local)
    assert(procesarLinea("definir traductor local d local") == ResultCommand.OK);
    assert(procesarLinea("definir traductor local c d") == ResultCommand.OK);
    assert(procesarLinea("definir programa chain_prog c") == ResultCommand.OK);
    assert(procesarLinea("ejecutable chain_prog") == ResultCommand.OK);

    // Programa en lenguaje aislado sin intérprete ni traductor
    assert(procesarLinea("definir programa solitario brainfuck") == ResultCommand.OK);
    assert(procesarLinea("ejecutable solitario") == ResultCommand.ERROR);

    // Definir un programa que esté en local de una vez
    assert(procesarLinea("definir programa compilable local") == ResultCommand.OK);
    assert(procesarLinea("ejecutable compilable") == ResultCommand.OK);

    // Salida
    assert(procesarLinea("salir") == ResultCommand.END);

    writeln("¡Todos los tests pasaron correctamente!");
}