//
//  HYQRViewController.h
//  iDriving
//
//  Created by wuhaoyuan on 16/8/9.
//  Copyright © 2016年 济南掌游. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  扫描二维码
 */
@interface HYQRViewController : UIViewController

@property(nonatomic, strong)void(^block)(NSString *info);
@property (nonatomic,strong) NSString *message;
@end
