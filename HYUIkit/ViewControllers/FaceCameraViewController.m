//
//  FaceCameraViewController.m
//  BaiLingDoctor
//
//  Created by 吴昊原 on 2019/5/13.
//  Copyright © 2019 BaiLingDoctor. All rights reserved.
//

#import "FaceCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import "HYLoadHUD.h"
//#import "HYTools.h"
//#import "UIImage+details.h"
#import <HYUIkit/HYUIkit.h>
#import "CameraDetailsView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface FaceCameraViewController ()<UITabBarDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCapturePhotoCaptureDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    __block BOOL isFace;
}
@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
// 输出格式
@property (nonatomic,strong) AVCapturePhotoSettings *outPutSetting;
// 出流对象
@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;
@property ( strong , nonatomic ) AVCapturePhotoOutput *output;
@property ( strong , nonatomic ) AVCaptureStillImageOutput *stillOutput;
@property ( strong , nonatomic ) AVCaptureMetadataOutput *dataOutput;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;
// 队列
@property (nonatomic,strong) dispatch_queue_t queue;
@property (strong, nonatomic) UIView *faceBorder;
@property (strong, nonatomic) CameraDetailsView *dateilsView;
@property (strong, nonatomic) UIButton *undoBtn;
@property (strong, nonatomic) UIButton *confirmBtn;

/*** 专门用于保存描边的图层 ***/
@property (nonatomic,strong) CALayer *containerLayer;
@end

@implementation FaceCameraViewController

