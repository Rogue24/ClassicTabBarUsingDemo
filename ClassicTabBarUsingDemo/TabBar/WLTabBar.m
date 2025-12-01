//
//  WLTabBar.m
//  WoLive
//
//  Created by 周健平 on 2019/8/6.
//  Copyright © 2019 zhoujianping. All rights reserved.
//

#import "WLTabBar.h"
#import "JPBounceView.h"
#import "JPImageView.h"
#import "UIImage+JPExtension.h"
#import "WLAuthenticationChooseViewController.h"

//#import "WLPlaybackViewController.h"

#import "WLRecordConfirmViewController.h"
#import "JPSystemImagePickerTool.h"
#import "WLVideoInterceptionViewController.h"
#import "JPPhotoTool.h"
#import "WLRecordListViewController.h"

@interface WLTabBar () <JPLiveModuleTransitionDelegate>
@property (nonatomic, weak) UIVisualEffectView *blurView;

@property (nonatomic, weak) UIView *bgView;
@property (nonatomic, weak) UILabel *mobileLabel;
@property (nonatomic, weak) UILabel *equipmentLabel;
@property (nonatomic, weak) UILabel *vrEquipmentLabel;

@property (nonatomic, copy) NSString *networkStatus;
@property (nonatomic, assign) WLPushType pushType;

@property (nonatomic, weak) UILongPressGestureRecognizer *lpGR;
@end

@implementation WLTabBar
{
    CGSize _tabBarItemSize;
    CGSize _popBtnSize;
    
    CGFloat _blurPlusY;
    CGPoint _mobileIconCenter;
    CGPoint _equipmentIconCenter;
    CGPoint _vrEquipmentIconCenter;
    CGPoint _mobileTitleCenter;
    CGPoint _equipmentTitleCenter;
    CGPoint _vrEquipmentTitleCenter;
}

- (NSMutableArray<WLTabBarItem *> *)tabBarItems {
    if (!_tabBarItems) _tabBarItems = [NSMutableArray array];
    return _tabBarItems;
}

+ (CGRect)tabBarFrame {
    return CGRectMake(0, JPPortraitScreenHeight - JPTabBarH, JPPortraitScreenWidth, JPTabBarH);
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = UIColor.clearColor;
        self.backgroundImage = [UIImage new];
        self.shadowImage = [UIImage new];
        
        CGRect tabBarFrame = self.class.tabBarFrame;
        self.tabBarFrame = tabBarFrame;
        
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:[WLConstant extraLightBlurStyle]]];
        blurView.frame = CGRectMake(0, 0, tabBarFrame.size.width, tabBarFrame.size.width);
        blurView.layer.masksToBounds = YES;
        [self addSubview:blurView];
        self.blurView = blurView;
        
        _tabBarItemSize = CGSizeMake(JPScaleValue(70), JPBaseTabBarH);
        _popBtnSize = CGSizeMake(JPScaleValue(80), JPBaseTabBarH);
        
        UIView *plusSuperView = [[UIView alloc] initWithFrame:CGRectMake(JPHalfOfDiff(tabBarFrame.size.width, _popBtnSize.width), 0, _popBtnSize.width, _popBtnSize.height)];
        [self addSubview:plusSuperView];
        self.plusSuperView = plusSuperView;
        
        JPBounceView *plusView = [[JPBounceView alloc] initWithFrame:plusSuperView.bounds];
        plusView.layer.contentsGravity = kCAGravityCenter;
        plusView.layer.contentsScale = JPScreenScale;
        plusView.image = [UIImage imageNamed:@"com_home_live_icon"];
        plusView.scale = 1.15;
        plusView.scaleDuration = 0.2;
        plusView.isJudgeBegin = YES;
        [plusSuperView addSubview:plusView];
        self.plusView = plusView;
        
        @jp_weakify(self);
        plusView.viewTouchUpInside = ^(JPBounceView *bounceView) {
            @jp_strongify(self);
            if (!self) return;
            [self didClickPlus];
        };
        
        UILongPressGestureRecognizer *lpGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        lpGR.minimumPressDuration = 0.4;
        [plusView addGestureRecognizer:lpGR];
        self.lpGR = lpGR;
        
        _blurPlusY = -(JPScaleValue(212) + JPDiffTabBarH - tabBarFrame.size.height);
        JPObserveNotification(self, @selector(updateColor), WLTraitCollectionDidChangeNotification, nil);
        JPObserveNotification(self, @selector(pushVcDidAppear), JPPushViewControllerDidAppearNotification, nil);
    }
    return self;
}

- (void)dealloc {
    JPRemoveNotification(self);
}

#pragma mark - 通知响应

- (void)updateColor {
    if (!self.plusing) self.plusView.image = [UIImage imageNamed:@"com_home_live_icon"];
}

- (void)pushVcDidAppear {
    [self closePlus:NO];
}

#pragma mark - 重写父类方法（布局子视图 & 点击区域的响应）

