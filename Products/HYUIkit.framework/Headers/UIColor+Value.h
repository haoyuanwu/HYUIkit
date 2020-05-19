//
//  UIColor+Value.h
//  HYUIkit
//
//  Created by wuhaoyuan on 2016/12/2.
//  Copyright © 2016年 wuhaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Value)

/**
 根据色值获取颜色

 @param color 色值
 */
+ (UIColor *)colorWithHexString:(NSString *)color;

/**
 根据色值透明度获取颜色

 @param color 色值
 @param alpha 透明度
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
