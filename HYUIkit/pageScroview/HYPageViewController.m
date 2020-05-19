//
//  HYPageViewController.m
//  HYPageScollView
//
//  Created by wuhaoyuan on 15/12/16.
//  Copyright © 2015年 pageScollView. All rights reserved.
//

#import "HYPageViewController.h"

@interface HYPageViewController ()<UIScrollViewDelegate,HYPageScrollViewDelegate>
{
    NSInteger tmpIndex;
    UIScrollView *scrollViewC;
}

@end

@implementation HYPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tmpIndex = 0;
    [self createPage];
    
    scrollViewC = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.scrollViewbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-44)];
    scrollViewC.pagingEnabled = YES;
    scrollViewC.delegate = self;
    scrollViewC.contentSize = CGSizeMake(self.view.frame.size.width * self.viewControllers.count,  self.view.frame.size.height-44);
    scrollViewC.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollViewC];
    
}

- (void)setViewControllers:(NSArray *)viewControllers{
    _viewControllers = viewControllers;
    for (int i = 0; i < _viewControllers.count; i++) {
        UIViewController *viewController = _viewControllers[i];
        viewController.view.frame = CGRectMake(self.view.frame.size.width * i, 0, self.view.frame.size.width, self.view.frame.size.height);
        CGFloat R = arc4random()%255;
        CGFloat G = arc4random()%255;
        CGFloat B = arc4random()%255;
        viewController.view.backgroundColor = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
        [self addChildViewController:viewController];
        [scrollViewC addSubview:viewController.view];
    }
}

- (void)createPage{
    self.scrollViewbar = [[HYPageScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    NSMutableArray *titleArr = [[NSMutableArray alloc] initWithCapacity:10];
    for (UIViewController *ViewController in self.viewControllers) {
        [titleArr addObject:ViewController.title];
    }
    self.scrollViewbar.titleArray = titleArr;
    self.scrollViewbar.backgroundColor = [UIColor whiteColor];
    self.scrollViewbar.eachRowNumber = self.eachRowNumber?_eachRowNumber:4;
    self.scrollViewbar.delegateHy = self;
    self.scrollViewbar.buttonFont = self.buttonFont?_buttonFont:[UIFont systemFontOfSize:17];
    self.scrollViewbar.tintColor = self.tintColor?_tintColor:[UIColor blackColor];
    self.scrollViewbar.buttonAdjustsFontSizeToFitWidth = _buttonAdjustsFontSizeToFitWidth;
    [self.view addSubview:self.scrollViewbar];
}

- (void)setEachRowNumber:(NSInteger)eachRowNumber{
    _eachRowNumber = eachRowNumber;
    self.scrollViewbar.eachRowNumber = _eachRowNumber?_eachRowNumber:4;
}

- (void)setButtonFont:(UIFont *)buttonFont{
    _buttonFont = buttonFont;
    self.scrollViewbar.buttonFont = _buttonFont?_buttonFont:[UIFont systemFontOfSize:17];
}

- (void)setButtonAdjustsFontSizeToFitWidth:(BOOL)buttonAdjustsFontSizeToFitWidth{
    _buttonAdjustsFontSizeToFitWidth = buttonAdjustsFontSizeToFitWidth;
    self.scrollViewbar.buttonAdjustsFontSizeToFitWidth = _buttonAdjustsFontSizeToFitWidth;
}

- (void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    self.scrollViewbar.tintColor = _tintColor?_tintColor:[UIColor blackColor];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/self.view.frame.size.width;
    CGFloat kWidth = self.view.frame.size.width/self.scrollViewbar.eachRowNumber;
    CGFloat scrollX = self.scrollViewbar.contentOffset.x;
    CGFloat sliderX = self.scrollViewbar.sliderView.frame.origin.x;
    CGFloat endScrollX = scrollX + kWidth * (self.scrollViewbar.eachRowNumber-1);
    CGFloat endTwoScrollX = self.scrollViewbar.contentOffset.x + kWidth * self.scrollViewbar.eachRowNumber;
    [UIView animateWithDuration:0.25 animations:^{
        NSInteger poorNumber = self.scrollViewbar.eachRowNumber - 1;
        if (index == tmpIndex - 1 || index == tmpIndex + 1) {
            if (sliderX >= endScrollX - 1 && sliderX < endTwoScrollX + 1 && tmpIndex < index) {
                self.scrollViewbar.contentOffset = CGPointMake(kWidth * (index-poorNumber), 0);
                
            }else if (sliderX != scrollX - 1 && tmpIndex > index) {
                if (sliderX >= scrollX - 1 && sliderX < scrollX + 1 && scrollX >= kWidth - 1) {
                    self.scrollViewbar.contentOffset = CGPointMake(scrollX - kWidth, 0);
                    self.scrollViewbar.sliderView.transform = CGAffineTransformMakeTranslation(scrollX - kWidth, 0);
                }
            }
        }else{
            if (tmpIndex != index && index < self.scrollViewbar.eachRowNumber) {
                self.scrollViewbar.contentOffset = CGPointMake(0, 0);
            }else if (tmpIndex != index && index != 0 && sliderX >= scrollX - 1 && sliderX < scrollX + 1){
                self.scrollViewbar.contentOffset = CGPointMake(kWidth * (index-poorNumber), 0);
            }else{
                if (kWidth * (index-poorNumber) <= 0) {
                    self.scrollViewbar.contentOffset = CGPointMake(0, 0);
                }else{
                    self.scrollViewbar.contentOffset = CGPointMake(kWidth * (index-poorNumber), 0);
                }
            }
        }
        self.scrollViewbar.sliderView.transform = CGAffineTransformMakeTranslation(kWidth * index, 0);
    }];
    tmpIndex = index;
}

- (void)touchesButton:(NSInteger)index{
    //    [UIView animateWithDuration:0.25 animations:^{
    scrollViewC.contentOffset = CGPointMake(self.view.frame.size.width * index, 0);
    //    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