- (CameraDetailsView *)dateilsView{
    if (!_dateilsView) {
        _dateilsView = [[CameraDetailsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _dateilsView.backgroundColor = UIColor.whiteColor;
        _dateilsView.alpha = 0;
    }
    return _dateilsView;
}
- (void)setMaskCropRect:(CGRect)maskCropRect{
    _maskCropRect = maskCropRect;
    self.dateilsView.maskCropRect = maskCropRect;
}


#pragma mark viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 开始扫描二维码
    [self startScan];
    self.imageSize = 0;
    if (self.maskCropRect.size.width == 0 || self.maskCropRect.size.height == 0) {
        self.maskCropRect = UIScreen.mainScreen.bounds;
    }
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        [HYTools showAlertViewTitle:@"温馨提示" message:@"您必须打开相机权限才能拍照，是否开启？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" handlerBlock:^(UIAlertAction * _Nullable action) {
            if ([action.title isEqualToString:@"确定"]) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        if (@available(iOS 10.0, *)) {
                            [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:nil];
                        } else {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                }
            }
        }];
    }
    self.navigationController.navigationBar.hidden = YES;
    
    self.dateilsView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    
    [self.view addSubview:self.faceBorder];
    [self.view addSubview:self.dateilsView];
    [self.view addSubview:self.maskBoard];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(20, statusBarHeight, 30, 30);
    
    UIImage *backImg = [UIImage imageNamed:@"image.bundle/back"
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];

    [button setImage:backImg forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(goback) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    _cameraBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _cameraBtn.frame = CGRectMake(SCREEN_WIDTH/2-40, SCREEN_HEIGHT-110, 80, 80);
    _cameraBtn.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-120);
    UIImage *cameraImg = [UIImage imageNamed:@"image.bundle/camera"
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    [_cameraBtn setImage:cameraImg forState:(UIControlStateNormal)];
//    _cameraBtn.enabled = NO;
    [_cameraBtn addTarget:self action:@selector(buttondown) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_cameraBtn];
    
    self.exchangeCamera = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.exchangeCamera.frame = CGRectMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 80, 40, 40);
    self.exchangeCamera.center = CGPointMake(self.exchangeCamera.center.x, _cameraBtn.center.y);
    UIImage *exchangeImg = [UIImage imageNamed:@"image.bundle/exchangeCamera"
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    [self.exchangeCamera setImage:exchangeImg forState:(UIControlStateNormal)];
    [self.exchangeCamera addTarget:self action:@selector(changeButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.exchangeCamera];
    
    self.albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *albumImg = [UIImage imageNamed:@"image.bundle/album"
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    self.albumBtn.frame = CGRectMake(60, SCREEN_HEIGHT - 80, 40, 40);
    self.albumBtn.center = CGPointMake(self.albumBtn.center.x, _cameraBtn.center.y);
    [self.albumBtn setImage:albumImg forState:(UIControlStateNormal)];
    [self.albumBtn addTarget:self action:@selector(openAlbumBtn) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.albumBtn];
    
    self.undoBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.undoBtn.frame = CGRectMake(SCREEN_WIDTH/4-15, SCREEN_HEIGHT-200, 40, 40);
    UIImage *undoImg = [UIImage imageNamed:@"image.bundle/undo"
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    [self.undoBtn setImage:undoImg forState:(UIControlStateNormal)];
    self.undoBtn.layer.shadowColor = UIColor.grayColor.CGColor;
    self.undoBtn.layer.shadowOffset = CGSizeMake(2, 4);
    self.undoBtn.layer.shadowRadius = 10;
    self.undoBtn.layer.shadowOpacity = 1;
    self.undoBtn.hidden = YES;
    [self.undoBtn addTarget:self action:@selector(undoImage) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.undoBtn];
    
    self.confirmBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.confirmBtn.frame = CGRectMake(SCREEN_WIDTH*3/4-15, SCREEN_HEIGHT-200, 40, 40);
    UIImage *confirmImg = [UIImage imageNamed:@"image.bundle/confirm"
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    [self.confirmBtn setImage:confirmImg forState:(UIControlStateNormal)];
    [self.confirmBtn addTarget:self action:@selector(confirmImage:) forControlEvents:(UIControlEventTouchUpInside)];
    self.confirmBtn.layer.shadowColor = UIColor.grayColor.CGColor;
    self.confirmBtn.layer.shadowOffset = CGSizeMake(2, 4);
    self.confirmBtn.layer.shadowRadius = 10;
    self.confirmBtn.layer.shadowOpacity = 1;
    self.confirmBtn.hidden = YES;
    [self.view addSubview:self.confirmBtn];
    
    self.albumBtn.hidden = self.hiddenAblumBtn;
    self.exchangeCamera.hidden = self.hiddenExchangeBtn;
    
}



#pragma mark 取消编辑选择
/// 取消编辑选择
- (void)undoImage{
    self.dateilsView.alpha = 0;
    self.undoBtn.hidden = YES;
    self.confirmBtn.hidden = YES;
    self.dateilsView.imageView.transform = CGAffineTransformIdentity;
    self.dateilsView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.albumBtn.hidden = self.hiddenAblumBtn;
    self.exchangeCamera.hidden = self.hiddenExchangeBtn;
    self.cameraBtn.hidden = NO;
    
    [self.session startRunning];
}
#pragma mark 确认编辑图片
/// 编辑图片确认
- (void)confirmImage:(UIButton *)sender{
    
    self.undoBtn.hidden = YES;
    self.confirmBtn.hidden = YES;
                // 通知主线程刷新 神马的
    //            UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0);
    //            [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
    //            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //            UIGraphicsEndImageContext();
            
    //            UIImage *image = [UIImage imageByConvertView:self relativeOriginSize:self.frame.size opaque:YES scale:0];
    //            UIImage *newImage = [self imageFromImage:image inRect:self.maskcCropRect];
    UIImage *newImage = self.disposeImageBlock(self.dateilsView, self.maskCropRect);
    self.dateilsView.imageView.transform = CGAffineTransformIdentity;
    self.dateilsView.imageView.image = newImage;
    self.dateilsView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (self.facepPicBlock) {
        self.facepPicBlock(newImage,UIImageJPEGRepresentation(newImage, 1));
    }
    self.dateilsView.alpha = 0;
    if (self.isSavePhoto) {
        UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 打开相册
- (void)openAlbumBtn {
    [self.session stopRunning];
    UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
    pickerVC.delegate = self;
    pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickerVC animated:true completion:nil];
    
}

- (void)goback {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIView *)maskBoard{
    if (!_maskBoard) {
        _maskBoard = [[UIView alloc] initWithFrame:CGRectZero];
        _maskBoard.backgroundColor = UIColor.clearColor;
    }
    return _maskBoard;
}

- (UIView *)faceBorder{
    if (!_faceBorder) {
        _faceBorder = [[UIView alloc] initWithFrame:CGRectZero];
        _faceBorder.layer.borderColor = UIColor.greenColor.CGColor;
        _faceBorder.layer.borderWidth = 2;
        _faceBorder.layer.cornerRadius = 7;
        _faceBorder.layer.masksToBounds = YES;
        _faceBorder.center = self.view.center;
        _faceBorder.backgroundColor = UIColor.clearColor;
        _faceBorder.alpha = 0;
    }
    return _faceBorder;
}

- (AVCaptureDevice *)device
{
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
    }
    return _device;
}

- (AVCaptureDeviceInput *)input
{
    if (!_input) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _previewLayer;
}


- (AVCapturePhotoOutput *)output
API_AVAILABLE(ios(10.0)){
    if (!_output) {
        
        _output = [[AVCapturePhotoOutput alloc] init];
        //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
        NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
        _outPutSetting = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    }
    return _output;
}

- (AVCaptureStillImageOutput *)stillOutput{
    if (!_stillOutput) {
        _stillOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *myOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
        [_stillOutput setOutputSettings:myOutputSettings];
    }
    return _stillOutput;
}

- (AVCaptureMetadataOutput *)dataOutput{
    if (!_dataOutput) {
        _dataOutput = [[AVCaptureMetadataOutput alloc] init];
        
        // 1.获取屏幕的frame
        CGRect viewRect = self.view.frame;
        // 2.获取扫描容器的frame
        CGRect containerRect = self.view.frame;
        
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
        
        _dataOutput.rectOfInterest = CGRectMake(x, y, width, height);
        
        //将元数据加入队列
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [_dataOutput setMetadataObjectsDelegate:self queue:_queue];
    }
    return _dataOutput;
}

- (AVCaptureVideoDataOutput *)videoDataOutput{
    if (!_videoDataOutput) {
        //初始化输出流对象
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
//        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
    }
    return _videoDataOutput;
}

- (CALayer *)containerLayer
{
    if (!_containerLayer) {
        _containerLayer = [[CALayer alloc] init];
    }
    return _containerLayer;
}

- (void)startScan
{

    // 1.判断输入能否添加到会话中
    if ([self.session canAddInput:self.input]){
        [self.session addInput:self.input];
    }
    // 2.判断输出能够添加到会话中
    if ([self.session canAddOutput:self.dataOutput]){
        [self.session addOutput:self.dataOutput];
    }
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    }
    if (@available(iOS 10.0, *)) {
        if ([self.session canAddOutput:self.output]) {
            [self.session addOutput:self.output];
        }
    }else{
        if ([self.session canAddOutput:self.stillOutput]) {
            [self.session addOutput:self.stillOutput];
        }
    }
    
    self.dataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    // 4.设置输出能够解析的数据类型
    // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
//    self.dataOutput.metadataObjectTypes  = self.dataOutput.availableMetadataObjectTypes;
    
    // 5.设置监听监听输出解析到的数据
    [self.dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 6.添加预览图层
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.frame = self.view.bounds;

    
    // 7.添加容器图层
    [self.view.layer addSublayer:self.containerLayer];
    
    self.containerLayer.frame = self.view.bounds;
    
    // 8.开始扫描
    [self.session startRunning];
    
    //设置人脸识别区域 并在此区域获取元数据
    self.dataOutput.rectOfInterest = [_previewLayer metadataOutputRectOfInterestForRect:UIScreen.mainScreen.bounds];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0){
        //停止扫描
//        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects.firstObject;
        if([metadataObject isKindOfClass:[AVMetadataFaceObject class]]){
//        NSLog(@"人脸");
//            [self.session startRunning];
        }else{
            NSLog(@"%s",object_getClassName(metadataObject));
        }
        
        // 只有当人脸区域的确在小框内时，才再去做捕获此时的这一帧图像
        if (metadataObject.type == AVMetadataObjectTypeFace) {
            
            AVMetadataObject *transformedMetadataObject = [_previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            CGRect faceRegion = transformedMetadataObject.bounds;
            
            isFace = CGRectContainsRect(UIScreen.mainScreen.bounds, faceRegion);
//            NSLog(@"是否包含头像：%d, facePathRect: %@, faceRegion: %@",isFace,NSStringFromCGRect(UIScreen.mainScreen.bounds),NSStringFromCGRect(faceRegion));
            // 为videoDataOutput设置代理
            if (isFace && _isOpenFace) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25 animations:^{
                        self.faceBorder.alpha = 1;
                        self.faceBorder.frame = faceRegion;
                    }];
                });
                if (!_videoDataOutput.sampleBufferDelegate) {
                    [_videoDataOutput setSampleBufferDelegate:self queue:_queue];
                }
            }
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
#pragma mark 从输出的数据流捕捉单一的图像帧
// AVCaptureVideoDataOutput获取实时图像，
//这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    //这个格式在初始化outPutSetting的时候设置了
    if (self.isOpenFace) {
        if ([captureOutput isEqual:_videoDataOutput]) {
            [self imageFromSampleBuffer:sampleBuffer];
        }
    }
}

#pragma mark 获取人脸的位置  生成图片
- (void )imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    //CIImage -> CGImageRef -> UIImage
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);  //拿到缓冲区帧数据
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    
    //需要旋转这个ciimage 按照正常图片方向返回正确的图片GCRect
    CIImage *wImage = [ciImage imageByApplyingOrientation:kCGImagePropertyOrientationRight];//创建CIImage对象 CGImagePropertyOrientation
    
    // 创建图形上下文
    CIContext * context = [CIContext contextWithOptions:nil];
    // 创建自定义参数字典
    NSDictionary * param = @{
        CIDetectorAccuracy:CIDetectorAccuracyHigh,
    };
    // 创建识别器对象
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    //识别脸部
//    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:temporaryContext options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}]; //CIDetectorAccuracyLow：识别精度低，但识别速度快、性能高
        //CIDetectorAccuracyHigh：识别精度高、但识别速度比较慢
//    NSArray * faceArray = [detector featuresInImage:ciImage];
    
    NSArray *faceArray = [detector featuresInImage:wImage options:nil];
    
    //得到人脸图片的尺寸
    if (faceArray.count) {
        NSLog(@"faceArray == %lu",(unsigned long)faceArray.count);
        
//        for (CIFaceFeature * faceFeature in faceArray) {
//            CGRect rect = faceFeature.bounds;
//        }
    }else{
        // 没有人脸，就将videoDataOutput的代理去掉，防止频繁调用
        if (_videoDataOutput.sampleBufferDelegate) {
            [_videoDataOutput setSampleBufferDelegate:nil queue:_queue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self->isFace) {
//                    [HYLoadHUD showLoadingFromView:self.view message:@"未识别到人脸,请对准取景框拍摄。"];
                }
                self->isFace = false;
                [UIView animateWithDuration:0.25 animations:^{
                    self.faceBorder.alpha = 0;
                    self.faceBorder.frame = CGRectMake(0, 0, 10, 10);
                    self.faceBorder.center = self.view.center;
                }];
            });
        }
    }
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

