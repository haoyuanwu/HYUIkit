//
//  HYPageScrollView.h
//  HYPageScollView
//
//  Created by wuhaoyuan on 15/12/15.
//  Copyright © 2015年 pageScollView. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HYPageScrollViewDelegate <NSObject>

- (void)touchesButton:(NSInteger)index;

@end

@interface HYPageScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,strong) id<HYPageScrollViewDelegate> delegateHy;

@property (nonatomic,strong) NSArray *titleArray;

@property (nonatomic,assign) NSInteger eachRowNumber;

@property (nonatomic,strong) UIColor *tintColor;

@property (nonatomic,strong) UIFont *buttonFont;

@property (nonatomic,assign) BOOL buttonAdjustsFontSizeToFitWidth;

@property (nonatomic,strong) UIView *sliderView;

@end
