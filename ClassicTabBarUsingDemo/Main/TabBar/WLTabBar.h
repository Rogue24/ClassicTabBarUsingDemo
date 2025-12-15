//
//  WLTabBar.h
//  WoLive
//
//  Created by 周健平 on 2019/8/6.
//  Copyright © 2019 zhoujianping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPBounceView.h"
@class WLTabBar;
@class WLTabBarItem;

@protocol WLTabBarDelegate <NSObject>
- (void)tabBar:(WLTabBar *)tabBar didSelectItemAt:(NSInteger)index;
@end

@interface WLTabBar : UIView
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) id<WLTabBarDelegate> delegate;

@property (nonatomic, strong) NSMutableArray<WLTabBarItem *> *tabBarItems;
- (void)addItemWithTitle:(NSString *)title
              normalIcon:(NSString *)normalIcon
              selectIcon:(NSString *)selectIcon
                   index:(NSInteger)index;

@property (nonatomic, weak) UIView *plusSuperView;
@property (nonatomic, weak) JPBounceView *plusView;
@property (nonatomic, assign, readonly) BOOL isAnimating;
@property (nonatomic, assign, readonly) BOOL plusing;
- (void)showPlus:(BOOL)isAnimated;
- (void)closePlus:(BOOL)isAnimated;

@property (nonatomic, weak) JPBounceView *mobileView;
@property (nonatomic, weak) JPBounceView *equipmentView;
@property (nonatomic, weak) JPBounceView *vrEquipmentView;
@end

@interface WLTabBarItem : JPBounceView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                        index:(NSInteger)index
                   normalIcon:(NSString *)normalIcon
                   selectIcon:(NSString *)selectIcon;

@property (nonatomic, weak, readonly) UIViewController *childVC;
@property (nonatomic, assign, readonly) NSInteger *index;

@property (nonatomic, assign) BOOL isSelected;
- (void)setIsSelected:(BOOL)isSelected animated:(BOOL)animated;

@property (nonatomic, assign) BOOL isHasBadge;
- (void)setIsHasBadge:(BOOL)isHasBadge animated:(BOOL)animated;

@end