//照相按钮点击事件
-(void)buttondown{
    
    if (@available(iOS 10.0, *)) {
        NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
        self.outPutSetting = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
        [self.output capturePhotoWithSettings:self.outPutSetting delegate:self];
        self.cameraBtn.enabled = NO;
    } else {
        AVCaptureConnection *stillImageConnection = [self.output connectionWithMediaType:AVMediaTypeVideo];
        UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
        AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
        [stillImageConnection setVideoOrientation:avcaptureOrientation];
        [stillImageConnection setVideoScaleAndCropFactor:1.0f];
        [self.stillOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            self.view.userInteractionEnabled = NO;
            [self.session stopRunning];
            [HYLoadHUD showLoadingFromView:self.view message:@"正在处理"];
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *data = jpegData;
                if (self.imageSize != 0) {
                    data = [UIImage resetSizeOfImageData:[UIImage fixOrientation:[UIImage imageWithData:jpegData]] maxSize:self.imageSize];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    self.dateilsView.imageView.image = image;
                    if (self.isEdit) {
                        self.dateilsView.alpha = 1;
                        self.undoBtn.hidden = NO;
                        self.confirmBtn.hidden = NO;
                        self.albumBtn.hidden = YES;
                        self.cameraBtn.hidden = YES;
                        self.exchangeCamera.hidden = YES;
                    }else{
                        if (self.facepPicBlock) {
                            UIImage *newImage = image;
                            if (self.isMaskOutputImage) {
                                // 截取屏幕当前显示的内容image
                                self.dateilsView.alpha = 1;
                                self.undoBtn.hidden = YES;
                                self.confirmBtn.hidden = YES;
                                
//                                UIGraphicsBeginImageContextWithOptions(self.dateilsView.frame.size, YES, 0);
//                                [[self.dateilsView layer] renderInContext:UIGraphicsGetCurrentContext()];
//                                UIImage *imag = UIGraphicsGetImageFromCurrentImageContext();
//                                UIGraphicsEndImageContext();
//
//                                CGImageRef ima = imag.CGImage;
//                                UIImage *sendImag = [UIImage imageWithCGImage:ima];
//                                // 在屏幕显示的内容中截取image
//                                newImage = [sendImag imageFromImageinRect:self.maskCropRect];
                                newImage = self.disposeImageBlock(self.dateilsView,self.maskCropRect);

                                NSData *newData = UIImageJPEGRepresentation(newImage, 1);
                                self.dateilsView.imageView.image = newImage;
                                self.facepPicBlock(newImage,newData);
                            }else{
                                self.facepPicBlock(newImage,data);
                            }
                        }
                        if (self.isSavePhoto) {
                            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                });
            });
        }];
    }
}

