1. 什么是多重继承的二义性

class A{
public:
    void f();
}
 
class B{
public:
    void f();
    void g();
}
 
class C:public A,public B{
public:
    void g();
    void h();
};
 如果声明：C c1，则c1.f();具有二义性，而c1.g();无二义性（同名覆盖)。

2. 解决办法一 -- 类名限定

调用时指名调用的是哪个类的函数，如

c1.A::f();
c1.B::f();
3. 解决办法二 -- 同名覆盖

在C中声明一个同名函数，该函数根据需要内部调用A的f或者是B的f。如

class C:public A,public B{
public:
    void g();
    void h();
    void f(){
        A::f();
    }
};
 4. 解决办法三 -- 虚基类（用于有共同基类的场合）
virtual 修饰说明基类，如：

1
class B1:virtual public B
虚基类主要用来解决多继承时，可能对同一基类继承继承多次从而产生的二义性。为最远的派生类提供唯一的基类成员，而不重复产生多次拷贝。注意：需要在第一次继承时就要将共同的基类设计为虚基类。虚基类及其派生类构造函数建立对象时所指定的类称为最（远）派生类。

虚基类的成员是由派生类的构造函数通过调用虚基类的构造函数进行初始化的。
在整个继承结构中，直接或间接继承虚基类的所有派生类，都必须在构造函数的成员初始化表中给出对虚基类的构造函数的调用。如果未列出，则表示调用该虚基类的缺省构造函数。
在建立对象时，只有最派生类的构造函数调用虚基类的构造函数，该派生类的其他基类对虚基类的构造函数的调用被忽略。


class B{
    public:
    int b;
}
 
class B1:virtual public B{
    priavte:
    int b1;
}
 
class B2:virutual public B{
    private:
    int b2;
}
 
class C:public B1,public B1{
    private:
    float d;
}
 
C obj;
obj.b;//正确的
 如果B1和B2不采用虚继续，则编译出错，提示“request for member 'b' is ambiguous”。这是因为，不指名virtual的继承，子类将父类的成员都复制到自己的空间中，所以，C中会有两个b。



#include<iostream>
using namespace std;
 
class B0{
public:
    B0(int n)    {
        nv=n;
        cout<<"i am B0,my num is"<<nv<<endl;
    }
    void fun()    {
        cout<<"Member of Bo"<<endl;
    }
private:
    int nv;
};
 
class B1:virtual public B0{
public:
    B1(int x,int y):B0(y){
       nv1=x;
       cout<<"i am  B1,my num is "<<nv1<<endl;
    }
private:
    int nv1;
};
 
class B2:virtual public B0{
public:
    B2(int x,int y):B0(y){
        nv2=x;
        cout<<"i am B2,my num is "<<nv2<<endl;
    }
private:
    int nv2;
};
 
class D:public B1,public B2{
public:
    D(int x,int y,int z,int k):B0(x),B1(y,y),B2(z,y){
       nvd=k;
       cout<<"i am D,my num is "<<nvd<<endl;
    }
private:
    int nvd;
};
 
int main(){
    D d(1,2,3,4);
    d.fun();
    return 0;
}
 d.fun()的结果是：

i am B0,my num is 1
i am B1,my num is 2
i am B2,my num is 3
i am D,my num is 4
Member of Bo
 