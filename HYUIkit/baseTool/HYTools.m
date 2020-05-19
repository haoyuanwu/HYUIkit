//
//  HYTools.m
//  HYUIkit
//
//  Created by 吴昊原 on 2017/11/28.
//  Copyright © 2017年 wuhaoyuan. All rights reserved.
//

#import "HYTools.h"



#define KSessionCookie @"SESSION"
#define KSessionName   @"myCookie"
#define KSessionDict   @"cookieDict"

@implementation HYTools

/**
 获取手机ip地址
 */
+ (NSString *)getDeviceIPIpAddresses
{
    
    int sockfd =socket(AF_INET,SOCK_DGRAM, 0);
    
    //    if (sockfd <</span> 0) return nil;
    
    NSMutableArray *ips = [NSMutableArray array];
    
    int BUFFERSIZE =4096;
    
    struct ifconf ifc;
    
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    
    struct ifreq *ifr, ifrcopy;
    
    ifc.ifc_len = BUFFERSIZE;
    
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd,SIOCGIFCONF, &ifc) >= 0){
        
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            
            int len =sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                
                len = ifr->ifr_addr.sa_len;
                
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            
            if (ifr->ifr_addr.sa_family !=AF_INET) continue;
            
            if ((cptr = (char *)strchr(ifr->ifr_name,':')) != NULL) *cptr =0;
            
            if (strncmp(lastname, ifr->ifr_name,IFNAMSIZ) == 0)continue;
            
            memcpy(lastname, ifr->ifr_name,IFNAMSIZ);
            
            ifrcopy = *ifr;
            
            ioctl(sockfd,SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags &IFF_UP) == 0)continue;
            
            NSString *ip = [NSString stringWithFormat:@"%s",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            
            [ips addObject:ip];
            
        }
    }
    
    close(sockfd);
    
    NSString *deviceIP =@"";
    
    for (int i=0; i < ips.count; i++)
        
    {
        if (ips.count >0)
            
        {
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
            
        }
        
    }
    
    NSLog(@"deviceIP========%@",deviceIP);
    
    return deviceIP;
    
}

/**
 自适应
 
 @param text 文字
 @param width 宽度
 @param fontSize 字体
 */
- (CGFloat)textHeight:(NSString *)text width:(CGFloat)width fontSize:(CGFloat)fontSize{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    return rect.size.height;
}

/**
 *  判断是否打开定位
 */
+ (BOOL)isOpenLocation{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
            return YES;
        }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            return NO;
        }else{
            return YES;
        }
}

/**
 *  生日计算年龄
 */
- (NSString *)countAge:(NSDate *)pickerDate birthday:(NSArray *)birthdayArr{
    NSDate *date = [NSDate date];
    
    if (birthdayArr == nil) {
        NSInteger year = [[date yearString] integerValue] - [[pickerDate yearString]integerValue];
        NSInteger month = [[pickerDate monthString] integerValue] - [[date monthString] integerValue];
        NSInteger day = [[pickerDate dayString] integerValue] - [[date dayString] integerValue];
        if (month > 0) {
            year--;
        }else if(month <= 0 && day < 0){
            year--;
        }
        if (year <= 0) {
            year = 0;
        }
        return [NSString stringWithFormat:@"%ld",(long)year];
    }else if(birthdayArr.count >= 3){
        NSInteger year = [[date yearString] integerValue] - [birthdayArr[0] integerValue];
        NSInteger month = [birthdayArr[1] integerValue] - [[date monthString] integerValue];
        NSInteger day = [birthdayArr[2] integerValue] - [[date dayString] integerValue];
        if (month > 0) {
            year--;
        }else if(month <= 0 && day < 0){
            year--;
        }
        if (year <= 0) {
            year = 0;
        }
        return [NSString stringWithFormat:@"%ld",(long)year];
    }
    return @"";
}


/**
 *  获取时间
 */
+ (NSDateComponents *)getTimer{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags =
    NSCalendarUnitEra        |
    NSCalendarUnitYear       |
    NSCalendarUnitMonth      |
    NSCalendarUnitDay        |
    NSCalendarUnitHour       |
    NSCalendarUnitMinute     |
    NSCalendarUnitSecond     |
    NSCalendarUnitWeekday    |
    NSCalendarUnitWeekdayOrdinal;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    return dateComponent;
}

