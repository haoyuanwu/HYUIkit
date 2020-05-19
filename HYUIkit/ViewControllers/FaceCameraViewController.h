//
//  FaceCameraViewController.h
//  BaiLingDoctor
//
//  Created by 吴昊原 on 2019/5/13.
//  Copyright © 2019 BaiLingDoctor. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaceCameraViewController : UIViewController

@property (strong, nonatomic) UIButton *cameraBtn;
@property (strong, nonatomic) UIButton *albumBtn;
@property (strong, nonatomic) UIView *maskBoard;

/// 是否按照裁剪区域裁剪   maskcCropRect属性必须赋值
// 当不打开相册 或 isEdit 是false/NO  该属性默认是NO  原图返回
// 设置属性为true/YES 拍照会按照maskcCropRect区域进行裁剪
@property (assign, nonatomic) bool isMaskOutputImage;
/// 蒙板内裁剪区域范围  设置isEdit为true/YES在编辑模式下默认裁剪   与isMaskOutputImage无关
@property (assign, nonatomic) CGRect maskCropRect;

@property (strong, nonatomic) UIButton *exchangeCamera;

/// 拍照编辑后的回调
@property (nonatomic,strong) void(^facepPicBlock)(UIImage *image,NSData *imageData);


/// 是否打开人脸识别框  默认NO
@property (assign, nonatomic) bool isOpenFace;

/// 打开拍照编辑模式  默认Yes
@property (assign, nonatomic) bool isEdit;
/// 是否保存到本地图片  默认NO
@property (assign, nonatomic) bool isSavePhoto;
/// 是否隐藏切换摄像头按钮
@property (assign, nonatomic) bool hiddenExchangeBtn;
/// 是否隐藏切换打开相册按钮
@property (assign, nonatomic) bool hiddenAblumBtn;

///  压缩图片  默认为0 不进行压缩   单位KB
@property (assign, nonatomic) CGFloat imageSize;

/// 此方法如果是编辑状态就一定要写  因为获取屏幕图片的方法只能在外面写有效 一下是代码
//            UIImage *image = [UIImage imageByConvertView:dateilsView relativeOriginSize:dateilsView.frame.size opaque:YES scale:0];
//            UIImage *newImage = [self imageFromImage:image inRect:rect];
@property (strong, nonatomic) UIImage*(^disposeImageBlock)(UIView *dateilsView,CGRect rect);

@end

NS_ASSUME_NONNULL_END
