//
//  NSDate+HYDate.m
//  HYDate + stretch
//
//  Created by wuhaoyuan on 16/4/21.
//  Copyright © 2016年 HYDate. All rights reserved.
//

#import "NSDate+HYDate.h"

@implementation NSDate (HYDate)

- (NSString *)string{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"yyyy-MM-dd HH-mm-ss"];
    
    return [formatter stringFromDate:self];
}

- (NSString *)stringWithFormatter:(NSString *)formatterStr{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:formatterStr];
    
    return [formatter stringFromDate:self];
}

+ (NSDate *)stringWithDate:(NSString *)string Formatter:(NSString *)formatter{
    
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [inputFormatter setTimeZone:timeZone];
    
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    [inputFormatter setDateFormat:formatter];
    
    return [inputFormatter dateFromString:string];
}

+ (NSDate *)timerDifference:(NSInteger)hour{
    return [NSDate dateWithTimeInterval:hour*60*60 sinceDate:[NSDate date]];
}

+ (NSDate *)timerDifferenceWithDate:(NSDate *)date hour:(NSInteger *)hour{
    return [NSDate dateWithTimeInterval:(int)hour*60*60 sinceDate:date];
}

/**
 *  第二天日期
 */
+ (NSDate *)toDayDate{
    return [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];
}

/**
 *  第几天后日期
 */
+ (NSDate *)dayDateformIndex:(NSInteger)index{
    return [NSDate dateWithTimeInterval:24*60*60*index sinceDate:[NSDate date]];
}

/**
 据给定时间的后某天日期
 */
+ (NSDate *)dayDateformIndex:(NSInteger)index formDate:(NSDate *)date{
    return [NSDate dateWithTimeInterval:24*60*60*index sinceDate:date];
}

/**
 *  年 year
 */
- (NSString *)yearString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy"];
    
    return [formatter stringFromDate:self];
}

/**
 *  月 month
 */
- (NSString *)monthString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"MM"];
    
    return [formatter stringFromDate:self];
}

/**
 *  日 day
 */
- (NSString *)dayString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"dd"];
    
    return [formatter stringFromDate:self];
}


/**
 计算时间点之前的天数时间

 @param day  天数
 @param date 时间点

 @return 
 */
+ (NSTimeInterval)ComputationTimeDay:(id)day date:(NSDate *)date{
    NSTimeInterval  timeInterval = [date timeIntervalSince1970];
    return timeInterval - ([day intValue] * 24*60*60 + 16*60*60);
}

@end