static BOOL added_ = NO;
- (void)setFrame:(CGRect)frame {
    [super setFrame:self.tabBarFrame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        UIView *subview = self.subviews[i];
        // 既然移除不了系统那条边，那就设为透明吧
        if (i == 0) {
            for (UIView *imgView in subview.subviews) {
                imgView.alpha = 0;
            }
        }
        Class class = NSClassFromString(@"UITabBarButton");
        if ([subview isKindOfClass:class]) {
            WLTabBarItem *tabBarItem = self.tabBarItems[index];
            subview.frame = tabBarItem.frame;
            subview.tag = index;
            if (!added_) {
                UIControl *child = (UIControl *)subview;
                [child addTarget:self action:@selector(touchingControl:) forControlEvents:UIControlEventTouchDown];
                [child addTarget:self action:@selector(touchingControl:) forControlEvents:UIControlEventTouchDragEnter];
                [child addTarget:self action:@selector(touchingControl:) forControlEvents:UIControlEventTouchDragInside];
                [child addTarget:self action:@selector(notTouchControl:) forControlEvents:UIControlEventTouchDragOutside];
                [child addTarget:self action:@selector(notTouchControl:) forControlEvents:UIControlEventTouchDragExit];
                [child addTarget:self action:@selector(notTouchControl:) forControlEvents:UIControlEventTouchCancel];
                [child addTarget:self action:@selector(notTouchControl:) forControlEvents:UIControlEventTouchUpOutside];
                [child addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            }
            index += 1;
        }
    }
    added_ = YES;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.plusing) {
        return YES;
    }
    BOOL inside = [super pointInside:point withEvent:event];
    if (inside) {
        if (CGRectContainsPoint(self.plusSuperView.frame, point)) {
            self.plusView.isTouching = YES;
            return inside;
        }
        for (WLTabBarItem *item in self.tabBarItems) {
            if (CGRectContainsPoint(item.frame, point)) {
                item.isTouching = YES;
                return inside;
            }
        }
    }
    return inside;
}

#pragma mark - 添加贴吧

- (UIViewController *)addChildVC:(UIViewController *)childVC
                           title:(NSString *)title
                           index:(NSInteger)index
                      normalIcon:(NSString *)normalIcon
                      selectIcon:(NSString *)selectIcon {
    WLNavigationController *navCtr = [[WLNavigationController alloc] initWithRootViewController:childVC];
    
    CGFloat w = _tabBarItemSize.width;
    CGFloat h = _tabBarItemSize.height;
    CGFloat x = 0;
    if (index > 1) {
        x = JPPortraitScreenWidth - w - (3 - index) * (w + JPScaleValue(2));
    } else {
        x = index * (w + JPScaleValue(2));
    }
    CGFloat y = 0;
    WLTabBarItem *tabBarItem = [[WLTabBarItem alloc] initWithFrame:CGRectMake(x, y, w, h) childVC:childVC title:title index:index normalIcon:normalIcon selectIcon:selectIcon];
    tabBarItem.isSelected = index == 0;
    [self.tabBarItems addObject:tabBarItem];
    [self insertSubview:tabBarItem belowSubview:self.plusSuperView];
    
    return navCtr;
}

#pragma mark - 自定义贴吧的点击响应

- (void)touchingControl:(UIControl *)control {
    if (self.plusing || self.isAnimating) return;
    WLTabBarItem *tabBarItem = self.tabBarItems[control.tag];
    tabBarItem.isTouching = YES;
}

- (void)notTouchControl:(UIControl *)control {
    if (self.plusing || self.isAnimating) return;
    WLTabBarItem *tabBarItem = self.tabBarItems[control.tag];
    tabBarItem.isTouching = NO;
}

- (void)touchUpInside:(UIControl *)control {
    if (self.plusing || self.isAnimating) return;
    WLTabBarItem *tabBarItem = self.tabBarItems[control.tag];
    tabBarItem.isTouching = NO;
    self.selectedIndex = control.tag;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (self.plusing || self.isAnimating) return;
    if (_selectedIndex == selectedIndex)return;
    
    WLTabBarItem *currTabBarItem = self.tabBarItems[_selectedIndex];
    [currTabBarItem setIsSelected:NO animated:YES];
    
    WLTabBarItem *tabBarItem = self.tabBarItems[selectedIndex];
    [tabBarItem setIsSelected:YES animated:YES];
    
    _selectedIndex = selectedIndex;
}

#pragma mark - 手势回调

- (void)longPressAction:(UILongPressGestureRecognizer *)lrGR {
    if (self.plusing) return;
    if (lrGR.state == UIGestureRecognizerStateBegan) {
        self.plusView.isCanTouchesBegan = NO;
        [self didClickPlus];
        AudioServicesPlaySystemSound(1519);
    }
}

- (void)didClickPlus {
    if (self.plusing) {
        [self closePlus:YES];
    } else {
        [self showPlus:YES];
    }
}

#pragma mark - plus动画

- (void)setIsAnimating:(BOOL)isAnimating {
    _isAnimating = isAnimating;
    if (!isAnimating) self.plusView.isCanTouchesBegan = YES;
}

- (void)setPlusing:(BOOL)plusing {
    _plusing = plusing;
    self.bgView.userInteractionEnabled = plusing;
    self.mobileView.userInteractionEnabled = plusing;
    self.equipmentView.userInteractionEnabled = plusing;
    self.vrEquipmentView.userInteractionEnabled = plusing;
    self.lpGR.enabled = !plusing;
}

- (void)showPlus:(BOOL)animated {
    if (self.plusing) return;
    [self plusAction:animated];
}

- (void)closePlus {
    [self closePlus:YES];
}

- (void)closePlus:(BOOL)animated {
    if (!self.plusing) return;
    [self plusAction:animated];
}