/// 获取拍照的图片
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error  API_AVAILABLE(ios(10.0)){
    
    self.cameraBtn.enabled = YES;
    [self.session stopRunning];
    NSData *jpegData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
//    NSData *data = [UIImage resetSizeOfImageData:[UIImage fixOrientation:[UIImage imageWithData:jpegData]] maxSize:100];
    UIImage *image = [UIImage imageWithData:jpegData];
    
    self.dateilsView.imageView.image = image;
    
    NSData *data = jpegData;
    // 判断要不要压缩
    if (self.imageSize != 0) {
        data = [UIImage resetSizeOfImageData:[UIImage fixOrientation:[UIImage imageWithData:jpegData]] maxSize:self.imageSize];
    }
    
    if (self.isEdit) {
        self.dateilsView.alpha = 1;
        self.undoBtn.hidden = NO;
        self.confirmBtn.hidden = NO;
        self.albumBtn.hidden = YES;
        self.cameraBtn.hidden = YES;
        self.exchangeCamera.hidden = YES;
    }else{
        if (self.facepPicBlock != nil) {
            UIImage *newImage = image;
            if (self.isMaskOutputImage) {
                // 截取屏幕当前显示的内容image
                self.dateilsView.alpha = 1;
                self.undoBtn.hidden = YES;
                self.confirmBtn.hidden = YES;
                
//                UIGraphicsBeginImageContextWithOptions(self.dateilsView.frame.size, YES, 0);
//                [[self.dateilsView layer] renderInContext:UIGraphicsGetCurrentContext()];
//                UIImage *imag = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();

//                CGImageRef ima = imag.CGImage;
//                UIImage *sendImag = [UIImage imageWithCGImage:ima];
//                // 在屏幕显示的内容中截取image
//                newImage = [sendImag imageFromImageinRect:self.maskcCropRect];
                
                newImage = self.disposeImageBlock(self.dateilsView,self.maskCropRect);
                NSData *newData = UIImageJPEGRepresentation(newImage, 1);
                self.facepPicBlock(newImage,newData);
            }else{
                self.facepPicBlock(newImage,data);
            }
        }
        if (self.isSavePhoto) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 相册回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.dateilsView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.dateilsView.imageView.image = image;
        self.dateilsView.alpha = 1;
        self.undoBtn.hidden = NO;
        self.confirmBtn.hidden = NO;
        self.albumBtn.hidden = YES;
        self.cameraBtn.hidden = YES;
        self.exchangeCamera.hidden = YES;
    }else{
        [self.session startRunning];
    }
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.session startRunning];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error == nil) {
        NSLog(@"保存成功");
    }else{
        NSLog(@"保存失败");
    }
}

