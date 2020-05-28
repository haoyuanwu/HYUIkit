//
//  HYQRViewController.h
//  iDriving
//
//  Created by wuhaoyuan on 16/8/9.
//  Copyright © 2016年 济南掌游. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class HYQRViewController;

@protocol HYQRViewControllerDelegate <NSObject>

- (void)HYQRViewController:(HYQRViewController *)QRViewController errMessage:(NSString *)errMessage status:(AVAuthorizationStatus)status;

@end
/**
 *  扫描二维码
 */
@interface HYQRViewController : UIViewController

@property(nonatomic, strong)void(^block)(NSString *info);
@property (nonatomic,strong) NSString *message;

@property (strong, nonatomic) id<HYQRViewControllerDelegate> deleagte;

@end