- (void)plusAction:(BOOL)animated {
    self.isAnimating = YES;
    self.plusing = !self.plusing;
    
    [self preparePlusSubviews];
    
    UIColor *bgColor = self.plusing ? JPRGBAColor(0, 0, 0, 0.35) : JPRGBAColor(0, 0, 0, 0);
    
    CGRect blurFrame = self.blurView.frame;
    blurFrame.origin.y = self.plusing ? _blurPlusY : 0;
    
    CGFloat blurRadius = self.plusing ? WL16StaticCornerRadius : 0;
    
    CGFloat iconAlpha = self.plusing ? 1 : 0;
    CGFloat iconScale = self.plusing ? 1 : (self.plusSuperView.jp_width / self.mobileView.jp_width);
    
    CGPoint mobileTitleCenter = self.plusSuperView.center;
    CGPoint equipmentTitleCenter = mobileTitleCenter;
    CGPoint vrEquipmentTitleCenter = mobileTitleCenter;
    
    CGPoint mobileIconCenter = mobileTitleCenter;
    CGPoint equipmentIconCenter = mobileTitleCenter;
    CGPoint vrEquipmentIconCenter = mobileTitleCenter;
    
    if (self.plusing) {
        mobileTitleCenter = _mobileTitleCenter;
        equipmentTitleCenter = _equipmentTitleCenter;
        vrEquipmentTitleCenter = _vrEquipmentTitleCenter;
        
        mobileIconCenter = _mobileIconCenter;
        equipmentIconCenter = _equipmentIconCenter;
        vrEquipmentIconCenter = _vrEquipmentIconCenter;
    }
    
    UIImage *plusImage = self.plusing ? [UIImage imageNamed:@"live_shut_crude_black_icon"] : [UIImage imageNamed:@"com_home_live_icon"];
    
    CGFloat tabBarItemScaleXY = self.plusing ? 0.5 : 1;
    CGFloat tabBarItemAlpha = self.plusing ? 0 : 1;
    
    if (!animated) {
        self.bgView.backgroundColor = bgColor;
        
        self.blurView.frame = blurFrame;
        self.blurView.layer.cornerRadius = blurRadius;
        
        self.mobileLabel.alpha = iconAlpha;
        self.mobileLabel.center = mobileTitleCenter;
        
        self.equipmentLabel.alpha = iconAlpha;
        self.equipmentLabel.center = equipmentTitleCenter;
        
        self.vrEquipmentLabel.alpha = iconAlpha;
        self.vrEquipmentLabel.center = vrEquipmentTitleCenter;
        
        self.mobileView.transform = CGAffineTransformMakeScale(iconScale, iconScale);
        self.mobileView.center = mobileIconCenter;
        self.mobileView.alpha = iconAlpha;
        
        self.equipmentView.transform = CGAffineTransformMakeScale(iconScale, iconScale);
        self.equipmentView.center = equipmentIconCenter;
        self.equipmentView.alpha = iconAlpha;
        
        self.vrEquipmentView.transform = CGAffineTransformMakeScale(iconScale, iconScale);
        self.vrEquipmentView.center = vrEquipmentIconCenter;
        self.vrEquipmentView.alpha = iconAlpha;
        
        self.plusView.image = plusImage;
        
        for (WLTabBarItem *tabBarItem in self.tabBarItems) {
            tabBarItem.layer.transform = CATransform3DMakeScale(tabBarItemScaleXY, tabBarItemScaleXY, 1);
            tabBarItem.layer.opacity = tabBarItemAlpha;
        }
        
        self.isAnimating = NO;
        return;
    }
    
    NSTimeInterval beginTime = 0;
    
    // ------------------ 背景 ------------------
    [self.bgView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewBackgroundColor toValue:bgColor duration:0.3 beginTime:beginTime completionBlock:nil];
    
    CGFloat springSpeed = self.plusing ? 10 : 17;
    CGFloat springBounciness = self.plusing ? 7 : 4;
    [self.blurView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewFrame toValue:@(blurFrame) springSpeed:springSpeed springBounciness:springBounciness beginTime:beginTime completionBlock:nil];
    [self.blurView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerCornerRadius toValue:@(blurRadius) duration:0.3 beginTime:beginTime completionBlock:nil];
    // -----------------------------------------
    
    
    // ------------------ 标签 ------------------
    NSTimeInterval duration = self.plusing ? 0.3 : 0.15;
    [self.mobileLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@(iconAlpha) duration:duration beginTime:beginTime completionBlock:nil];
    [self.mobileLabel jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewCenter toValue:@(mobileTitleCenter) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    
    [self.equipmentLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@(iconAlpha) duration:duration beginTime:beginTime completionBlock:nil];
    [self.equipmentLabel jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewCenter toValue:@(equipmentTitleCenter) springSpeed:10 springBounciness:7 beginTime:beginTime  completionBlock:nil];
    
    [self.vrEquipmentLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@(iconAlpha) duration:duration beginTime:beginTime completionBlock:nil];
    [self.vrEquipmentLabel jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewCenter toValue:@(vrEquipmentTitleCenter) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    // -----------------------------------------
    
    
    // ------------------ 图标 ------------------
    CGPoint iconScaleXY = CGPointMake(iconScale, iconScale);
    
    [self.mobileView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(iconScaleXY) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    [self.mobileView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewCenter toValue:@(mobileIconCenter) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    [self.mobileView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewAlpha toValue:@(iconAlpha) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];

    [self.equipmentView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(iconScaleXY) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    [self.equipmentView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewCenter toValue:@(equipmentIconCenter) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    [self.equipmentView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewAlpha toValue:@(iconAlpha) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];

    [self.vrEquipmentView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(iconScaleXY) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    [self.vrEquipmentView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewCenter toValue:@(vrEquipmentIconCenter) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    [self.vrEquipmentView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewAlpha toValue:@(iconAlpha) springSpeed:10 springBounciness:7 beginTime:beginTime completionBlock:nil];
    // -----------------------------------------
    
    
    // ------------------ 按钮 ------------------
    [self.plusSuperView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(0.1, 0.1)) duration:0.13 beginTime:beginTime completionBlock:^(POPAnimation *anim, BOOL finished) {
        self.plusView.image = plusImage;
        [self.plusSuperView.layer jp_addPOPSpringAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(1, 1)) springSpeed:20 springBounciness:8 completionBlock:^(POPAnimation *anim, BOOL finished) {
            // 不知道被什么覆盖了点不了，重新按上去
            [self addSubview:self.plusSuperView];
            self.isAnimating = NO;
        }];
    }];
    // -----------------------------------------
    
    
    // ------------------ 贴吧 ------------------
    beginTime = self.plusing ? 0 : 0.15;
    springSpeed = 20;
    springBounciness = self.plusing ? 7 : 5;
    for (WLTabBarItem *tabBarItem in self.tabBarItems) {
        [tabBarItem.layer jp_addPOPSpringAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(tabBarItemScaleXY, tabBarItemScaleXY)) springSpeed:springSpeed springBounciness:springBounciness beginTime:beginTime completionBlock:nil];
        [tabBarItem.layer jp_addPOPSpringAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@(tabBarItemAlpha) springSpeed:springSpeed springBounciness:springBounciness beginTime:beginTime completionBlock:nil];
    }
    // -----------------------------------------
    
    AudioServicesPlaySystemSound((self.plusing ? 1397 : 1396));
}

#pragma mark 创建plus的子视图
- (void)preparePlusSubviews {
    if (self.bgView) {
        self.mobileView.hidden = NO;
        self.equipmentView.hidden = NO;
        self.vrEquipmentView.hidden = NO;
        return;
    }
    
    CGFloat w = JPPortraitScreenWidth;
    CGFloat h = JPPortraitScreenHeight;
    CGFloat x = 0;
    CGFloat y = self.jp_height - h;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    bgView.backgroundColor = JPRGBAColor(0, 0, 0, 0);
    [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePlus)]];
    [self insertSubview:bgView belowSubview:self.blurView];
    self.bgView = bgView;
    
    w = h = JPScaleValue(60);
    x = JPScaleValue(43);
    y = _blurPlusY + JPScaleValue(48);
    CGFloat space = (JPPortraitScreenWidth - 2 * x - 3 * w) / 2.0;
    
    self.mobileView = [self createTypeViewWithFrame:CGRectMake(x, y, w, h) image:[UIImage imageNamed:@"live_phone_icon"] bgColor:JPRGBColor(230, 55, 81) pushType:WLPushType_MobilePush];
    
    x = x + w + space;
    self.equipmentView = [self createTypeViewWithFrame:CGRectMake(x, y, w, h) image:[UIImage imageNamed:@"live_equipment_icon"] bgColor:WoLiveBlue pushType:WLPushType_EquipmentPush];
    
    x = x + w + space;
    self.vrEquipmentView = [self createTypeViewWithFrame:CGRectMake(x, y, w, h) image:[UIImage imageNamed:@"live_vr_icon"] bgColor:JPRGBColor(53, 188, 156) pushType:WLPushType_VR_EquipmentPush];
    
    _mobileIconCenter = self.mobileView.center;
    _equipmentIconCenter = self.equipmentView.center;
    _vrEquipmentIconCenter = self.vrEquipmentView.center;
    
    UIColor *textColor = [WLConstant lightBlackWhiteColor];
    self.mobileLabel = [self createTypeLabelWithTitle:@"手机直播" textColor:textColor typeView:self.mobileView];
    self.equipmentLabel = [self createTypeLabelWithTitle:@"专业设备直播" textColor:textColor typeView:self.equipmentView];
    self.vrEquipmentLabel = [self createTypeLabelWithTitle:@"VR直播" textColor:textColor typeView:self.vrEquipmentView];
    
    _mobileTitleCenter = self.mobileLabel.center;
    _equipmentTitleCenter = self.equipmentLabel.center;
    _vrEquipmentTitleCenter = self.vrEquipmentLabel.center;

    CGFloat iconScale = self.plusSuperView.jp_width / self.mobileView.jp_width;
    CGPoint center = self.plusSuperView.center;
    
    self.mobileView.transform = CGAffineTransformMakeScale(iconScale, iconScale);
    self.mobileView.center = center;
    self.mobileView.alpha = 0;
    
    self.equipmentView.transform = CGAffineTransformMakeScale(iconScale, iconScale);
    self.equipmentView.center = center;
    self.equipmentView.alpha = 0;
    
    self.vrEquipmentView.transform = CGAffineTransformMakeScale(iconScale, iconScale);
    self.vrEquipmentView.center = center;
    self.vrEquipmentView.alpha = 0;

    self.mobileLabel.center = center;
    self.mobileLabel.alpha = 0;
    
    self.equipmentLabel.center = center;
    self.equipmentLabel.alpha = 0;
    
    self.vrEquipmentLabel.center = center;
    self.vrEquipmentLabel.alpha = 0;
}

- (JPBounceView *)createTypeViewWithFrame:(CGRect)frame
                                    image:(UIImage *)image
                                  bgColor:(UIColor *)bgColor
                                 pushType:(WLPushType)pushType {
    JPBounceView *typeView = [[JPBounceView alloc] initWithFrame:frame];
    typeView.image = image;
    typeView.scale = 0.88;
    typeView.scaleDuration = 0.3;
    
    typeView.layer.cornerRadius = frame.size.height * 0.5;
    typeView.layer.masksToBounds = YES;
    typeView.backgroundColor = bgColor;
    typeView.tag = pushType;
    
    @jp_weakify(self);
    typeView.viewTouchUpInside = ^(JPBounceView *bounceView) {
        @jp_strongify(self);
        if (!self || self.isAnimating) return;
        [self choose:bounceView.tag];
    };
    
    [self insertSubview:typeView belowSubview:self.plusSuperView];
    return typeView;
}

- (UILabel *)createTypeLabelWithTitle:(NSString *)title textColor:(UIColor *)textColor typeView:(UIView *)typeView {
    UILabel *typeLabel = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.font = JPScaleFont(15);
        aLabel.textColor = textColor;
        aLabel.text = title;
        [aLabel sizeToFit];
        aLabel.center = CGPointMake(typeView.jp_midX, typeView.jp_maxY + JP8Margin + aLabel.jp_height * 0.5);
        aLabel;
    });
    [self insertSubview:typeLabel belowSubview:self.plusSuperView];
    return typeLabel;
}

#pragma mark - 前往直播

- (void)setNetworkStatus:(NSString *)networkStatus {
    _networkStatus = networkStatus;
    if (networkStatus && JPKeyWindow.userInteractionEnabled) {
        [JPProgressHUD showWithStatus:networkStatus];
    }
}

- (UIAlertAction *)albumAction {
    return [UIAlertAction actionWithTitle:@"去相册选视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [JPSystemImagePickerTool openSystemImagePickerWithTitle:@"选视频" message:nil options:JPSystemImagePickerPhotosAlbumOption otherAlertActions:nil willOpenImagePicker:^(JPImagePickerController *picker, BOOL isCamera) {
            picker.mediaTypes = @[(NSString *)kUTTypeMovie];
            picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        } willCloseImagePicker:nil didClosedImagePicker:nil imagePickerComplete:^(NSURL *mediaURL, UIImage *image) {
            WLRecordModel *model = [WLRecordModel modelWithAlbumVideoFilePath:mediaURL.absoluteString];
            WLRecordConfirmViewController *rcVC = [[WLRecordConfirmViewController alloc] initWithModel:model isFromRecordDone:NO];
            [(UINavigationController *)WLTabBarCtr.selectedViewController pushViewController:rcVC animated:YES];
        }];
    }];
}

