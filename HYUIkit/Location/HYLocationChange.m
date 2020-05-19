//
//  HYLocationChange.m
//  iCarClient
//
//  Created by wuhaoyuan on 15/11/2.
//  Copyright © 2015年 济南掌游. All rights reserved.
//

#import "HYLocationChange.h"

@implementation HYLocationChange

/**
 *  百度转原生地图坐标
 */
+ (CLLocationCoordinate2D)ChangeLoactionBD09FromGCJ02:(CLLocationCoordinate2D)coor{
    CLLocationDegrees x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    CLLocationDegrees x = coor.longitude - 0.0065, y = coor.latitude - 0.006;
    CLLocationDegrees z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    CLLocationDegrees gg_lon = z * cos(theta);
    CLLocationDegrees gg_lat = z * sin(theta);
    return CLLocationCoordinate2DMake(gg_lat, gg_lon);
}

/**
 *  原生转百度地图坐标
 */
+ (CLLocationCoordinate2D)ChangeLoactionGCJ02FromBD09:(CLLocationCoordinate2D)coor{
    CLLocationDegrees x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    CLLocationDegrees x = coor.longitude, y = coor.latitude;
    CLLocationDegrees z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    CLLocationDegrees bd_lon = z * cos(theta) + 0.0065;
    CLLocationDegrees bd_lat = z * sin(theta) + 0.006;
    return CLLocationCoordinate2DMake(bd_lat, bd_lon);
}
@end
