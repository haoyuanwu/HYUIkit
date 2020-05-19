//
//  SSScanningController.h
//  SSScanningCard
//
//  Created by soldoros on 2018/9/19.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCardModel.h"

@class SSScanningController;
//扫描完毕后的回调
@protocol SSScanningControllerDelegate <NSObject>

-(void)SSScanningControllerPopController:(SSScanningController *)ScanningController model:(SSCardModel *)model;

@end

@interface SSScanningController : UIViewController

@property(nonatomic,assign)id<SSScanningControllerDelegate>delegate;



@end
