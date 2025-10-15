========================================
            T Diagram
========================================

Lenguaje:
    D (Dlang)

Archivo principal:
    TDiagram.d

----------------------------------------
Compilación:
    dmd TDiagram.d

Ejecución:
    ./TDiagram

Ejecución con tests unitarios:
    dmd -unittest -cov TDiagram.d

----------------------------------------
Comandos disponibles (CLI):

    definir programa <nombre> <lenguaje>
        → Define un nuevo programa indicando el lenguaje en que está escrito.

    definir interprete <lenguaje_base> <lenguaje>
        → Indica que el lenguaje puede ejecutarse a través de un intérprete.

    definir traductor <lenguaje_base> <lenguaje_origen> <lenguaje_destino>
        → Indica que un lenguaje puede traducirse a otro usando un lenguaje base.

    ejecutable <nombre>
        → Verifica si un programa puede ejecutarse localmente.

    salir
        → Finaliza el programa.

----------------------------------------