//
//  QRView.m
//  HYQRCodeView
//
//  Created by 吴昊原 on 2017/7/3.
//  Copyright © 2017年 HYQRCodeView. All rights reserved.
//

#import "QRView.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface QRView ()
{
    NSTimer *timer;
    UIImageView *lineImg;
    CGRect rect;
}
@end

@implementation QRView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(self.frame.size.width/4, self.frame.size.height/2-self.frame.size.width/4, self.frame.size.width/2, self.frame.size.width/2)];
//
//        CAShapeLayer *layer = [CAShapeLayer layer];
//        //填充颜色
//        layer.fillColor = [UIColor clearColor].CGColor;
//        //边框颜色
//        layer.strokeColor = [UIColor blackColor].CGColor;
//        layer.path = path.CGPath;
//        [self.layer addSublayer:layer];
//
//        CALayer *layer = [CALayer layer];
//        layer.frame = CGRectMake(self.frame.size.width/4, frame.size.height/2 - frame.size.width/4, self.frame.size.width/2, self.frame.size.width/2);
//        [self.layer addSublayer:layer];
//
        self.isStop = YES;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self addSubview:bgView];
        
        UIBlurEffect *blurForHeadImage = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        /** 创建UIVisualEffectView的对象visualView, 以blur为参数. */
        UIVisualEffectView *HeadImage = [[UIVisualEffectView alloc] initWithEffect:blurForHeadImage];
        /** 将visualView的大小等于头视图的大小. (visualView的大小可以自行设定, 它的大小决定了显示毛玻璃效果区域的大小.) */
        HeadImage.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        // 透明度
        HeadImage.alpha = 0.8;
        /** 将visualView添加到blurImageView上. */
        [bgView addSubview:HeadImage];

        rect = CGRectMake(self.frame.size.width/6, self.frame.size.height/2 - self.frame.size.width/3, self.frame.size.width*2/3, self.frame.size.width*2/3);

        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];

        [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0] bezierPathByReversingPath]];

        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        [bgView.layer setMask:shapeLayer];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self addSubview:view];
        
        
        UIImageView *topLeftImg = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, 20, 20)];
        topLeftImg.contentMode = UIViewContentModeScaleAspectFit;
        topLeftImg.image = [UIImage imageNamed:@"QRCodeLeftTop"];
        [view addSubview:topLeftImg];
        
        UIImageView *topRightImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rect) - 20, rect.origin.y, 20, 20)];
        topRightImg.contentMode = UIViewContentModeScaleAspectFit;
        
        topRightImg.image = [UIImage imageNamed:@"QRCodeRightTop"];
        [view addSubview:topRightImg];
        
        UIImageView *bottomLeftImg = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, CGRectGetMaxY(rect)-20, 20, 20)];
        bottomLeftImg.contentMode = UIViewContentModeScaleAspectFit;
        
        bottomLeftImg.image = [UIImage imageNamed:@"QRCodeLeftBottom"];
        [view addSubview:bottomLeftImg];
        
        UIImageView *bottomRightImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rect) - 20, CGRectGetMaxY(rect)-20, 20, 20)];
        bottomRightImg.contentMode = UIViewContentModeScaleAspectFit;
        
        bottomRightImg.image = [UIImage imageNamed:@"QRCodeRightBottom"];
        [view addSubview:bottomRightImg];
        
        lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 10)];
//        lineImg.contentMode = UIViewContentModeScaleAspectFit;
//        NSString *strResourcesBundle = [[NSBundle mainBundle] pathForResource:@"HYUIKitImage" ofType:@"bundle"];
//        NSString *strC = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"actionbar_audio_call_icon" ofType:@"png" inDirectory:@"voip"];
//        NSString *strC = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"QRCodeScanningLine" ofType:@"png"];
        lineImg.image = [UIImage imageNamed:@"QRCodeScanningLine"];
        [view addSubview:lineImg];

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        });
        __weak typeof (self)wself = self;
        timer = [NSTimer scheduledTimerWithTimeInterval:4 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [wself lineMobile];
        }];
        [timer fire];
        
        UIButton *lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        lightBtn.frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - 80, rect.size.width, 80);
        lightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//        [lightBtn setTitle:@"打开照明" forState:(UIControlStateNormal)];
//        [lightBtn setTitle:@"关闭照明" forState:UIControlStateSelected];
        [lightBtn setImage:[UIImage imageNamed:@"Light_close"] forState:UIControlStateNormal];
        [lightBtn setImage:[UIImage imageNamed:@"Light_open"] forState:UIControlStateSelected];
        [lightBtn addTarget:self action:@selector(offAndNoLight:) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:lightBtn];
        
        self.messageLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(rect) - 40, SCREEN_WIDTH, 30)];
        self.messageLab.textColor = UIColor.whiteColor;
        self.messageLab.textAlignment = NSTextAlignmentCenter;
        self.messageLab.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.messageLab];
    }
    return self;
}

- (void)offAndNoLight:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.block) {
        self.block(sender);
    }
}

- (void)lineMobile{
    [UIView animateWithDuration:2 animations:^{
        self->lineImg.transform = CGAffineTransformMakeTranslation(0, rect.size.height-10);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2 animations:^{
            self->lineImg.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
//            if (!self.isStop) {
//                [self lineMobile];
//            }
        }];
    }];
}

- (void)setIsStop:(BOOL)isStop{
    _isStop = isStop;
    if (!isStop) {
        if (!timer) {
            [self lineMobile];
        }else{
            [timer fire];
        }
    }
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