- (void)keepRecord:(WLRecordModel *)recordingModel {
    [WLRecordModelTool recordingModel:recordingModel mergeVideosThenIsToRecordDone:NO mergeErrorBlock:^BOOL(WLRecordModel *kModel, WLVideosMergeFailureReason failureReason, NSString *path, NSInteger index, NSInteger total) {
        switch (failureReason) {
            case WLVideosMergeFailureReason_NotAssets:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [WLRecordModelTool removeModel:recordingModel];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [JPProgressHUD showInfoWithStatus:@"没有录制的视频" userInteractionEnabled:YES];
                    });
                });
                return NO;
            }
            case WLVideosMergeFailureReason_SingleVideoDamage:
            case WLVideosMergeFailureReason_AllVideoDamage:
            {
                if ((failureReason == WLVideosMergeFailureReason_SingleVideoDamage && (total == 1 || index != 0)) || failureReason == WLVideosMergeFailureReason_AllVideoDamage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [WLRecordModelTool removeModel:recordingModel];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [JPProgressHUD showErrorWithStatus:@"视频文件已损坏" userInteractionEnabled:YES];
                        });
                    });
                    return NO;
                } else {
                    return YES;
                }
            }
            case WLVideosMergeFailureReason_MergeURLExists:
                break;
            case WLVideosMergeFailureReason_MergeFailed:
            case WLVideosMergeFailureReason_MergeCancelled:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *actions = [NSMutableArray array];
                    [actions addObject:[UIAlertAction actionWithTitle:@"重新生成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [JPProgressHUD show];
                        [self keepRecord:recordingModel];
                    }]];
                    [actions addObject:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [JPProgressHUD show];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [WLRecordModelTool removeModel:recordingModel];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [JPProgressHUD showSuccessWithStatus:@"已删除" userInteractionEnabled:YES];
                            });
                        });
                    }]];
                    [JPAlertControllerTool alertControllerWithStyle:UIAlertControllerStyleAlert title:@"录制视频生成错误" message:nil actions:actions targetController:WLTabBarCtr];
                });
                break;
            }
        }
        return YES;
    } mergeProgressBlock:^(float progress) {
        [JPProgressHUD showProgress:progress status:[NSString stringWithFormat:@"已生成%.0lf%%", progress * 100]];
    } mergeCompleteBlock:^(WLRecordModel *kModel, NSString *path) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];
            
            WLRecordViewController *recordVC = [WLRecordViewController recordViewControllerWithRecordModel:kModel];
            JPLiveModuleNavigationController *navCtr = [JPLiveModuleNavigationController liveModuleNavigationControllerWithTransitionDelegate:nil rootViewController:recordVC];
            navCtr.isPushingLandscapeVC = NO;
            [WLTabBarCtr presentViewController:navCtr animated:YES completion:nil];
        });
    }];
    
}

