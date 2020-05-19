//
//  CameraDetailsView.h
//  HYUIkit
//
//  Created by 吴昊原 on 2020/4/23.
//  Copyright © 2020 wuhaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraDetailsView : UIView

@property (strong, nonatomic) UIImageView *imageView;
//@property (strong, nonatomic) UIButton *undoBtn;
//@property (strong, nonatomic) UIButton *confirmBtn;
@property (assign, nonatomic) CGRect maskCropRect;

@property (nonatomic,strong) void(^cancelBlock)(void);
@property (nonatomic,strong) void(^confirmBlock)(UIImage *image);


//            UIImage *image = [UIImage imageByConvertView:dateilsView relativeOriginSize:dateilsView.frame.size opaque:YES scale:0];
//            UIImage *newImage = [self imageFromImage:image inRect:rect];
@property (strong, nonatomic) UIImage*(^disposeImageBlock)(UIView *dateilsView,CGRect rect);



@end

NS_ASSUME_NONNULL_END
