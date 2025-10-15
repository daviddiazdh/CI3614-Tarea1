========================================
        PROYECTO BUDDY SYSTEM
========================================

Lenguaje:
    D (Dlang)

Archivo principal:
    BuddySystem.d

----------------------------------------
Compilación:
    dmd BuddySystem.d

Ejecución:
    ./BuddySystem <cantidad_bloques>

Ejemplo:
    ./BuddySystem 64

Ejecución con tests unitarios:
    dmd -unittest -cov BuddySystem.d

----------------------------------------
Comandos disponibles (CLI):

    reservar <tamaño> <nombre>
        → Reserva un bloque de memoria.

    liberar <nombre>
        → Libera un bloque previamente reservado.

    mostrar
        → Muestra el árbol del Buddy System.

    salir
        → Finaliza el programa.