- (void)testRecord {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        [JPProgressHUD show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self testRecord];
        });
        return;
    }

//    [WLRecordModelTool removeRecordDoneModels];
//    return;

#pragma mark 1.先检查有没正在录制的

    WLRecordModel *recordingModel = [WLRecordModelTool getRecordingModel];
    if (recordingModel) {
        unsigned long long fileSize = [JPFileTool calculateFolderSize:[WLRecordModel videoDotPath:YES]];

        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];

            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"重新录制" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [JPProgressHUD show];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                    [WLRecordModelTool removeModel:recordingModel];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [JPProgressHUD dismiss];

                        WLRecordViewController *recordVC = [WLRecordViewController recordViewControllerWithRecordModel:nil];
                        JPLiveModuleNavigationController *navCtr = [JPLiveModuleNavigationController liveModuleNavigationControllerWithTransitionDelegate:nil rootViewController:recordVC];
                        navCtr.isPushingLandscapeVC = NO;
                        [WLTabBarCtr presentViewController:navCtr animated:YES completion:nil];
                    });
                });
            }];

            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"继续录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [JPProgressHUD show];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self keepRecord:recordingModel];
                });
            }];

            UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"拿去发布" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                JPLog(@"还需合并转移");

                [JPProgressHUD show];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self keepRecord:recordingModel];
                });
            }];

            UIAlertAction *action4 = [self albumAction];

            [JPAlertControllerTool alertControllerWithStyle:UIAlertControllerStyleAlert title:@"是否继续录制" message:[NSString stringWithFormat:@"%@", JPFileSizeString(fileSize)] actions:@[action1, action2, action3, action4] targetController:WLTabBarCtr];

        });
    } else {

        unsigned long long fileSize = [JPFileTool calculateFolderSize:[WLRecordModel videoDotPath:NO]];
        NSArray *models = [WLRecordModelTool getRecordDoneModels];

        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];

            NSMutableArray *actions = [NSMutableArray array];

            if (models.count) {

                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"去媒体库选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                    WLRecordListViewController *recordListVC = [[WLRecordListViewController alloc] init];
                    [(UINavigationController *)WLTabBarCtr.selectedViewController pushViewController:recordListVC animated:YES];
                }];

                [actions addObject:action1];
            }


            [actions addObject:[UIAlertAction actionWithTitle:(models.count ? @"去录制新的" : @"去录制") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                WLRecordViewController *recordVC = [WLRecordViewController recordViewControllerWithRecordModel:nil];
                JPLiveModuleNavigationController *navCtr = [JPLiveModuleNavigationController liveModuleNavigationControllerWithTransitionDelegate:nil rootViewController:recordVC];
                navCtr.isPushingLandscapeVC = NO;
                [WLTabBarCtr presentViewController:navCtr animated:YES completion:nil];
            }]];


            [actions addObject:[self albumAction]];

            [JPAlertControllerTool alertControllerWithStyle:UIAlertControllerStyleAlert title:(models.count ? @"媒体库有保存好的" : nil) message:(models.count ? [NSString stringWithFormat:@"总共有%@", JPFileSizeString(fileSize)] : nil) actions:actions targetController:WLTabBarCtr];

        });

    }
}