/**
 切换摄像头按钮的点击方法的实现
 */
-(void)changeButtonAction{
    //获取摄像头的数量（该方法会返回当前能够输入视频的全部设备，包括前后摄像头和外接设备）
//    NSInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
//    //摄像头的数量小于等于1的时候直接返回
//    if (cameraCount <= 1) {
//        return;
//    }
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    //获取当前相机的方向（前/后）
    AVCaptureDevicePosition position = [[self.input device] position];
    
    if (position == AVCaptureDevicePositionFront) {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }else if (position == AVCaptureDevicePositionBack){
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }
    //输入流
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    if (newInput != nil) {
        [self.session beginConfiguration];
        //先移除原来的input
        [self.session removeInput:self.input];
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
            self.input = newInput;
        }else{
            //如果不能加现在的input，就加原来的input
            [self.session addInput:self.input];
        }
        [UIView animateWithDuration:1 animations:^{
            [self.session commitConfiguration];
        }];
    }
    
}

-(AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *devicesIOS10 = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        
        NSArray *devicesIOS  = devicesIOS10.devices;
        for (AVCaptureDevice *device in devicesIOS) {
            if ([device position] == position) {
                return device;
            }
        }
        return nil;
    }else{
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices )
            if ( device.position == position )
                return device;
        return nil;
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

