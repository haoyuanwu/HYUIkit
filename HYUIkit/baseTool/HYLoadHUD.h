//
//  HYLoadHUD.h
//  HYLoadHUD
//
//  Created by 吴昊原 on 2018/7/24.
//  Copyright © 2018 吴昊原. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYLoadHUD : NSObject

+ (instancetype)shareInstance;

+ (void)showLoading;

+ (void)hiddenLoading;

+ (void)showLoadingFromView:(UIView *)view;

+ (void)showLoadingFromView:(UIView *)view message:(NSString *)message;

@end
