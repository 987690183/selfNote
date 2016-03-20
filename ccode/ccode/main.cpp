//
//  main.cpp
//  cHello
//
//  Created by 黄霖 on 16/3/6.
//  Copyright © 2016年 huanglin. All rights reserved.
//

#include <iostream>
#include "cstdlib"
#include "cstring"
#include "stdio.h"
using namespace std;


/*
 虚函数简单说明
 */

/*
 class hxl
 {
 public:
 virtual void tom() {
 printf("hello\n");
 };
 };
 
 class hxl2 : public hxl
 {
 public:
 virtual void tom(){
 printf("helloworld!\n");
 }
 };
 
 int main(){
 hxl *a = NULL;
 hxl2 b;
 a = &b;
 a->tom();//这里实现了多态的概念，a指向子类对象，调用的就是子类对象的对应tom方法
 return 0;
 }
 */



/*纯虚函数*/

class hxl
{
public:
    virtual void tom() = 0;
    
};

class hxl2: public hxl
{
public:
    virtual void tom(){
        printf("hxl7777\n");
    }
    void hehe(){
        printf("lalalalala");
    }
};

struct Teacher{
    char a[10];
    int b;
};


//const Teacher * p  和 Teacher const * p 是一样的，都是修饰指向p的内存地址的值，不能被修改
//Teacher * const p 代表的就是修饰指针了，此时p的指向就不能被修改了
int test(const Teacher * p, Teacher * const q)
{
    Teacher t = {"dfsdfs", 2};
    p = &t;
    
    //    p->b = 666; //错误，不允许被修改它指向的内存地址里的值
    
    q->b = 666;   //正确
    //    q = 0x11; // 错误，此时不允许修改指向的指向的值，
    
    return 0;
}

//这个就有点吊了，指针是常量，指针指向的内存地址的值也不允许被修改
void test2(const Teacher * const p){
    //    p->b = 666;
    //    p = 0x11;
}

int main2(){
    
    
    int a = 10;
    int b = 20;
    (a < b ? a: b) = 30;
    
    printf("%d %d\n", a, b);
    return 0;
}



// --------------------分割线----------------------
//二义性： 1.同名二义性 2.路径二义性
/*
 1.在继承时，基类之间、或基类与派生类之间发生成员同名时，将出现对成员访问的不确定性——同名二义性。
 2.当派生类从多个基类派生，而这些基类又从同一个基类派生，则在访问此共同基类中的成员时，将产生另一种不确定性——路径二义性。
 
 同名二义性
 同名隐藏规则——解决同名二义的方法
 当派生类与基类有同名成员时,派生类中的成员将屏蔽基类中的同名成员。
 若未特别指明，则通过派生类对象使用的都是派生类中的同名成员;
 如要通过派生类对象访问基类中被屏蔽的同名成员，应使用基类名限定(::)。
 
 
 
 */


//1.同名二义性
class name1{
public:
    int a = 123;
    int b = 10;
    void fun(){
        printf("name1  666\n");
        printf("%d\n", this->a);
    }
};

class name2
{
public:
    int a = 2;
    int b = 100;
    void fun(){
        printf("name2  7777\n");
        printf("%d\n", this->a);
    }
};

class name3:public name1, name2
{
public:
    int a = 3; // 同名覆盖
    void fun(){ //同名覆盖
        printf("gegeg\n");
        printf("%d\n", a);
    }
};

int main3(){
    
    name3 n3;
    
    n3.fun();
    //    printf("输出的东西是具有二义性的  %d", n3.b);
    
    return 0;
}


//路径二义性  http://blog.csdn.net/whz_zb/article/details/6843298

