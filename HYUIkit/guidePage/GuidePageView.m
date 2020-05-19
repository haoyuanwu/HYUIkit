//
//  GuidePageView.m
//  HYGuidePage
//
//  Created by wuhaoyuan on 15/12/22.
//  Copyright © 2015年 HYGuidePage. All rights reserved.
//

#import "GuidePageView.h"
#define Kheight [UIScreen mainScreen].bounds.size.height
#define Kwidth [UIScreen mainScreen].bounds.size.width

@interface GuidePageView ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *images;

@end

@implementation GuidePageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setGuidePageArr:(NSArray *)guidePageArr{
    _guidePageArr = guidePageArr;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.scrollView.contentSize = CGSizeMake(Kwidth * self.guidePageArr.count, Kheight);
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    
    self.images = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.images.backgroundColor = [UIColor whiteColor];
    self.images.userInteractionEnabled = YES;
    [self addSubview:self.images];
    
    for (int i = 0; i < self.guidePageArr.count; i++) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 , Kwidth, Kheight)];
        image.image = [UIImage imageNamed:self.guidePageArr[i]];
        image.contentMode = UIViewContentModeScaleAspectFit;
        image.userInteractionEnabled = YES;
        image.tag = 100 + i;
        if (i != 0) {
            image.alpha = 0;
        }
    
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeGuideView:)];
        [self.scrollView addGestureRecognizer:tap];
        [self.images addSubview:image];
    }

    [self addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, Kheight - 44, Kwidth, 44)];
    self.pageControl.numberOfPages = self.guidePageArr.count;
    self.pageControl.pageIndicatorTintColor = [UIColor orangeColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    [self addSubview:self.pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat imgAlpha = scrollView.contentOffset.x/Kwidth;
    NSInteger index = scrollView.contentOffset.x/Kwidth;
    
    if (scrollView.contentOffset.x > index && scrollView.contentOffset.x < Kwidth * (index+1)) {
        for (UIImageView *img in self.images.subviews) {
            if (img.tag == 100 + index) {
                img.alpha = (index + 1)-imgAlpha;
            }else if (img.tag == 100 + index + 1){
                img.alpha = imgAlpha - index;
            }else{
                img.alpha = 0;
            }
        }
    }
}

- (void)removeGuideView:(UITapGestureRecognizer *)sender{
    if (self.scrollView.contentOffset.x == self.scrollView.contentSize.width - Kwidth) {
        [UIView animateWithDuration:1 animations:^{
            self.scrollView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            CGRect rect = self.scrollView.frame;
            rect.size = CGSizeMake(self.frame.size.width*1.5, self.frame.size.height*1.5);
            self.alpha = 0;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = scrollView.contentOffset.x/Kwidth;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