- (void)choose:(WLPushType)pushType {
    if (pushType != WLPushType_MobilePush) {
#warning jp_ceshi
        [self testRecord];
        return;
    }
    
    if (!WLAccount) {
        [JPProgressHUD showInfoWithStatus:@"请先登录" userInteractionEnabled:YES];
        [self closePlus];
        return;
    }
    
    if (WLGlobalDataInstance.isCheckingCurrentLive) {
        [JPProgressHUD showInfoWithStatus:@"正在获取直播间信息，请稍等" userInteractionEnabled:YES];
        return;
    }
    
    if (WLGlobalDataInstance.isCheckingCertification) {
        [JPProgressHUD showInfoWithStatus:@"正在获取认证信息，请稍等" userInteractionEnabled:YES];
        return;
    }
    
    _networkStatus = nil;
    self.pushType = pushType;
    
    JPKeyWindow.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JPKeyWindow.userInteractionEnabled = YES;
        if (self.networkStatus) [JPProgressHUD showWithStatus:self.networkStatus];
    });
    
    if (WLGlobalDataInstance.isAssistDirector) {
        // 直接下一步
        [self checkCurrentLive:NO];
        return;
    }
    
    WLAccountCertificationModel *certificationModel = WLGlobalDataInstance.certificationModel;
    if (certificationModel) {
        if (certificationModel.status == WLAccountCertificationStatus_Passed) {
            // 已经认证，下一步
            [self checkCurrentLive:YES];
        } else if (certificationModel.status == WLAccountCertificationStatus_Failed) {
            // 认证失败，去认证
            [self goToCertificationWithTitle:certificationModel.refuseCause message:@"请重新认证"];
        } else {
            // 获取最新状态，再下一步
            [self checkCertificationStatus];
        }
    } else {
        // 没有认证，去认证
        [self goToCertificationWithTitle:@"通过实名认证后即可使用直播功能" message:@"通过认证即送价值1000元1小时直播时长"];
    }
}

