//
//  TextView.h
//  TextUIViewLayer
//
//  Created by wuhaoyuan on 15/7/29.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  百分比饼图
 */
@interface PieView : UIView

//一个圆多个扇形  需要给出endArrayCount最后角度的数组
- (void)customViewCenter:(CGPoint *)point withViewColorArray:(NSArray *)colorArr andStartAngle:(CGFloat)startAngle andEndAngle:(CGFloat)endAngle andRadius:(CGFloat)radius;

//一个圆一个扇形
- (void)customViewCenter:(CGPoint *)point withViewColor:(UIColor *)color andStartAngle:(CGFloat)startAngle andEndAngle:(CGFloat)endAngle andRadius:(CGFloat)radius;

/**
 *  如果你要画多个扇形 把扇形的角度下文存到数组里
 */
@property(nonatomic,strong)NSArray *endArrayCount;

/**
 *  笔画的颜色
 */
- (void)strokeColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end
