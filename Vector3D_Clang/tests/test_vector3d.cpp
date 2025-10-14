#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#include "../src/Vector3D.h"

TEST_CASE("Suma de vectores") {
    Vector3D a(1,2,3);
    Vector3D b(4,5,6);
    Vector3D c = a + b;
    REQUIRE(c.x == 5);
    REQUIRE(c.y == 7);
    REQUIRE(c.z == 9);
}

TEST_CASE("Resta de vectores") {
    Vector3D a(1,2,3);
    Vector3D b(4,5,6);
    Vector3D c = a - b;
    REQUIRE(c.x == -3);
    REQUIRE(c.y == -3);
    REQUIRE(c.z == -3);
}

TEST_CASE("Producto cruz de vectores") {
    Vector3D a(1,2,3);
    Vector3D b(4,5,6);
    Vector3D c = a * b;
    REQUIRE(c.x == -3);
    REQUIRE(c.y == 6);
    REQUIRE(c.z == -3);
}

TEST_CASE("Producto punto de vectores") {
    Vector3D a(1,2,3);
    Vector3D b(4,5,6);
    int c = a % b;
    REQUIRE(c == 32);
}

TEST_CASE("Norma de vectores") {
    Vector3D a(1,0,0);
    double c = &a;
    REQUIRE(c == 1);

    Vector3D b(4,3,0);
    c = &b;
    REQUIRE(c == 5);
}

TEST_CASE("Suma con escalares") {
    Vector3D a(1,2,3);
    double c = 2;
    Vector3D b = a + c;
    REQUIRE(b.x == 3);
    REQUIRE(b.y == 4);
    REQUIRE(b.z == 5);
}

TEST_CASE("Producto con escalares") {
    Vector3D a(1,2,3);
    double c = 2;
    Vector3D b = a * c;
    REQUIRE(b.x == 2);
    REQUIRE(b.y == 4);
    REQUIRE(b.z == 6);
}

TEST_CASE("Impresion de vectores") {
    Vector3D a(1, 2, 3);
    std::stringstream ss;
    ss << a;
    REQUIRE(ss.str() == "(1, 2, 3)");
}