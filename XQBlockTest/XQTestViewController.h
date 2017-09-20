//
//  XQTestViewController.h
//  XQBlockTest
//
//  Created by LaiXuefei on 2017/9/19.
//  Copyright © 2017年 lxf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BlockType) {
    BlockType_TempBlock = 0,
    BlockType_TempBlockContainGCD,
    BlockType_MemberBlock,
    BlockType_MemberBlockContainGCD,
    BlockType_PropertyBlock,
    BlockType_PropertyBlockContainGCD
};

@interface XQTestViewController : UIViewController
@property(nonatomic, assign)BlockType currentType;
@end
