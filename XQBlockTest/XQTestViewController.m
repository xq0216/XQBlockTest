//
//  XQTestViewController.m
//  XQBlockTest
//
//  Created by LaiXuefei on 2017/9/19.
//  Copyright © 2017年 lxf. All rights reserved.
//

#import "XQTestViewController.h"


/*
 *  弱引用&强引用
 */
#define WEAK_SELF_OBJ(obj)   __weak __typeof(obj) weakSelf = obj;
#define STRONG_SELF_OBJ(obj)  __strong __typeof(obj) strongSelf = obj; if (!strongSelf) {NSLog(@"XQ: %s >>>>> strongSelf = nil >>>> %d",__FUNCTION__,__LINE__);return ;}

static CGFloat const delayTime = 3.;

typedef void (^XQTestBlock)() ;

@interface XQTestViewController (){
    NSString *p_testStr;
    XQTestBlock p_block;
}
@property(nonatomic, strong)NSString *testStr;
@property(nonatomic, strong)XQTestBlock block;
@end

@implementation XQTestViewController
- (void)dealloc{
    NSLog(@">>> delloc 执行了 <<<<");
}

- (void)viewDidLoad {
    [super viewDidLoad];

     p_testStr = @"成员变量";

    self.testStr = @"属性";

    //根据所选类型，演示block
    switch (_currentType) {
        case BlockType_TempBlock:
        {
            [self tempBlock];
        }
            break;
        case BlockType_MemberBlock:
        {
            [self memberBlock];
        }
            break;
        case BlockType_PropertyBlock:
        {
            [self propertyBlock];
        }
            break;
        case BlockType_TempBlockContainGCD:
        {
            [self tempBlockAndGCD];
        }
            break;
        case BlockType_MemberBlockContainGCD:
        {
            [self memberBlockAndGCD];
        }
            break;
        case BlockType_PropertyBlockContainGCD:
        {
            [self propertyBlockAndGCD];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Block 演示

/**
 演示临时变量 tempBlock 对 self 进行强引用是否会造成循环引用
 */
- (void)tempBlock{
     //self 没有持有 testBlock，故 testBlock 直接强引用 self，没有形成闭环，界面返回时，该类实例还是会释放
    void (^testBlock)() = ^(){
        self.testStr = @"Hello block";
        NSLog(@"testBlock执行了 -- self.testStr = %@",self.testStr);
    };
    testBlock();
}

/**
 演示临时变量 testBlock 中含有 GCD，而 GCD 对 self 进行强引用是否会造成循环引用
 */
- (void)tempBlockAndGCD{
    //self 没有持有 testBlock，故 testBlock 持有 GCD，而 GCD 直接强引用 self，没有形成闭环，界面返回时，GCD执行完了后，该类实例还是会释放
    void (^testBlock)() = ^(){
        NSLog(@">>>testBlock执行了<<<<");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.testStr = @"Hello block";
            NSLog(@"gcd执行了 -- self.testStr = %@",self.testStr);
        });
    };
    testBlock();
}

/**
 演示成员变量 p_block 对 self 进行引用，如何不造成循环引用
 */
- (void)memberBlock{
    WEAK_SELF_OBJ(self)
    p_block = ^(){
        STRONG_SELF_OBJ(weakSelf)
        NSLog(@"p_block执行了 -- p_testStr = %@",strongSelf -> p_testStr);//若直接用p_testStr，则实际上用的是 self -> p_testStr，则界面返回，不会释放该类实例
    };
    p_block();

    /* p_block执行后，置为nil，不会造成循环引用，界面返回也会进行释放
     p_block = ^(){
     NSLog(@"p_block执行了 -- p_testStr = %@",strongSelf -> p_testStr);
     };
     p_block();
     p_block = nil;

     */
}

/**
 演示成员变量 p_block 中含有 GCD，而 GCD 对 self 进行引用，如何不造成循环引用
 */
- (void)memberBlockAndGCD{
    WEAK_SELF_OBJ(self)
    p_block = ^(){
        NSLog(@">>>>p_block执行了<<<");
        STRONG_SELF_OBJ(weakSelf)
        //若用self，则界面返回，该类实例不会释放（GCD还是会执行完）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //GCD 没执行就返回，此处两次引用self，用了 strongSelf，GCD执行完了后，才执行 dealloc；若用一次引用self 用 weakself，会立马执行 dealloc，之后执行 GCD
            strongSelf.testStr = @"Hello block";
            NSLog(@"gcd执行了 -- self.testStr = %@",strongSelf.testStr);
        });
    };
    p_block();

    /* p_block 执行后，置为nil，界面返回也会进行释放
    p_block = ^(){
        NSLog(@">>>>p_block执行了<<<");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.testStr = @"Hello block";
            NSLog(@"gcd执行了 -- self.testStr = %@",self.testStr);
        });
    };
    p_block();

    p_block = nil;
     */
}

/**
 演示属性 block 对 self 进行引用，如何不造成循环引用
 */
- (void)propertyBlock{
    WEAK_SELF_OBJ(self)
    self.block = ^(){
        NSLog(@"block 执行了 -- self.testStr = %@",weakSelf.testStr);//若用self.testStr，则界面返回，不会释放该类实例
    };
    self.block();

    /* self.block 执行后，置为nil，不会造成循环引用，界面返回也会进行释放
     self.block = ^(){
     NSLog(@"p_block执行了 -- self.testStr = %@",self.testStr);
     };
     self.block();
     self.block = nil;

     */
}

/**
 演示成员变量 p_block 中含有 GCD，而 GCD 对 self 进行引用，如何不造成循环引用
 */
- (void)propertyBlockAndGCD{
    WEAK_SELF_OBJ(self)
    self.block = ^(){
        NSLog(@">>>>block执行了<<<");
        STRONG_SELF_OBJ(weakSelf)
        //若用self，则界面返回，该类实例不会释放（GCD还是会执行完）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //GCD 没执行就返回，此处两次引用self，用了 strongSelf，GCD执行完了后，才执行 dealloc；若用一次引用self 用 weakself，会立马执行 dealloc，之后执行 GCD
            strongSelf.testStr = @"Hello block";
            NSLog(@"gcd执行了 -- self.testStr = %@",weakSelf.testStr);
        });
    };
    self.block();

    /* p_block 执行后，置为nil，界面返回也会进行释放
     self.block = ^(){
     NSLog(@">>>>p_block执行了<<<");
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     self.testStr = @"Hello block";
     NSLog(@"gcd执行了 -- self.testStr = %@",self.testStr);
     });
     };
     self.block();

     self.block = nil;
     */
}

@end