//- (void)camerImage:(UIImage *)image{
//    CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
//    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
//    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
//
//    //所有的人脸数据
//    NSArray* features = [detector featuresInImage:ciimage];
//    if(features.count>0) {
//        NSLog(@"检测到%lu",(unsigned long)features.count);
//    }
//    CIFaceFeature*face = [features firstObject];
//    if (face.hasSmile) {
//        NSLog(@"有微笑");
//    }
//    if (face.leftEyeClosed) {
//        NSLog(@"左眼闭着的");
//    }
//    if (face.rightEyeClosed) {
//        NSLog(@"右眼闭着的");
//    }
//    if (face.hasLeftEyePosition) {
//        NSLog(@"左眼位置：%@",NSStringFromCGPoint(face.leftEyePosition));
//    }
//    if (face.hasRightEyePosition) {
//        NSLog(@"右眼位置：%@",NSStringFromCGPoint(face.rightEyePosition));
//    }
//    if (face.hasMouthPosition) {
//        NSLog(@"嘴巴位置：%@",NSStringFromCGPoint(face.mouthPosition));
//    }
//    NSLog(@"脸部区域：%@",NSStringFromCGRect(face.bounds));
//    if(face.bounds.size.width == face.bounds.size.height) {
//        NSLog(@"脸蛋是圆的");
//    }
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end
