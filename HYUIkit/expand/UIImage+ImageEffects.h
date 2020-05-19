//
//  UIImage+ImageEffects.h
//  HYHUD
//
//  Created by wuhaoyuan on 15/12/18.
//  Copyright © 2015年 HYHUD. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  给图片添加模糊效果
 */
@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
