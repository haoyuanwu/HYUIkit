//
//  UIImage+alpha.h
//  Component
//
//  Created by Chance on 15/7/14.
//  Copyright (c) 2015年 济南掌游. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (details)

/**
 base64解码
 
 @param string base64编码的流字符串
 
 */
+ (UIImage *)imageWithBase64String:(NSString *)string;

/// 截取图片
/// @param rect 要截取的区域
//- (UIImage *)imageFromImageinRect:(CGRect)rect;

/**
 将view包含subviews所呈现的视图转换成image,非view包含的内容不被转换,默认倍率为屏幕倍率

 @param view 需要转换的视图
 @return 生成的image
 */
+ (UIImage *)imageByConvertView:(UIView *)view;

/**
 将view包含subviews所呈现的视图转换成image,非view包含的内容不被转换

 @param view 需要转换的视图
 @param size 根据view的原点,设置要生成image的区域,如果超出将由 isOpaque参数控制超出部分是否透明
 @param isOpaque 设置生成的image背景是否不透明, YES不透明, NO透明
 @param scale 生成的视图倍率,按size的1比1像素为基准,如size(300,300),scale为2, 则生成image大小为600像素x600像素
 @return 生成的image
 */
+ (UIImage *)imageByConvertView:(UIView *)view relativeOriginSize:(CGSize)size opaque:(BOOL)isOpaque scale:(CGFloat)scale;

/**
 *  改变UIImage颜色（必须为纯色）
 */
- (UIImage *) imageWithTintColor:(UIColor *)tintColor alpha:(CGFloat)alpha;

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha;

/**
 *  改变image的方向（拍照之后）
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

/**
 *  图片压缩
 *
 *  @param sourceImage 图片
 *  @param defineWidth 压缩宽度
 *
 */
+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

/*
 * @brief rotate image 90 withClockWise
 */
- (UIImage*)rotate90Clockwise;

/*
 * @brief rotate image 90 counterClockwise
 */
- (UIImage*)rotate90CounterClockwise;

/*
 * @brief rotate image 180 degree
 */
- (UIImage*)rotate180;

/*
 * @brief rotate image to default orientation
 */
- (UIImage*)rotateImageToOrientationUp;

/*
 * @brief flip horizontal
 */
- (UIImage*)flipHorizontal;

/*
 * @brief flip vertical
 */
- (UIImage*)flipVertical;

/*
 * @brief flip horizontal and vertical
 */
- (UIImage*)flipAll;

/**
 生成颜色图片
 
 @param color 颜色
 @param height 高度
 @return 图片
 */
- (UIImage*) imageWithColor:(UIColor*)color andHeight:(CGFloat)height;

/**
 返回一张不超过屏幕大小的图片
 */
+ (UIImage *)imageSizeWithScreenImage:(UIImage *)image;


///调整图片分辨率/尺寸（等比例缩放）
+ (UIImage *)newSizeImage:(CGSize)size image:(UIImage *)sourceImage;


/// 压缩图片
/// @param image 图片
/// @param maxLength 压缩到最大范围
+ (NSData *)compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength;
@end
