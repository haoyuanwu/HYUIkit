//
//  GuidePageView.h
//  HYGuidePage
//
//  Created by wuhaoyuan on 15/12/22.
//  Copyright © 2015年 HYGuidePage. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  引导页（淡入淡出效果）
 */
@interface GuidePageView : UIView

@property (nonatomic,strong) NSArray *guidePageArr;

@property (nonatomic,strong) UIPageControl *pageControl;
@end
