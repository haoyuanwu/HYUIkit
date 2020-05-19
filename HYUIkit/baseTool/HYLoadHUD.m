//
//  HYLoadHUD.m
//  HYLoadHUD
//
//  Created by 吴昊原 on 2018/7/24.
//  Copyright © 2018 吴昊原. All rights reserved.
//

#import "HYLoadHUD.h"

@interface HYLoadHUD()

@property (nonatomic,strong)NSTimer *timerLayer;
@property (nonatomic,strong)NSTimer *timerView;
@property (nonatomic,strong)UIView *loadView;
@property (nonatomic,strong)UILabel *titleLabel;

@end

@implementation HYLoadHUD

+(instancetype) shareInstance
{
    static HYLoadHUD* _instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    });
    
    return _instance ;
}

-(UIView *)loadView{
    if (!_loadView) {
        _loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _loadView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        _loadView.layer.cornerRadius = 7;
        _loadView.layer.masksToBounds = YES;
        _loadView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//        backView.center = CGPointMake(_loadView.frame.size.width/2, _loadView.frame.size.height/2);
        [_loadView addSubview:backView];
        
    }
    return _loadView;
}

+ (void)showLoading{
    
    [[UIApplication sharedApplication].keyWindow addSubview:[HYLoadHUD shareInstance].loadView];
    
    UIView *view = [HYLoadHUD shareInstance].loadView.subviews[0];
    if (view.layer.sublayers.count == 0) {
        timerFire();
        RotationBackView();
    }
}

+ (void)hiddenLoading{
    
    [[HYLoadHUD shareInstance].timerLayer invalidate];
    [HYLoadHUD shareInstance].timerLayer = nil;
    [[HYLoadHUD shareInstance].timerView invalidate];
    [HYLoadHUD shareInstance].timerView = nil;
    [[HYLoadHUD shareInstance].loadView removeFromSuperview];
    [HYLoadHUD shareInstance].loadView = nil;
    
}

void RotationBackView() {
    
    UIView *view = [HYLoadHUD shareInstance].loadView.subviews[0];
    
    [UIView animateWithDuration:3 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^{
        view.transform = CGAffineTransformRotate(view.transform, 1*M_PI);
    } completion:^(BOOL finished) {
        if (view) {
            if (view.layer.sublayers.count != 0) {
                RotationBackView();
            }
        }
    }];
}

void timerFire(){
    
    UIView *view = [HYLoadHUD shareInstance].loadView.subviews[0];
    
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 3;
    //圆环的颜色
    layer.strokeColor = [UIColor whiteColor].CGColor;
    //背景填充色
    layer.fillColor = [UIColor clearColor].CGColor;
    //设置半径为10
    CGFloat radius = 20;
    //按照顺时针方向
    BOOL clockWise = true;
    layer.strokeStart = 0;
    layer.strokeEnd = 0;
    //初始化一个路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:view.center radius:radius startAngle:(-0.5*M_PI) endAngle:1.5*M_PI clockwise:clockWise];
    layer.path = [path CGPath];
    [view.layer addSublayer:layer];
    
    __block CGFloat value = 0;
    [HYLoadHUD shareInstance].timerLayer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        if (layer.strokeEnd >= 1) {
            layer.strokeStart = 0;
            if (value >= 1) {
                value = 0;
            }
            value += 0.1;
            layer.strokeStart = value;
            if (layer.strokeStart >= 1) {
                [timer invalidate];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [layer removeFromSuperlayer];
                    timerFire();
                });
            }
        }else{
            value += 0.1;
            layer.strokeEnd = value;
        }
    }];
}

+ (void)showLoadingFromView:(UIView *)view{
    
    [view addSubview:[HYLoadHUD shareInstance].loadView];
    
    UIView *bview = [HYLoadHUD shareInstance].loadView.subviews[0];
    if (bview.layer.sublayers.count == 0) {
        RotationBackView();
        timerFire();
    }
}

+ (void)showLoadingFromView:(UIView *)view message:(NSString *)message{
    
    [view addSubview:[HYLoadHUD shareInstance].loadView];
    UIView *bview = [HYLoadHUD shareInstance].loadView.subviews[0];
    UILabel *titleLabel = [HYLoadHUD shareInstance].titleLabel;
    
    if (bview.layer.sublayers.count == 0) {
        RotationBackView();
        timerFire();
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bview.frame.size.height-30, bview.frame.size.width, 30)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        
        [[HYLoadHUD shareInstance].loadView addSubview:titleLabel];
    }
    
    titleLabel.text = message;
    
}

@end
