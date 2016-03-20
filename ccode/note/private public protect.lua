1.类的一个特征就是封装，public和private作用就是实现这一目的。所以：
用户代码（类外）可以访问public成员而不能访问private成员；private成员只能由类成员（类内）和友元访问。

2.类的另一个特征就是继承，protected的作用就是实现这一目的。所以：
protected成员可以被派生类对象访问，不能被用户代码（类外）访问。


--很简单。--by hxl
继承中的特点：
先记住：不管是否继承，上面的规则永远适用！
有public, protected, private三种继承方式，它们相应地改变了基类成员的访问属性。
1.public继承：基类public成员，protected成员，
private成员的访问属性在派生类中分别变成：public, protected, private

2.protected继承：基类public成员，protected成员，
private成员的访问属性在派生类中分别变成：protected, protected, private

3.private继承：基类public成员，protected成员，
private成员的访问属性在派生类中分别变成：private, private, private

但无论哪种继承方式，上面两点都没有改变：
1.private成员只能被本类成员（类内）和友元访问，不能被派生类访问；
2.protected成员可以被派生类访问。
