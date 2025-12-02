//
//  JPConstant.m
//  Infinitee2.0
//
//  Created by 周健平 on 2017/9/24.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPConstant.h"
#import <ClassicTabBarUsingDemo-Swift.h>

@implementation JPConstant

static CGFloat uiBasisWScale_ = 1.0;
static CGFloat uiBasisHScale_ = 1.0;

+ (void)initialize {
    uiBasisWScale_ = Env.screenWidth / 375.0;
    uiBasisHScale_ = Env.screenHeight / 667.0;
}

+ (CGFloat)UIBasisWidthScale {
    return uiBasisWScale_;
}

+ (CGFloat)UIBasisHeightScale {
    return uiBasisHScale_;
}

@end
