//
//  JPConstant.h
//  Infinitee2.0
//
//  Created by 周健平 on 2017/9/24.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JPScale [JPConstant UIBasisWidthScale]
#define JPHScale [JPConstant UIBasisHeightScale]

@interface JPConstant : NSObject
+ (CGFloat)UIBasisWidthScale;
+ (CGFloat)UIBasisHeightScale;
@end

#pragma mark - 宏

#define JPRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define JPRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define JPRandomColor JPRGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define JPRandomAColor(a) JPRGBAColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), a)

#pragma mark - 内联函数

/**
 * 获取当前页码
 */
CG_INLINE NSInteger JPGetCurrentPageNumber(CGFloat offsetValue, CGFloat pageSizeValue) {
    return (NSInteger)((offsetValue + pageSizeValue * 0.5) / pageSizeValue);
}

/**
 * 弧度 --> 角度（ π --> 180° ）
 */
CG_INLINE CGFloat JPRadian2Angle(CGFloat radian) {
    return (radian * 180.0) / M_PI;
}

/**
 * 角度 --> 弧度（ 180° -->  π  ）
 */
CG_INLINE CGFloat JPAngle2Radian(CGFloat angle) {
    return (angle / 180.0) * M_PI;
}

/**
 * 随机整数（from <= number <= to）
 */
CG_INLINE NSInteger JPRandomNumber(NSInteger from, NSInteger to) {
    return (NSInteger)(from + (arc4random() % (to - from + 1)));
}

/**
 * 随机布尔值（YES or NO）
 */
CG_INLINE BOOL JPRandomBool(void) {
    return JPRandomNumber(0, 1);
}

/**
 * 随机比例值（0.0 ~ 1.0）
 */
CG_INLINE CGFloat JPRandomUnsignedScale(void) {
    return JPRandomNumber(0, 100) * 1.0 / 100.0;
}

/**
 * 随机比例值（-1.0 ~ 1.0）
 */
CG_INLINE CGFloat JPRandomScale(void) {
    return (JPRandomBool() ? 1.0 : -1.0) * JPRandomUnsignedScale();
}

/**
 * 随机小写字母（a ~ z）
 */
CG_INLINE NSString * JPRandomLowercaseLetters(void) {
    char data[1];
    data[0] = (char)('a' + JPRandomNumber(0, 25));
    return [[NSString alloc] initWithBytes:data length:1 encoding:NSUTF8StringEncoding];
}

/**
 * 随机大写字母（A ~ Z）
 */
CG_INLINE NSString * JPRandomCapitalLetter(void) {
    char data[1];
    data[0] = (char)('A' + JPRandomNumber(0, 25));
    return [[NSString alloc] initWithBytes:data length:1 encoding:NSUTF8StringEncoding];
}

CG_INLINE CGFloat JPFromSourceToTargetValueByDifferValue(CGFloat sourceValue, CGFloat differValue, CGFloat progress) {
    return sourceValue + progress * differValue;
}

CG_INLINE CGFloat JPFromSourceToTargetValue(CGFloat sourceValue, CGFloat targetValue, CGFloat progress) {
    return JPFromSourceToTargetValueByDifferValue(sourceValue, (targetValue - sourceValue), progress);
}

CG_INLINE CGFloat JPHalfOfDiff(CGFloat value1, CGFloat value2) {
    return (value1 - value2) * 0.5;
}

CG_INLINE CGFloat JPScaleValue(CGFloat value) {
    return value * JPScale;
}

CG_INLINE CGFloat JPHScaleValue(CGFloat value) {
    return value * JPHScale;
}

CG_INLINE UIFont * JPScaleFont(CGFloat fontSize)  {
    return [UIFont systemFontOfSize:JPScaleValue(fontSize)];
}

CG_INLINE UIFont * JPScaleBoldFont(CGFloat fontSize) {
    return [UIFont boldSystemFontOfSize:JPScaleValue(fontSize)];
}

/**
 * 判断两个字符串是否相等（两个都为 nil 也算相等）
 */
CG_INLINE BOOL JPStringEqual(NSString *a, NSString *b) {
    return (a == b) || [a isEqualToString:b];
}