#pragma mark 验证认证信息

- (void)checkCertificationStatus {
    self.networkStatus = @"正在获取认证信息，请稍等";
    @jp_weakify(self);
    [WLGlobalDataInstance queryCertificationWithSuccess:^{
        @jp_strongify(self);
        if (!self) return;
        WLAccountCertificationModel *certificationModel = WLGlobalDataInstance.certificationModel;
        if (certificationModel) {
            if (certificationModel.status == WLAccountCertificationStatus_Passed) {
                // 已经认证，下一步
                [self checkCurrentLive:YES];
            } else if (certificationModel.status == WLAccountCertificationStatus_Failed) {
                // 认证失败，去认证
                [self goToCertificationWithTitle:certificationModel.refuseCause message:@"请重新认证"];
            } else {
                self.networkStatus = nil;
                [JPProgressHUD showInfoWithStatus:@"认证正在审核中" userInteractionEnabled:YES];
            }
        } else {
            // 没有认证，去认证
            [self goToCertificationWithTitle:@"通过实名认证后即可使用直播功能" message:@"通过认证即送价值1000元1小时直播时长"];
        }
    } failure:^{
        @jp_strongify(self);
        if (!self) return;
        self.networkStatus = nil;
        [JPProgressHUD showErrorWithStatus:@"网络异常，获取信息失败" userInteractionEnabled:YES];
    }];
}

- (void)goToCertificationWithTitle:(NSString *)title message:(NSString *)message {
    self.networkStatus = nil;
    [JPProgressHUD dismiss];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"前往认证" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WLAuthenticationChooseViewController *acVC = [[WLAuthenticationChooseViewController alloc] init];
        UIViewController *selectedViewController = WLTabBarCtr.selectedViewController;
        if ([selectedViewController isKindOfClass:UINavigationController.class]) {
            [(UINavigationController *)selectedViewController pushViewController:acVC animated:YES];
        } else {
            [selectedViewController.navigationController pushViewController:acVC animated:YES];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self closePlus:NO];
        });
    }];
    [alert addAction:action];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [WLTabBarCtr presentViewController:alert animated:YES completion:nil];
}

- (void)goToGiveMoney {
    self.networkStatus = nil;
    [JPProgressHUD dismiss];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您录播的时长已经超过服务时长" message:@"请商务洽谈" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
    [WLTabBarCtr presentViewController:alert animated:YES completion:nil];
}

#pragma mark 验证当前直播

- (void)checkCurrentLive:(BOOL)isCheckLeftDuration {
    @jp_weakify(self);
    
    if (isCheckLeftDuration) {
        // 先查询剩余时间
        self.networkStatus = @"正在获取录播剩余时长，请稍等";
        [JPSessionManager requestWoliveTypeDataWithSuffixURLStr:@"charge/permission" parameter:nil successHandler:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
            @jp_strongify(self);
            if (!self) return;
            if (![responseObject[@"status"] isEqualToString:@"0"]) {
                NSString *message = responseObject[@"message"];
                if (!message.length) message = @"服务器异常，请重试";
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.networkStatus = nil;
                    [JPProgressHUD showErrorWithStatus:message userInteractionEnabled:YES];
                });
                return;
            }
            NSDictionary *permission = responseObject[@"permission"];
            NSInteger totalDuration = [permission[@"totalDuration"] integerValue];
            NSInteger currentDuration = [permission[@"currentDuration"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (totalDuration <= currentDuration) {
                    // 去升级时长
                    [self goToGiveMoney];
                } else {
                    // 下一步
                    [self checkCurrentLive:NO];
                }
            });
        } failureHandler:^(NSURLSessionDataTask *task, NSError *error, BOOL isCancelMyself) {
            @jp_strongify(self);
            if (!self) return;
            self.networkStatus = nil;
            [JPProgressHUD showErrorWithStatus:@"网络异常，获取信息失败" userInteractionEnabled:YES];
        }];
        return;
    }
    
    self.networkStatus = @"正在获取直播间信息，请稍等";
    [WLGlobalDataInstance queryCurrentLiveWithSuccess:^{
        @jp_strongify(self);
        if (!self) return;
        self.networkStatus = nil;
        [JPProgressHUD dismiss];
        if (WLGlobalDataInstance.liveModel) {
            @jp_weakify(self);
            [WLGlobalDataInstance showCurrentLiveAlertWithGoToLiveBlock:^{
                @jp_strongify(self);
                if (!self) return;
                [self startToLive];
            }];
        } else {
            [self startToLive];
        }
    } failure:^{
        @jp_strongify(self);
        if (!self) return;
        self.networkStatus = nil;
        [JPProgressHUD showErrorWithStatus:@"网络异常，获取信息失败" userInteractionEnabled:YES];
    }];
}

