//
//  HYLocationChange.h
//  iCarClient
//
//  Created by wuhaoyuan on 15/11/2.
//  Copyright © 2015年 济南掌游. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HYLocationChange : NSObject

/**
 *  百度转换原生
 *
 *  @param coor 位置
 *
 *  @return
 */
+ (CLLocationCoordinate2D)ChangeLoactionGCJ02FromBD09:(CLLocationCoordinate2D)coor;

/**
 *  原生转换百度
 *
 *  @param coor 位置
 *
 *  @return
 */
+ (CLLocationCoordinate2D)ChangeLoactionBD09FromGCJ02:(CLLocationCoordinate2D)coor;
@end
