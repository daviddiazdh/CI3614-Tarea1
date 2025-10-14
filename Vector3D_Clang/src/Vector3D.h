#pragma once

#ifndef VECTOR3D_H
#define VECTOR3D_H

#include <iostream>

class Vector3D {
public:
    double x, y, z;

    Vector3D(double x = 0, double y = 0, double z = 0);
    
    Vector3D operator+(const Vector3D& otro) const;
    Vector3D operator-(const Vector3D& otro) const;
    Vector3D operator*(const Vector3D& otro) const; 
    int operator%(const Vector3D& otro) const;       
    double operator&() const;                        

    Vector3D operator+(double escalar) const;
    Vector3D operator*(double escalar) const;

    friend std::ostream& operator<<(std::ostream& os, const Vector3D& v);
};

#endif