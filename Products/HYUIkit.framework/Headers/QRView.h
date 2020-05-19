//
//  QRView.h
//  HYQRCodeView
//
//  Created by 吴昊原 on 2017/7/3.
//  Copyright © 2017年 HYQRCodeView. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRView : UIView

@property (nonatomic,strong) void(^block)(UIButton *sender);
@property (nonatomic,assign) BOOL isStop;
@property (nonatomic,strong) UILabel *messageLab;
@end
