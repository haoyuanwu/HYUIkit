//
//  HYLocationManager.m
//  HYUIkit
//
//  Created by wuhaoyuan on 16/4/20.
//  Copyright © 2016年 wuhaoyuan. All rights reserved.
//

#import "HYLocationManager.h"
#import <objc/runtime.h>

@interface HYLocationManager ()<CLLocationManagerDelegate,MKMapViewDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;

@end

static NSString *annViewID = @"cell";

@implementation HYLocationManager

+ (HYLocationManager *)singletion{
    static HYLocationManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[HYLocationManager alloc]init];
        obj.routeColor = [UIColor blueColor];
        obj.routeWidth = 5.0;
    });
    return obj;
}

- (instancetype)init{
    if (self = [super init]) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        
        if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0)
        {
            //需要在plist文件中添加默认缺省的字段“NSLocationAlwaysUsageDescription”，这个提示是:“允许应用程序在您并未使用该应用程序时访问您的位置吗？”NSLocationAlwaysUsageDescription对应的值是告诉用户使用定位的目的或者是标记。
            [self.locationManager requestAlwaysAuthorization];
            // 需要在plist文件中添加默认缺省的字段“NSLocationWhenInUseDescription”，这个时候的提示是:“允许应用程序在您使用该应用程序时访问您的位置吗？”
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 10.0f;
    }
    return self;
}

+ (void)updataUserLocation:(UserLocation)userLocation{
    __weak HYLocationManager *manager = [HYLocationManager singletion];
    [manager.locationManager startUpdatingLocation];
    manager.userLocation = ^(CLPlacemark *placemark,NSError *error){
        if (userLocation) {
            manager.placemark = placemark;
            userLocation(placemark,error);
        }
    };
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self.locationManager stopUpdatingLocation];
    //CLLocation是位置类,主要的属性有经纬度，海拔，移动速度等
    CLLocation *loc=[locations lastObject];
    //------------------位置解析（ios5以后）---------------------
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *place in placemarks)//for-in快速枚举
        {
            self.userLocation(place,error);
        }
    }];
}

/**
 *  画路线方法
 *
 *  @param statrPoint 起点
 *  @param endPoint   终点
 *  @param mapView    地图
 *  @param routeArr   路线数组
 */
+ (void)routeActionWithStartPoint:(CLLocationCoordinate2D)statrPoint endPoint:(CLLocationCoordinate2D)endPoint toMap:(MKMapView *)mapView Route:(RouteLine)routeArr{
    
    mapView.delegate = [HYLocationManager singletion];
    CLLocationCoordinate2D fromCoordinate2D = statrPoint;
    CLLocationCoordinate2D toCoordinate2D = endPoint;
    //设置我的位置为起点位置
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate2D addressDictionary:nil];
    //设置公司位置为目的位置
    MKPlacemark *toPlacemark = [[MKPlacemark alloc] initWithCoordinate:toCoordinate2D addressDictionary:nil];
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    //设置方向请求
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = fromItem;
    request.destination = toItem;
    //如果两点之间有多条线路会返回多个线路，默认是NO的
    request.requestsAlternateRoutes = YES;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    //画出路线的
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"Error: %@", error);
         }
         else {
             //划线  现在只花了一条
             MKRoute *route = response.routes[0];
             [mapView addOverlay:route.polyline];
             routeArr(response.routes);
         }
     }];
}

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

#pragma mark - 导航的代理方法
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = self.routeWidth; // 线宽
    renderer.strokeColor = self.routeColor;
    return renderer;
}

- (MKMapView *)HYLocationManagerWithMaptoView:(UIView *)view{
    [view addSubview:self.HYMapView];
    return self.HYMapView;
}

- (MKMapView *)HYMapView{
    if (!_HYMapView) {
        _HYMapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_HYMapView sizeToFit];
        //地图的类型(3种)
        _HYMapView.mapType = MKMapTypeStandard;
        //设置代理
        _HYMapView.delegate = self;
        //显示用户定位
        _HYMapView.showsUserLocation = YES;
    }
    return _HYMapView;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
}

/**
 *  根据地址转换经纬度
 *
 *  @param address   地址
 *  @param Placemark 经纬度
 */
+ (void)exchangeAddressWithLocation:(NSString *)address CLPlacemark:(firstPlacemark)Placemark{
    
    CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
    [myGeocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if (Placemark) {
                Placemark(placemark);
            }
        }
        else if ([placemarks count] == 0 && error == nil) {
            NSLog(@"Found no placemarks.");
        } else if (error != nil) {
            NSLog(@"An error occurred = %@", error);
        }
    }];
}

/**
 *  调用地图导航
 *
 *  @param locationCoordinate2D 起点
 *  @param companyCoordinate2D  终点
 */
+ (void)loadMapNavigationStartLocation:(CLLocationCoordinate2D)locationCoordinate2D companyCoordinate2D:(CLLocationCoordinate2D)companyCoordinate2D{
    NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving",locationCoordinate2D.latitude,locationCoordinate2D.longitude,companyCoordinate2D.latitude,companyCoordinate2D.longitude];
    NSURL *url = [NSURL URLWithString:stringURL];
    if (![[UIApplication sharedApplication] openURL:url]){
        
        CLLocation*loca=[[CLLocation alloc]initWithCoordinate:companyCoordinate2D altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:loca.coordinate addressDictionary:nil] ];
        toLocation.name = @"终点";
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                       launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                 forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }

}

/**
 *  添加地标
 *
 *  @param location 位置
 *  @param title    标题
 *  @param subtitle 副标题
 */
- (void)addAnnotationViewtoMap:(MKMapView *)map location:(CLLocationCoordinate2D)location title:(NSString *)title subtitle:(NSString *)subtitle{
    MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
    ann.coordinate = location;
    ann.title = title;
    ann.subtitle = subtitle;
    if (map) {
        [map addAnnotation:ann];
    }else{
        [self.HYMapView addAnnotation:ann];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    MKPinAnnotationView *annotationView=(MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annViewID];
    
    if (annotationView == nil)
    {
        annotationView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annViewID];
    }
    if (self.annotationViewImage) {
        annotationView.image = self.annotationViewImage;
    }
    
    annotationView.animatesDrop = self.animatesDrop;//往下坠的动画效果
    if (self.HYAnnotationColor) {
        annotationView.pinColor = self.HYAnnotationColor;
    }
    
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

- (void)HYCoordinateRegionMakeWithDistance:(MKCoordinateRegion)CoordinateRegion{
    MKCoordinateRegion region = CoordinateRegion;
    [self.HYMapView setRegion:region animated:YES];
}
@end
