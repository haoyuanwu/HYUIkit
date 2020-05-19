
//
//  TextView.m
//  TextUIViewLayer
//
//  Created by wuhaoyuan on 15/7/29.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "PieView.h"

@interface PieView ()
{
    NSArray *_colorArr;
    CGFloat X;
    CGFloat Y;
    CGFloat start;
    CGFloat end;
    CGFloat Radius;
    UIColor *_color;
    BOOL pluralbool;
    
    CGFloat _red;
    CGFloat _green;
    CGFloat _blue;
    CGFloat _alpha;
}

@end

@implementation PieView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    //An opaque type that represents a Quartz 2D drawing environment.
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    
    if (pluralbool == NO) {
        CGContextRef context = UIGraphicsGetCurrentContext();

        for (int i = 0 ; i< _endArrayCount.count;i++) {
            /*画扇形和椭圆*/
            // 画扇形，也就画圆，只不过是设置角度的大小，形成一个扇形
            CGContextSetRGBStrokeColor(context, _red, _green, _blue, _alpha);
            CGContextSetFillColorWithColor(context, ((UIColor *)_colorArr[i]).CGColor);//填充颜色
            end = [self.endArrayCount[i] floatValue];
            //以10为半径围绕圆心画指定角度扇形
            CGContextMoveToPoint(context, X,Y);
            CGContextAddArc(context, X, Y, Radius/* 半径*/,  start * M_PI / 180, end * M_PI / 180, 0);
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
            start = end;
        }
    }else{
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetRGBStrokeColor(context, _red, _green, _blue, _alpha);
        CGContextSetFillColorWithColor(context, _color.CGColor);//填充颜色
        //以10为半径围绕圆心画指定角度扇形
        CGContextMoveToPoint(context, X,Y);
        CGContextAddArc(context, X, Y, Radius/* 半径*/,  start * M_PI / 180, end * M_PI / 180, 0);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
    }

}

- (void)customViewCenter:(CGPoint *)point withViewColorArray:(NSArray *)colorArr andStartAngle:(CGFloat)startAngle andEndAngle:(CGFloat)endAngle andRadius:(CGFloat)radius{
    pluralbool = NO;
    self->_colorArr = colorArr;
    self->X = point->x;
    self->Y = point->y;
    self->start = startAngle;
    self->end = endAngle;
    self->Radius = radius;
}

- (void)customViewCenter:(CGPoint *)point withViewColor:(UIColor *)color andStartAngle:(CGFloat)startAngle andEndAngle:(CGFloat)endAngle andRadius:(CGFloat)radius{
    pluralbool = YES;
    self->_color = color;
    self->X = point->x;
    self->Y = point->y;
    self->start = startAngle;
    self->end = endAngle;
    self->Radius = radius;
}

- (void)strokeColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha{
    self->_red = red;
    self->_green = green;
    self->_blue = green;
    self->_alpha = alpha;
}


@end