- (void)startToLive {
    JPLiveModuleNavigationController *navCtr;
    WLLiveModel *liveModel = WLGlobalDataInstance.liveModel;
    if (liveModel) {
        self.pushType = liveModel.pushType;
        navCtr = [JPLiveModuleNavigationController livePushNavigationControllerWithTransitionDelegate:self liveModel:liveModel];
    } else {
        navCtr = [JPLiveModuleNavigationController settingNavigationControllerWithTransitionDelegate:self pushType:self.pushType];
    }
    [WLTabBarCtr presentViewController:navCtr animated:YES completion:nil];
}

#pragma mark - <JPLiveModuleTransitionDelegate>

- (UIImageView *)setupManufacturerIconWithIsPresent:(BOOL)isPresent {
    if (isPresent) {
        switch (self.pushType) {
            case WLPushType_MobilePush:
                return (UIImageView *)self.mobileView;
            case WLPushType_EquipmentPush:
                return (UIImageView *)self.equipmentView;
            case WLPushType_VR_EquipmentPush:
                return (UIImageView *)self.vrEquipmentView;
        }
    } else {
        return (UIImageView *)self.plusView;
    }
}

- (void)startTransitionWithIsPresent:(BOOL)isPresent {
    if (isPresent) {
        JPBounceView *iconView;
        switch (self.pushType) {
            case WLPushType_MobilePush:
                iconView = self.mobileView;
                break;
            case WLPushType_EquipmentPush:
                iconView = self.equipmentView;
                break;
            case WLPushType_VR_EquipmentPush:
                iconView = self.vrEquipmentView;
                break;
        }
        iconView.hidden = YES;
    } else {
        self.plusView.hidden = YES;
    }
    
    if (isPresent) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            WLTabBarCtr.view.transform = CGAffineTransformScale(WLTabBarCtr.view.transform, 1.2, 1.2);
        } completion:nil];
    } else {
        WLTabBarCtr.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            WLTabBarCtr.view.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
    }
    
    AudioServicesPlaySystemSound((isPresent ? 1397 : 1396));
}

- (NSTimeInterval)finishTransitionWithIsPresent:(BOOL)isPresent {
    [WLTabBarCtr.view.layer removeAllAnimations];
    WLTabBarCtr.view.transform = CGAffineTransformIdentity;
    
    self.plusView.hidden = NO;
    NSTimeInterval delay = 0.0;
    if (isPresent) {
        [self closePlus:NO];
    } else {
        self.plusView.alpha = 0;
        delay = 0.25;
        [UIView animateWithDuration:delay animations:^{
            self.plusView.alpha = 1;
        }];
    }
    return delay;
}

@end





@interface WLTabBarItem ()
@property (nonatomic, weak) JPImageView *normalIconView;
@property (nonatomic, weak) JPImageView *selectIconView;
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation WLTabBarItem

- (instancetype)initWithFrame:(CGRect)frame
                      childVC:(UIViewController *)childVC
                        title:(NSString *)title
                        index:(NSInteger)index
                   normalIcon:(NSString *)normalIcon
                   selectIcon:(NSString *)selectIcon {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        
        self.scale = 1.17;
        self.scaleDuration = 0.2;
        self.recoverBounciness = 15;
        
        CGRect iconFrame = CGRectMake(JPScaleValue(25), 6, 20, 20);
        
        JPImageView *normalIconView = [[JPImageView alloc] initWithFrame:iconFrame];
        normalIconView.image = [UIImage imageNamed:normalIcon];
        [self addSubview:normalIconView];
        self.normalIconView = normalIconView;
        
        JPImageView *selectIconView = [[JPImageView alloc] initWithFrame:iconFrame];
        selectIconView.image = [UIImage imageNamed:selectIcon];
        [self addSubview:selectIconView];
        self.selectIconView = selectIconView;
        
        UILabel *titleLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:10];
            aLabel.text = title;
            aLabel.frame = CGRectMake(0, selectIconView.jp_maxY + 4, frame.size.width, 14);
            aLabel;
        });
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        CGFloat iconMidY = CGRectGetMidY(iconFrame);
        CGFloat diffY = frame.size.height * 0.5 - iconMidY;
        self.layer.anchorPoint = CGPointMake(0.5, (iconMidY / frame.size.height));
        self.layer.jp_positionY -= diffY;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    [self setIsSelected:isSelected animated:NO];
}

- (void)setIsSelected:(BOOL)isSelected animated:(BOOL)animated {
    _isSelected = isSelected;
    CGFloat normalIconViewAlpha = isSelected ? 0.0 : 1.0;
    CGFloat selectIconViewAlpha = isSelected ? 1.0 : 0.0;
    UIColor *titleLabelColor = isSelected ? JPRGBColor(29, 121, 255) : JPRGBColor(115, 122, 135);
    if (animated) {
        NSTimeInterval duration = isSelected ? 0.2 : 0.1;
        [self.normalIconView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@(normalIconViewAlpha) duration:duration];
        [self.selectIconView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@(selectIconViewAlpha) duration:duration];
        [self.titleLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPLabelTextColor toValue:titleLabelColor duration:duration];
    } else {
        self.normalIconView.alpha = normalIconViewAlpha;
        self.selectIconView.alpha = selectIconViewAlpha;
        self.titleLabel.textColor = titleLabelColor;
    }
}

- (void)setIsHasBadge:(BOOL)isHasBadge {
    [self setIsHasBadge:isHasBadge animated:NO];
}

- (void)setIsHasBadge:(BOOL)isHasBadge animated:(BOOL)animated {
    _isHasBadge = isHasBadge;
}

@end