/*
 为了解决路径二义性问题，引入虚基类。
 –用于有共同基类的多继承场合(多层共祖)
 声明
 –以virtual修饰说明共同的直接基类
 例：class B1: virtual public B
 作用
 –用来解决多继承时可能发生的对同一基类继承多次和多层而产生的二义性问题.
 –为最远的派生类提供唯一的基类成员，而不重复产生个副本。
 注意：
 –在第一级继承时就要将共同基类设计为虚基类。
 虚基类举例
 class B { public: int b;};
 class B1 : virtual public B { private: int b1;};
 class B2 : virtualpublic B { private: int b2;};
 class C: public B1, public B2{ private: float d;};
 在子类对象中，最远基类成分是唯一的。于是下面的访问是正确的：
 C cobj;
 cobj.b;
 
 */

class name{
public:
    int a;
    void fun(){
        printf("dfsfsd\n");
    }
};

class name4:virtual public name
{
    int b;
};

class name5:virtual public name
{
    int c;
};

class name6:public name4, name5
{
};

int main4(){
    
    name6 n6;
    n6.fun();
    return 0;
}



//-------------------------分割线--------------------------
//private public protect
/*
 1.类的一个特征就是封装，public和private作用就是实现这一目的。所以：
 用户代码（类外）可以访问public成员而不能访问private成员；private成员只能由类成员（类内）和友元访问。
 
 2.类的另一个特征就是继承，protected的作用就是实现这一目的。所以：
 protected成员可以被派生类对象访问，不能被用户代码（类外）访问。
 //我怎么感觉这样描述有问题~， 应该是，protected成员可以被派生类中访问吧。
 */

class p1{
public:
    int a = 1;
    void fun(){
        printf("111111\n");
        printf("%d\n", b);
        printf("%d\n", c);
    }
private:
    int b = 2;
    void fun2(){
        printf("222222\n");
        printf("%d\n", b);
    }
protected:
    int c = 3;
    void fun3(){
        printf("333333\n");
    }
};


//要知道，什么是派生类对象，并不是说，在派生类中定义父类。
class p2:public p1
{
public:
    p1 p;
    void fun(p1 *a){
        //        p.fun2(); //因为fun2是p1的私有的，所以没有办法访问（达到封装的目的）
        //        p.fun3();
        //        a->fun3();
        
        printf("我就是这么吊，输出的是父亲类的c值： %d\n", c);
        //        b = 2;
    }
};


int main5(){
    
    p1 p;
    p.a = 3;
    p.fun();
    
    //    p.fun2(); //私有不能被直接访问
    //    p.fun3();
    
    
    p2 hxl;
    hxl.fun(new p1);
    
    
    /*
     我怎么感觉这样描述有问题~， 应该是，protected成员可以被派生类中访问吧。
     不然，为什么这个报错，其实也没有意义啊。。。
     没有意义是因为，hxl是p2的子类，继承了父类的东西，b就是继承来的，那么是什么类型，
     public？ 显然不应该呀。还说应该是同样的private类型，好。
     如此，我们可以看出它就是p2里直接定义的private的，那么hxl.b还有意义吗？
     */
    //    printf("%d", hxl.b);
    return 0;
}


/*
 继承中的特点：
 先记住：不管是否继承，上面的规则永远适用！
 有public, protected, private三种继承方式，它们相应地改变了基类成员的访问属性。
 1.public继承：基类public成员，protected成员，private成员的访问属性在派生类中分别变成：public, protected, private
 2.protected继承：基类public成员，protected成员，private成员的访问属性在派生类中分别变成：protected, protected, private
 3.private继承：基类public成员，protected成员，private成员的访问属性在派生类中分别变成：private, private, private
 但无论哪种继承方式，上面两点都没有改变：
 1.private成员只能被本类成员（类内）和友元访问，不能被派生类访问；
 2.protected成员可以被派生类访问。
 */

class q1{
public:
    int a = 1;
    void fun(){
        printf("dfljdl\n");
    }
private:
    int b = 2;
    void fun2(){
        printf("6666\n");
    }
protected:
    int c = 3;
    void fun3(){
        printf("7777\n");
    }
};

