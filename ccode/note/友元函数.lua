http://www.cnblogs.com/BeyondAnyTime/archive/2012/06/04/2535305.html

1.友元函数的简单介绍

1.1为什么要使用友元函数

在实现类之间数据共享时，减少系统开销，提高效率。如果类A中的函数要访问类B中的成员（例如：智能指针类的实现），
那么类A中该函数要是类B的友元函数。具体来说：为了

使其他类的成员函数直接访问该类的私有变量。即：允许外面的类或函数去访问类的私有变量和保护变量，从而使两个类共享同一函数。

实际上具体大概有下面两种情况需要使用友元函数：
	(1）运算符重载的某些场合需要使用友元。
	(2)两个类要共享数据的时候。

1.2使用友元函数的优缺点
1.2.1优点：能够提高效率，表达简单、清晰。
1.2.2缺点：友元函数破环了封装机制，尽量不使用成员函数，除非不得已的情况下才使用友元函数。

------------------------------------------------------------------

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

2.4友元函数的分类：

根据这个函数的来源不同，可以分为三种方法：

2.4.1普通函数友元函数
2.4.1.1 目的：使普通函数能够访问类的友元
2.4.1.2 语法：
声明： friend + 普通函数声明
实现位置：可以在类外或类中
实现代码：与普通函数相同
调用：类似普通函数，直接调用
	class INTEGER
	{
	　　friend void Print(const INTEGER& obj);//声明友元函数
	};
	void Print(const INTEGER& obj）
	{
	　　 //函数体
	}
	void main()
	{
	　　INTEGER obj;
	　　Print(obj);//直接调用
	}
------------------------------------------------------------------

2.4.2类Y的所有成员函数都为类X友元函数—友元类
2.4.2.1目的：使用单个声明使Y类的所有函数成为类X的友元，它提供一种类之间合作的一种方式，使类Y的对象可以具有类X和类Y的功能。
2.4.2.2语法：
声明位置：公有私有均可，常写为私有(把类看成一个变量)
声明： friend + 类名（不是对象哦）
//友元类
class boy;
class girl{
private:
    int lala = 123;
    void fun(){
        printf("我是girl，输出我的lala: %d\n", lala);
    }
    friend boy; //声明boy是girl的友元类
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

int main(){
    boy bbb;
    bbb.grap(*new girl());
    return 0;
}

------------------------------------------------------------------

2.4.3类Y的一个成员函数为类X的友元函数
2.4.3.1目的：使类Y的一个成员函数成为类X的友元，具体而言：在类Y的这个成员函数中，借助参数X，可以直接以X的私有变量
2.4.3.2语法：
声明位置：声明在公有中 （本身为函数）
声明：friend + 成员函数的声明
调用：先定义Y的对象y---使用y调用自己的成员函数---自己的成员函数中使用了友元机制


------------------------------------------------------------------
4.友元函数和类的成员函数的区别
4.1 成员函数有this指针，而友元函数没有this指针。
4.2 友元函数是不能被继承的，就像父亲的朋友未必是儿子的朋友。

------------------------------------------------------------------

//友元函数，一个函数是多个类的友元的情况
class Country;
class Internet
{
public:
    Internet(char *name,char *address)        // 改为：internet(const char *name , const char *address)
    {
        strcpy(Internet::name,name);
        strcpy(Internet::address,address);
    }
    friend void ShowN(Internet &obj,Country &cn);//注意这里
public:
    char name[20];
    char address[20];
};
class Country
{
public:
    Country()
    {
        strcpy(cname,"中国");
    }
    friend void ShowN(Internet &obj,Country &cn);//注意这里
protected:
    char cname[30];
};

void ShowN(Internet &obj,Country &cn)
{
    cout<<cn.cname<<"|"<<obj.name<<endl;
}

int main1()
{
    char str1[] = "大气象";
    char str2[] = "http://greatverve.cnblogs.com";
    Internet a(str1, str2);
    Country b;
    ShowN(a,b);
    cin.get();
    return 0;
}





