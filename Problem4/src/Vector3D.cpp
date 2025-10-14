#include "Vector3D.h"
#include <cmath>

Vector3D::Vector3D(double x, double y, double z) : x(x), y(y), z(z){}

Vector3D Vector3D::operator+(const Vector3D& otro) const{
    return Vector3D(x + otro.x, y + otro.y, z + otro.z);
}

Vector3D Vector3D::operator-(const Vector3D& otro) const{
    return Vector3D(x - otro.x, y - otro.y, z - otro.z);
}

Vector3D Vector3D::operator*(const Vector3D& otro) const{
    return Vector3D(y*otro.z - z*otro.y, z*otro.x - x*otro.z, x*otro.y - y*otro.x);
}

int Vector3D::operator%(const Vector3D& otro) const{
    return x * otro.x + y * otro.y + z * otro.z;
}

double Vector3D::operator&() const {
    return std::sqrt(x*x + y*y + z*z);
}

Vector3D Vector3D::operator+(double escalar) const {
    return Vector3D(x + escalar, y + escalar, z + escalar);
}

Vector3D Vector3D::operator*(double escalar) const {
    return Vector3D(x * escalar, y * escalar, z * escalar);
}

std::ostream& operator<<(std::ostream& os, const Vector3D& v) { 
    os << "(" << v.x << ", " << v.y << ", " << v.z << ")"; return os; 
}