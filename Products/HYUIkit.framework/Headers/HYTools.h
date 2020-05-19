//
//  HYTools.h
//  HYUIkit
//
//  Created by 吴昊原 on 2017/11/28.
//  Copyright © 2017年 wuhaoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSDate+HYDate.h"
#import <MapKit/MapKit.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <arpa/inet.h>
//#import <CommonCrypto/CommonDigest.h>


@interface HYTools : NSObject

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
+ (void)saveCookie;

/**
 设置cookie
 */
+ (void)setCoookie;

/**
 删除cookie
 */
+ (void)deleteCookie;

+ (void)showAlertViewTitle:(NSString *_Nullable)title message:(NSString *_Nullable)message cancelButtonTitle:(NSString *_Nullable)cancel otherButtonTitle:(NSString *_Nullable)other handlerBlock:(void(^_Nullable)(UIAlertAction * _Nullable action))handlerBlock;
@end
