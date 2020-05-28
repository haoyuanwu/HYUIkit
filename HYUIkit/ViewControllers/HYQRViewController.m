//
//  QLQRViewController.m
//  iDriving
//
//  Created by wuhaoyuan on 16/8/9.
//  Copyright © 2016年 济南掌游. All rights reserved.
//

#import "HYQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRView.h"
#import "HYTools.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface HYQRViewController () <UITabBarDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;
@property (nonatomic, strong) QRView *qrView;

/*** 专门用于保存描边的图层 ***/
@property (nonatomic,strong) CALayer *containerLayer;
@end

@implementation HYQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"二维码";
    self.view.backgroundColor = UIColor.blackColor;
    // 开始扫描二维码
    [self startScan];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(10, 20, 44, 44);
    [button setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(goback) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
}

- (void)goback {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setMessage:(NSString *)message{
    _message = message;
    self.qrView.messageLab.text = message;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.qrView.isStop = NO;
}

- (AVCaptureDevice *)device
{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _previewLayer;
}
// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
//        out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureMetadataOutput *)output
{
    if (_output == nil) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        
        // 1.获取屏幕的frame
        CGRect viewRect = self.view.frame;
        // 2.获取扫描容器的frame
        CGRect containerRect = self.view.frame;
        
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
        
        // CGRect outRect = CGRectMake(x, y, width, height);
        // [_output rectForMetadataOutputRectOfInterest:outRect];
        _output.rectOfInterest = CGRectMake(x, y, width, height);
    }
    return _output;
}

- (CALayer *)containerLayer
{
    if (_containerLayer == nil) {
        _containerLayer = [[CALayer alloc] init];
    }
    return _containerLayer;
}

- (void)startScan
{

    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        if (self.deleagte && [self.deleagte respondsToSelector:@selector(HYQRViewController:errMessage:status:)] ) {
            [self.deleagte HYQRViewController:self errMessage:@"未相册允许权限" status:authStatus];
        }
        return;
    }
    // 1.判断输入能否添加到会话中
    if (![self.session canAddInput:self.input]) return;
    [self.session addInput:self.input];
    
    
    // 2.判断输出能够添加到会话中
    if (![self.session canAddOutput:self.output]) return;
    [self.session addOutput:self.output];
    
    // 4.设置输出能够解析的数据类型
    // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
   self.output.metadataObjectTypes  = self.output.availableMetadataObjectTypes;
//    self.output.metadataObjectTypes = @[
//      AVMetadataObjectTypeQRCode,
//      AVMetadataObjectTypeEAN13Code,
//      AVMetadataObjectTypeEAN8Code,
//      AVMetadataObjectTypeCode128Code
//      ];
    
    // 5.设置监听监听输出解析到的数据
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 6.添加预览图层
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.frame = self.view.bounds;
    
    self.qrView = [[QRView alloc] initWithFrame:self.view.frame];
    self.qrView.messageLab.text = self.message;
    __weak typeof (self) wself = self;
    self.qrView.block = ^(UIButton *sender) {
        [wself turnOnLight:sender.isSelected];
    };
    [self.view addSubview:self.qrView];
    
    // 7.添加容器图层
    [self.view.layer addSublayer:self.containerLayer];
    
    self.containerLayer.frame = self.view.bounds;
    
    // 8.开始扫描
    [self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if (metadataObjects.count > 0){
       
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            if (metadataObject && metadataObject.stringValue != nil) {
                if (self.session.isRunning) {
                    [self.session stopRunning];
                    stringValue = metadataObject.stringValue;
                    NSLog(@"%@",stringValue);
                    self.block(stringValue);
                    [self goback];
                }
            }
        }else if([metadataObject isKindOfClass:[AVMetadataFaceObject class]]){
            NSLog(@"人脸");
            [self.session startRunning];
        }else{
            NSLog(@"%s",object_getClassName(metadataObject));
        }
    }
}

- (void)turnOnLight:(BOOL)on {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (on) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode: AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