//public继承方式,ok，都是一样的啦
class q2:public q1
{
    void fun4(){
        printf("输出a %d", a);
        printf("输出c %d", c);//是允许的，因为他用来继承呀
        //        printf("输出b %d", b);//不允许的，因为他是私有的，不能在派生类中访问呀
    }
};

//protected继承方式， ok， public变成了protected的了，其他不变
class q3:protected q1
{
    void fun4(){
        printf("输出a %d", a);//ok，变成了protected
        printf("输出c %d", c);//是允许的，因为他用来继承呀
        
        //        printf("输出b %d", b);//不允许，不解释了，一样的
    }
};

//private继承方式，ok，全部变成了private，呵呵。。。。。。。。。。。
class q4:private q1
{
    void fun4(){
        
        //事实上我错了，是继承后，变成了private,对应q4的派生类来说
        printf("输出a的值看看，我猜是不行 %d:", a);
        printf("输出c的值看看，我猜是不行 %d:", c);
        //        printf("输出b的值看看，我猜是不行 %d:", b);
    }
};

//测试protected
class test1:public q3
{
    void fun5(){
        printf("输出a %d", a);//ok，变成了protected
        printf("输出c %d", c);//是允许的，因为他用来继承呀
        
        //        printf("这个肯定不行，我知道 %d", b);
    }
};

class test2:public q4
{
    void fun5(){
        //        printf("我猜，这个肯定是不行的，都是privated才对 %d", a);
        //        printf("我猜，这个肯定是不行的，都是privated才对 %d", c);
        //搞定，最后一个不用测都知道的。
    }
};


//-------------------分割线---------------------
/*
 友元函数和友元类
 2.友元函数的使用
 2.1友元函数的参数：
 因为友元函数没有this指针，则参数要有三种情况：
 2.1.1 要访问非static成员时，需要对象做参数；
 2.1.2 要访问static成员或全局变量时，则不需要对象做参数；
 2.1.3 如果做参数的对象是全局对象，则不需要对象做参数；
 
 2.2友元函数的位置
 因为友元函数是类外的函数，所以它的声明可以放在类的私有段或公有段且没有区别。
 2.3友元函数的调用
 可以直接调用友元函数，不需要通过对象或指针
 */

class myFriend{
private:
    int a = 1;
    
    //其实在private,protected,public里定义都是一样的。
    friend void fun(myFriend f){
        //        printf("我要从外部输出a的值 %d\n", a);//要访问非static成员时，需要对象做参数；
        printf("我要从外部输出a的值 %d\n", f.a);
    }
    
    friend void myFriendFun(myFriend f);
};

void myFriendFun(myFriend f){
    printf("我在这里也能输出a， 真是很神奇，就相当于在类内部一样  %d\n", f.a);
}

int main7(){
    fun(*new myFriend());
    myFriendFun(*new myFriend());
    return 0;
}




//友元类

class girl{
    friend class boy; //声明boy是girl的友元类
private:
    int lala = 123;
    void fun(){
        printf("我是girl，输出我的lala: %d\n", lala);
    }
    
};

class boy{
public:
    int a = 1;
    void grap(girl g);
};

void boy::grap(girl g){
    printf("我是boy，我将要调用girl类里面的函数了\n");
    g.fun();
}

int main8(){
    boy bbb;
    bbb.grap(*new girl());
    return 0;
}


//只用一个类中的一个函数，成为另一个类的友元

class tea;
class stu{
public:
    int a = 1;
    
    //这里有个问题，我被坑了，
    //void hxltom(tea t){} //这里是创建对象，？那 tea &t又代表什么意思！！
    //所以这里又衍生出了另一个问题，我要去弄明白这里具体是什么鬼东东。。。。
    void hxltom(tea &t){
        
    }
};

class tea{
private:
    friend void stu::hxltom(tea &t);
};

int main(){
    printf("test\n");
    return 0;
}


