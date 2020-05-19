//
//  CameraDetailsView.m
//  HYUIkit
//
//  Created by 吴昊原 on 2020/4/23.
//  Copyright © 2020 wuhaoyuan. All rights reserved.
//

#import "CameraDetailsView.h"
#import <HYUIkit/HYUIkit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface CameraDetailsView ()<UIScrollViewDelegate>

/** 旋转缩放参考点 */
@property (nonatomic, assign) CGPoint originalPoint;
/** 视图初始化宽高 */
@property (nonatomic, assign) CGFloat originalWidth;
@property (nonatomic, assign) CGFloat originalHeight;

@end

@implementation CameraDetailsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.blackColor;
        self.originalPoint = self.center;
        self.originalWidth = self.imageView.width;
        self.originalHeight = self.imageView.height;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        
//        self.undoBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        self.undoBtn.frame = CGRectMake(SCREEN_WIDTH/4-15, SCREEN_HEIGHT-200, 40, 40);
//        UIImage *undoImg = [UIImage imageNamed:@"image.bundle/undo"
//        inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
//        [self.undoBtn setImage:undoImg forState:(UIControlStateNormal)];
//        self.undoBtn.layer.shadowColor = UIColor.grayColor.CGColor;
//        self.undoBtn.layer.shadowOffset = CGSizeMake(2, 4);
//        self.undoBtn.layer.shadowRadius = 10;
//        self.undoBtn.layer.shadowOpacity = 1;
//        [self.undoBtn addTarget:self action:@selector(undoImage) forControlEvents:(UIControlEventTouchUpInside)];
//        [self addSubview:self.undoBtn];
//
//        self.confirmBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        self.confirmBtn.frame = CGRectMake(SCREEN_WIDTH*3/4-15, SCREEN_HEIGHT-200, 40, 40);
//        UIImage *confirmImg = [UIImage imageNamed:@"image.bundle/confirm"
//        inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
//        [self.confirmBtn setImage:confirmImg forState:(UIControlStateNormal)];
//        [self.confirmBtn addTarget:self action:@selector(confirmImage:) forControlEvents:(UIControlEventTouchUpInside)];
//        self.confirmBtn.layer.shadowColor = UIColor.grayColor.CGColor;
//        self.confirmBtn.layer.shadowOffset = CGSizeMake(2, 4);
//        self.confirmBtn.layer.shadowRadius = 10;
//        self.confirmBtn.layer.shadowOpacity = 1;
//        [self addSubview:self.confirmBtn];
        
        [self setUserGesture];
    }
    return self;
}

- (void)setMaskCropRect:(CGRect)maskCropRect{
    _maskCropRect = maskCropRect;
}

-(void) setUserGesture
{
    [self.imageView setUserInteractionEnabled:YES];
    //添加移动手势
    UIPanGestureRecognizer *moveGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
    [moveGes setMinimumNumberOfTouches:1];
    [moveGes setMaximumNumberOfTouches:1];
    [self.imageView addGestureRecognizer:moveGes];
    //添加缩放手势
    UIPinchGestureRecognizer *scaleGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    [self.imageView addGestureRecognizer:scaleGes];
    //添加旋转手势
    UIRotationGestureRecognizer *rotateGes = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
    [self.imageView addGestureRecognizer:rotateGes];
}

float _lastTransX = 0.0, _lastTransY = 0.0;
- (void)moveImage:(UIPanGestureRecognizer *)sender
{
    //获取偏移量
//    // 返回的是相对于最原始的手指的偏移量
//    CGPoint transP = [sender translationInView:self.imageView];
//
//    // 移动图片控件
//    self.imageView.transform = CGAffineTransformTranslate(self.imageView.transform, transP.x, transP.y);
//
//    // 复位,表示相对上一次
//    [sender setTranslation:CGPointZero inView:self.imageView];
    CGPoint translatedPoint = [sender translationInView:self];

    if([sender state] == UIGestureRecognizerStateBegan) {
        _lastTransX = 0.0;
        _lastTransY = 0.0;
    }
    CGAffineTransform trans = CGAffineTransformMakeTranslation(translatedPoint.x - _lastTransX, translatedPoint.y - _lastTransY);
    CGAffineTransform newTransform = CGAffineTransformConcat(self.imageView.transform, trans);
    _lastTransX = translatedPoint.x;
    _lastTransY = translatedPoint.y;

    if ([self isCanMove:newTransform])
    {
         self.imageView.transform = newTransform;
    }
   
}

float _lastScale = 1.0;
- (void)scaleImage:(UIPinchGestureRecognizer *)sender
{
    if([sender state] == UIGestureRecognizerStateBegan) {
        
        _lastScale = 1.0;
        return;
    }
    
    CGFloat scale = [sender scale]/_lastScale;
    
    CGAffineTransform currentTransform = self.imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [self.imageView setTransform:newTransform];
    
    _lastScale = [sender scale];
}

float _lastRotation = 0.0;
- (void)rotateImage:(UIRotationGestureRecognizer *)sender
{
    if([sender state] == UIGestureRecognizerStateEnded) {
        
        _lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = -_lastRotation + [sender rotation];
    
    CGAffineTransform currentTransform = self.imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    [self.imageView setTransform:newTransform];
    
    _lastRotation = [sender rotation];
    
}


/***
 方法名称：isCanMove:
 方法用途：限制图片移动的区域
 方法说明：YES：可以移动，NO：不可以移动
 Author：Created by ztli on 14-11-27
 ***/
-(BOOL) isCanMove:(CGAffineTransform ) newTransform
{
    if (self.imageView.frame.size.height/2  - fabs(newTransform.ty)<=0 ||
        self.imageView.frame.size.width/2 - fabs(newTransform.tx)  <=0)
    {
        return NO;
        
    } else
    {
        return YES;
    }
}

- (void)undoImage{
    self.alpha = 0;
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

//- (void)confirmImage:(UIButton *)sender{
//    
//    if (self.confirmBlock) {
//        self.undoBtn.hidden = YES;
//        self.confirmBtn.hidden = YES;
//            // 通知主线程刷新 神马的
////            UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0);
////            [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
////            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
////            UIGraphicsEndImageContext();
//        
////            UIImage *image = [UIImage imageByConvertView:self relativeOriginSize:self.frame.size opaque:YES scale:0];
////            UIImage *newImage = [self imageFromImage:image inRect:self.maskcCropRect];
//        UIImage *newImage = self.disposeImageBlock(self, self.maskCropRect);
//        self.imageView.transform = CGAffineTransformIdentity;
//        self.imageView.image = newImage;
//        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        self.undoBtn.hidden = NO;
//        self.confirmBtn.hidden = NO;
//        self.confirmBlock(newImage);
//        self.alpha = 0;
//
////        CGImageRef ima = imag.CGImage;
////        UIImage *sendImag = [UIImage imageWithCGImage:ima];
////        UIImage *sendImag = [self imageByConvertView:self];
//        
//        
//    }
//}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
