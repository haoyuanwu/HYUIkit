//
//  HYPageViewController.h
//  HYPageScollView
//
//  Created by wuhaoyuan on 15/12/16.
//  Copyright © 2015年 pageScollView. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPageScrollView.h"

/**
 *  滑动标签试图控制器
 */
@interface HYPageViewController : UIViewController

/**
 *  控制器数组(标签名是控制的title)
 */
@property (nonatomic,strong) NSArray *viewControllers;

/**
 *  标签栏
 */
@property (nonatomic,strong) HYPageScrollView *scrollViewbar;

/**
 *  每页显示多少个标签(默认是3个)
 */
@property (nonatomic,assign) NSInteger eachRowNumber;

/**
 *  标签和滑块颜色(默认黑色)
 */
@property (nonatomic,strong) UIColor *tintColor;

/**
 *  标签的字体大小(默认17)
 */
@property (nonatomic,strong) UIFont *buttonFont;

/**
 *  按标签大小自动适应文字大小(默认关闭)
 */
@property (nonatomic,assign) BOOL buttonAdjustsFontSizeToFitWidth;

/**
 *  只是器滑块
 */
@property (nonatomic,strong) UIView *sliderView;

@end
