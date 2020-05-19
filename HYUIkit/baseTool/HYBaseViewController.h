//
//  HYBaseViewController.h
//  HYUIkit
//
//  Created by iPhone on 15/10/27.
//  Copyright © 2015年 wuhaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYBaseViewController : UIViewController

/**
 *  获取系统时间类
 */
+ (NSDateComponents *)getTimer;

/**
 *  自适应高度方法
 */
- (CGFloat)textHeight:(NSString *)text width:(CGFloat)width fontSize:(CGFloat)fontSize;

/**
 *  取消本地推送
 */
+ (void)cancelLocalNotificationWithKey:(NSString *)key;

/**
 *  计算缓存
 */
+ (NSString *)stringFromFileSize:(CGFloat)theSize;

/**
 *  添加本地推送
 *
 *  @param alertTime 倒计时(等于零不会推送)
 *  @param title     提示标题
 *  @param date      时间（alertTime必须为零才生效）
 *  @param key       key
 */
+ (void)registerLocalNotification:(NSInteger)alertTime title:(NSString *)title date:(NSDate *)date key:(NSString *)key;

/**
 获取手机ip地址
 */
+ (NSString *)getDeviceIPIpAddresses;

/**
 保存cookie
 */
- (void)saveCookie;

/**
 设置cookie
 */
- (void)setCoookie;

/**
 删除cookie
 */
- (void)deleteCookie;


@end
