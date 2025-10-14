import std.stdio;
import std.container;
import std.array;
import std.string;

enum ResultCommand { OK = 0, ERROR = 1, END = 2 }

class Nodo {
    string nombre;
    Arista[] aristas;
    this(string nombre) {
        this.nombre = nombre;
        this.aristas = [];
    }
}

class Arista {
    string tipo;
    Nodo destino;
    Nodo base;

    this(string tipo, Nodo destino, Nodo base = null) {
        this.tipo = tipo;
        this.destino = destino;
        this.base = base;
    }
}

Nodo[string] grafo;
string[string] programas; // nombrePrograma -> lenguaje (normalizado)

// helper: normaliza nombres de lenguajes (usar consistentemente)
string norm(string s) {
    return s.toUpper();
}

Nodo obtenerOCrearNodo(string nombre) {
    auto key = norm(nombre);
    if (!(key in grafo)) {
        grafo[key] = new Nodo(key);
    }
    return grafo[key];
}

void agregarInterprete(string lenguaje, string lenguajeBase) {
    auto keyLeng = norm(lenguaje);
    auto keyBase = norm(lenguajeBase);

    if (!(keyLeng in grafo)) definirLenguaje(lenguaje);
    
    if (!(keyBase in grafo)) definirLenguaje(lenguajeBase);

    auto nodoLenguaje = grafo[keyLeng];
    auto nodoBase = grafo[keyBase];

    nodoLenguaje.aristas ~= new Arista("INTERPRETE", nodoBase);
}

void agregarTraductor(string lenguajeOrigen, string lenguajeDestino, string lenguajeBase) {
    auto kOrig = norm(lenguajeOrigen);
    auto kDest = norm(lenguajeDestino);
    auto kBase = norm(lenguajeBase);

    if (!(kOrig in grafo)) definirLenguaje(lenguajeOrigen);

    if (!(kDest in grafo)) definirLenguaje(lenguajeDestino);

    if (!(kBase in grafo)) definirLenguaje(lenguajeBase);

    auto nodoOrigen = grafo[kOrig];
    auto nodoDestino = grafo[kDest];
    auto nodoBase = grafo[kBase];

    nodoOrigen.aristas ~= new Arista("TRADUCTOR", nodoDestino, nodoBase);
}

bool puedeEjecutar(Nodo nodo, bool[string]* visitados = null) {
    bool[string] local;
    if (visitados is null)
        visitados = &local;

    if ((*visitados).get(nodo.nombre, false))
        return false;
    (*visitados)[nodo.nombre] = true;

    if (nodo.nombre == norm("LOCAL"))
        return true;

    foreach (ref arista; nodo.aristas) {
        if (arista.tipo == "INTERPRETE") {
            if (puedeEjecutar(arista.destino, visitados))
                return true;
        } else if (arista.tipo == "TRADUCTOR") {
            // Copias separadas para no contaminar comprobaciones
            bool[string] copiaBase = (*visitados).dup;
            bool[string] copiaDestino = (*visitados).dup;
            if (puedeEjecutar(arista.base, &copiaBase) &&
                puedeEjecutar(arista.destino, &copiaDestino))
                return true;
        }
    }

    return false;
}

void definirLenguaje(string nombre) {
    // A esta función no le hace falta validar la existencia del lenguaje, porque quien llama ya sabe que el lenguaje no está.
    auto key = norm(nombre);
    grafo[key] = new Nodo(key);
}

bool definirPrograma(string nombre, string lenguaje) {
    if (nombre in programas) {
        writeln("Error: El programa ", nombre, " ya está definido.");
        return false;
    }

    // Normalizar lenguaje al guardarlo
    auto keyLang = norm(lenguaje);

    // Crear el lenguaje si no existe
    if (!(keyLang in grafo)) {
        definirLenguaje(keyLang);
    }

    programas[nombre] = keyLang;
    return true;
}

bool programaEjecutable(string nombre) {
    if (!(nombre in programas)) {
        writeln("Error: programa ", nombre, " no definido.");
        return false;
    }

    string lenguaje = programas[nombre]; // ya normalizado
    auto nodo = grafo[lenguaje];
    return puedeEjecutar(nodo);
}


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
    // definimos LOCAL normalizado
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

    

    // Definir un inteprete antes de la existencia del lenguaje java
    assert(procesarLinea("definir interprete local java") == ResultCommand.OK);

    // Definir y ejecutar un programa en C
    assert(procesarLinea("definir programa c1 c") == ResultCommand.OK);
    assert(procesarLinea("ejecutable c1") == ResultCommand.ERROR);

    // Definir un traductor para C en java hacia java
    assert(procesarLinea("definir traductor java c java") == ResultCommand.OK);

    // Ya que hay un traductor para c, entonces definir un programa en c y ejecutarlo
    assert(procesarLinea("ejecutable c1") == ResultCommand.OK);

    // Definir otro programa en python, pero con mayusculas
    assert(procesarLinea("definir PROGRAMA p1 python") == ResultCommand.OK);
    // Verificar que reconozca el mismo Python
    assert(procesarLinea("definir interprete local PYTHON") == ResultCommand.OK);
    // Debe ejecutar
    assert(procesarLinea("ejecutable p1") == ResultCommand.OK);

    // Tratar de definir un programa con el mismo nombre de uno ya creado
    assert(procesarLinea("definir PROGRAMA p1 C#") == ResultCommand.ERROR);

    // Ejecutar programa inexistente
    assert(procesarLinea("ejecutable j1") == ResultCommand.ERROR);

    // No enviar ningun comando (No se cuenta como error)
    assert(procesarLinea("") == ResultCommand.OK);
    assert(procesarLinea("         ") == ResultCommand.OK);

    // Mala sintaxis en definir
    assert(procesarLinea("definir") == ResultCommand.ERROR);
    assert(procesarLinea("definir programa hola") == ResultCommand.ERROR);
    assert(procesarLinea("definir traductor hola python") == ResultCommand.ERROR);
    assert(procesarLinea("definir al_arco") == ResultCommand.ERROR);

    // Mala sintaxis en ejecutable
    assert(procesarLinea("ejecutable") == ResultCommand.ERROR);
    assert(procesarLinea("ejecutable hola.py gol") == ResultCommand.ERROR);

    // Comando inexistente
    assert(procesarLinea("comando_que_no_existe") == ResultCommand.ERROR);

    // Salida
    assert(procesarLinea("salir") == ResultCommand.END);
    

    writeln("¡Todos los tests pasaron correctamente!");
}