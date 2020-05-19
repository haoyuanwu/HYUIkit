//
//  HYPageScrollView.m
//  HYPageScollView
//
//  Created by wuhaoyuan on 15/12/15.
//  Copyright © 2015年 pageScollView. All rights reserved.
//

#import "HYPageScrollView.h"

@interface HYPageScrollView ()
{
    UIImageView *leftImg;
    UIImageView *rightImg;
}
@property (nonatomic,strong) UIButton *titleButton;

@end

@implementation HYPageScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (void)createButton{
    for (int i = 0 ; i < self.titleArray.count ; i++) {
        self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.titleButton.frame = CGRectMake(self.frame.size.width/self.eachRowNumber * i, 20, self.frame.size.width/self.eachRowNumber, self.frame.size.height-20);
        self.titleButton.titleLabel.adjustsFontSizeToFitWidth = self.buttonAdjustsFontSizeToFitWidth;
        [self.titleButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        self.titleButton.titleLabel.font = self.buttonFont;
        self.titleButton.tag = 100 + i;
        [self.titleButton addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleButton setTitle:self.titleArray[i] forState:UIControlStateNormal];
        [self addSubview:self.titleButton];
    }
    self.contentSize = CGSizeMake(self.frame.size.width/self.eachRowNumber *  self.titleArray.count, self.frame.size.height);
    
    self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 3, self.frame.size.width/self.eachRowNumber, 3)];
    self.sliderView.backgroundColor = self.tintColor;
    [self addSubview:self.sliderView];
    
}

- (void)setTitleArray:(NSArray *)titleArray{
    _titleArray = titleArray;
    if (_eachRowNumber) {
        [self createButton];
    }
}

- (void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setTitleColor:_tintColor forState:UIControlStateNormal];
        }
    }
    self.sliderView.backgroundColor = _tintColor;
}

- (void)setEachRowNumber:(NSInteger)eachRowNumber{
    if (_eachRowNumber != eachRowNumber) {
        _eachRowNumber = eachRowNumber;
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        [self createButton];
    }
}

- (void)setButtonFont:(UIFont *)buttonFont{
    _buttonFont = buttonFont;
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.titleLabel.font = _buttonFont;
        }
    }
}

- (void)setButtonAdjustsFontSizeToFitWidth:(BOOL)buttonAdjustsFontSizeToFitWidth{
    _buttonAdjustsFontSizeToFitWidth = buttonAdjustsFontSizeToFitWidth;
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.titleLabel.adjustsFontSizeToFitWidth = _buttonAdjustsFontSizeToFitWidth;
        }
    }
}

//点击按钮
- (void)touchButton:(UIButton *)sender{
    NSInteger index = sender.tag - 100;
    if (self.delegateHy && [self.delegateHy respondsToSelector:@selector(touchesButton:)]) {
        [self.delegateHy touchesButton:index];
    }
    CGFloat widthX = sender.frame.origin.x;
    CGFloat scrollX = self.contentOffset.x;
    CGFloat scrollTwoX = scrollX + sender.frame.size.width;
    CGFloat endBtnX = scrollX + sender.frame.size.width * (self.eachRowNumber-1);
    CGFloat endTwoBtnX = scrollX + sender.frame.size.width * self.eachRowNumber;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.sliderView.transform = CGAffineTransformMakeTranslation(widthX, 0);
    }];
    
    if (widthX >= endBtnX - 1 && widthX < endTwoBtnX) {
        if (index == self.titleArray.count - 1) {
            return;
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.contentOffset = CGPointMake(scrollX + sender.frame.size.width, 0);
        }];
    }else if (widthX >= scrollX - 1 && widthX < scrollTwoX){
        if (index == 0) {
            return;
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.contentOffset = CGPointMake(widthX - sender.frame.size.width, 0);
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

@end
