//
//  HYLocationManager.h
//  HYUIkit
//
//  Created by wuhaoyuan on 16/4/20.
//  Copyright © 2016年 wuhaoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HYLocationChange.h"

typedef void (^UserLocation)(CLPlacemark *placemark,NSError *error);

typedef void (^RouteLine) (NSArray<MKRoute *> *route);

typedef void(^firstPlacemark)(CLPlacemark *firstplacemark);

@interface HYLocationManager : HYLocationChange

@property(nonatomic,strong)void(^userLocation)(CLPlacemark *placemark,NSError *error);

@property (nonatomic,strong) MKMapView *HYMapView;
@property (nonatomic,strong) CLPlacemark *placemark;
@property (nonatomic,strong) UIColor *routeColor;
@property (nonatomic,assign) CGFloat routeWidth;

@property (nonatomic,strong) UIImage *annotationViewImage;
@property (nonatomic,assign) MKPinAnnotationColor HYAnnotationColor;
@property (nonatomic,assign) BOOL animatesDrop;

+ (HYLocationManager *)singletion;

/**
 *  定位当前位置
 *
 *  @param userLocation 位置信息
 */
+ (void)updataUserLocation:(UserLocation)userLocation;

/**
 *  两点之前的路线
 *
 *  @param statrPoint 起点
 *  @param endPoint   终点
 *  @param mapView    地图
 *  @param routeArr   路线数组
 */
#pragma 要外部实现mapViewdelegate的方法  自行设置线宽和颜色
+ (void)routeActionWithStartPoint:(CLLocationCoordinate2D)statrPoint endPoint:(CLLocationCoordinate2D)endPoint toMap:(MKMapView *)mapView Route:(RouteLine)routeArr;

/**
 *  地理位置转为经纬度
 *
 *  @param address   地名
 *  @param Placemark 地理信息
 */
+ (void)exchangeAddressWithLocation:(NSString *)address CLPlacemark:(firstPlacemark)Placemark;

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

/**
 *  打开地图开启导航
 *
 *  @param locationCoordinate2D 起点
 *  @param companyCoordinate2D  终点
 */
+ (void)loadMapNavigationStartLocation:(CLLocationCoordinate2D)locationCoordinate2D companyCoordinate2D:(CLLocationCoordinate2D)companyCoordinate2D;


//================================================以下方法用处不大==================================================
/**
 *  添加Map
 */
- (MKMapView *)HYLocationManagerWithMaptoView:(UIView *)view;

/**
 *  放大坐标
 */
- (void)HYCoordinateRegionMakeWithDistance:(MKCoordinateRegion)CoordinateRegion;

/**
 *  添加地标
 *
 *  @param location 位置
 *  @param title    标题
 *  @param subtitle 副标题
 */
- (void)addAnnotationViewtoMap:(MKMapView *)map location:(CLLocationCoordinate2D)location title:(NSString *)title subtitle:(NSString *)subtitle;
@end
