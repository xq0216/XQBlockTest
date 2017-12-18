# XQBlockTest
该 demo 是用于演示 Block 解决循环引用的 3 种方式，

# 一、循环引用的原因
简单来说就是，【互相持有，造成内存不释放】。

如： self --持有--> block --持有--> self  形成了一个环，中间还可能穿插其他对象，反正最后形成了一个闭环，造成谁也不撒手，故内存永远不释放。

block 引用 self 的方式，可以是调用 self 的 **方法** ，使用 self 的 **属性** 和 **成员变量** 。

# 二、解决循环引用
也是一句话，砍掉任一一个链，破坏这个互相持有的闭环。

1、self 不持有 block

      void (^testBlock)() = ^(){  
        self.testStr = @"Hello block";  
      };  
      testBlock(@"");   
      
2、block 不强持有 self ： weakSelf & strongSelf

      __weak __typeof__(self) weakSelf = self;  
  
      __strong typeof(weakSelf) strongSelf = weakSelf; 
      
即 Block 里对 self 为弱引用，不持有 self，即 self 的引用计数不会+1.

若仅引用一次，用weakSelf ，多次引用，则用 strongSelf 。strongSelf 是为了保证在 block 执行过程中，self 不会再变化。

      __weak __typeof__(self) weakSelf = self;  
      self.block = ^(){  
          __strong typeof(weakSelf) strongSelf = weakSelf;  
          testStr0 = @"这是 test 字符串";  
          NSLog(@"%@",strongSelf->testStr0);  
      };  
      self.block();
      
另，在 block 中对 self 的引用情况，包括调用 self 的 **方法**，使用 self 的 **属性** 和 **成员变量**。

      __weak __typeof__(self) weakSelf = self;  
      self.block = ^(){  
          __strong typeof(weakSelf) strongSelf = weakSelf;  
          strongSelf->p_testStr = @"这是成员变量";  
          NSLog(@"%@",strongSelf->p_testStr);  
      };  
      self.block(); 
      
3、block 执行完后，置为 nil

      self.testStr = @"Test Str";  
      self.block = ^(){  
          NSLog(@"%@",self.testStr);  
      };  
      self.block();  
      self.block = nil;  
     
# 三、扩展

在总结循环引用的问题时，突发奇想这样一种情况：

若 block 中，有用了 GCD , GCD 的 block 里又用到了 self ，那该如何判断是否存在循环引用呢？

如：

      void (^testBlock)() = ^(){  
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{  
              self.testStr = @"Hello block";  
              NSLog(@"%@>>>gcd执行了",self.testStr);  
          });  
      };  
      testBlock();  
      
 再如：
 
       self.block = ^(){  
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{  
              self.testStr = @"Hello block";  
              NSLog(@"%@>>>gcd执行了",self.testStr);  
          });  
      };  
      self.block();
      
 其实，分析其持有关系，看有没有形成互相持有的环，若存在环，那肯定就循环引用了。
 
1、testBlock --持有-->  GCD --持有-->  self 【没有形成环，不存在循环引用】

2、self --持有--> block --持有--> GCD --持有--> self 【形成了环，故存在循环引用】

解决循环引用的方式还是如上面所述的三点即可。

# 四、其他

以下罗列出不同情况下，block 的声明方式，demo中也有相应备注：
（ps：以下 block 声明方式的总结来源于：http://fuckingblocksyntax.com/ ，感谢作者分享！）

## 1、作为局部变量
        returnType (^blockName)(parameterTypes) = ^returnType(parameters) {...};

## 2、作为属性
        @property (nonatomic, copy, nullability) returnType (^blockName)(parameterTypes);

## 3、方法声明时，作为参数
        - (void)someMethodThatTakesABlock:(returnType (^nullability)(parameterTypes))blockName;

## 4、方法调用时，作为参数
        [someObject someMethodThatTakesABlock:^returnType (parameters) {...}];

## 5、使用 typedef 声明
        typedef returnType (^TypeName)(parameterTypes);
        TypeName blockName = ^returnType(parameters) {...};







