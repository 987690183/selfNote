--[[

	虚函数




	-----------------美丽分割线-----------------
	纯虚函数

	引入原因：

	1、同“虚函数”；

	2、在很多情况下，基类本身生成对象是不合情理的。例如，动物作为一个基类可以派生出老虎、孔雀等子类，但动物本身生成对象明显不合常理。

	//纯虚函数就是基类只定义了函数体，没有实现过程定义方法如下

	// virtual void Eat() = 0; 直接=0 不要 在cpp中定义就可以了

	//纯虚函数相当于接口，不能直接实例话，需要派生类来实现函数定义


	-----------------美丽分割线-----------------
	虚函数和纯虚函数区别

		
]]