+ (void)insertNotifications:(NSDate *)date alert:(NSString *)alert key:(NSString *)key{
    
    NSArray *days = @[@90, @30, @7,@1];
    
    for (int i = 0; i<3; i++) {
        NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:[NSDate ComputationTimeDay:days[i] date:date]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        //获取当前时间
        NSString *nowDateStr = [[NSDate date] string];
        //截取字符串
        NSString *changeString = [nowDateStr stringByReplacingCharactersInRange:NSMakeRange([nowDateStr length] - 8, 8) withString:@"00:00:00"];
        //更新当前时间（+16）
        NSDate *freshDate = [NSDate stringWithDate:changeString Formatter:@"yyyy-MM-dd HH:mm:ss"];
        //更新当前时间（new）
        NSDate *nowDate = [NSDate dateWithTimeInterval:8*60*60 sinceDate:freshDate];
        NSTimeInterval time = [newDate timeIntervalSinceDate:nowDate];
        NSLog(@"%f",time);
        if (time<0) {
            continue;
        }else if (time<[NSDate ComputationTimeDay:days[i] date:date]){
            [HYTools registerLocalNotification:0 title:[alert stringByAppendingString:days[i]] date:newDate key:[key stringByAppendingString:days[i]]];
        }
    }
}

+ (void)registerLocalNotification:(NSInteger)alertTime title:(NSString *)title date:(NSDate *)date key:(NSString *)key{
    
    [HYTools cancelLocalNotificationWithKey:key];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    if (alertTime != 0) {
        //间隔多长时间推送
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
        notification.fireDate = fireDate;
    }else{
        //时间点推送
        notification.fireDate = date;
    }
    NSDictionary *dict = notification.userInfo;
    
    [dict setValue:key forKey:@"key"];
    
    notification.userInfo = dict;
    
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = kCFCalendarUnitSecond;
    
    // 通知内容
    notification.alertBody = title;
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

/**
 *  计算缓存
 */
+ (NSString *)stringFromFileSize:(CGFloat)theSize{
    
    float floatSize = theSize;
    if (theSize==0) {
        return@"0 KB";
    }
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%f bytes",floatSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
    floatSize = floatSize / 1024;
    
    return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

/**
 *  背景图片渐变模糊处理
 */
//- (void)hiden{
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = self.view.layer.bounds;
//    gradientLayer.colors = [NSArray arrayWithObjects:
//                            (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
//                            (id)[UIColor colorWithWhite:0.0f alpha:0.2f].CGColor,
//                            (id)[UIColor colorWithWhite:0.0f alpha:0.3f].CGColor,
//                            (id)[UIColor colorWithWhite:0.0f alpha:1.0f].CGColor,
//                            nil];
//    gradientLayer.locations = [NSArray arrayWithObjects:
//                               [NSNumber numberWithFloat:0.0f],
//                               [NSNumber numberWithFloat:0.40f],
//                               [NSNumber numberWithFloat:0.60f],
//                               [NSNumber numberWithFloat:0.90f],
//                               nil];
//    [self.view.layer addSublayer:gradientLayer];
//}

#pragma mark 获取并保存cookie到userDefaults
+ (void)saveCookie{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:KSessionCookie]) {
            NSMutableDictionary *cookieDict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:KSessionName]];
            [cookieDict setValue:cookie.properties forKey:KSessionName];
            [userDefaults setObject:cookieDict forKey:KSessionDict];
        }
    }
}

#pragma mark 删除cookie
+ (void)deleteCookie{
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //删除cookie
    for (NSHTTPCookie *tempCookie in cookies) {
        [cookieStorage deleteCookie:tempCookie];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:KSessionDict];
}

#pragma mark 再取出保存的cookie重新设置cookie
+ (void)setCoookie{
    
    NSLog(@"============再取出保存的cookie重新设置cookie===============");
    //取出保存的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *cookieDict = [userDefaults objectForKey:KSessionDict];
    NSDictionary *cookiePropertie = [cookieDict valueForKey:KSessionName];
    if (cookiePropertie != nil) {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookiePropertie];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [cookieStorage setCookie:cookie];
    }
}
+ (void)showAlertViewTitle:(NSString *_Nullable)title message:(NSString *_Nullable)message cancelButtonTitle:(NSString *_Nullable)cancel otherButtonTitle:(NSString *_Nullable)other handlerBlock:(void(^_Nullable)(UIAlertAction * _Nullable action))handlerBlock{
    
    UIAlertController *alerView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    if (cancel && ![cancel isEqualToString:@""]) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nullable action) {
            handlerBlock(action);
        }];
        [alerView addAction:cancelAction];
    }
    if (other && ![other isEqualToString:@""]) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:other style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nullable action) {
            handlerBlock(action);
        }];
        [alerView addAction:cancelAction];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alerView animated:YES completion:nil];
    if ((!cancel && !other) || ([cancel isEqualToString:@""] && [other isEqualToString:@""]) ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alerView dismissViewControllerAnimated:YES completion:nil];
        });
    }
    
}


@end
