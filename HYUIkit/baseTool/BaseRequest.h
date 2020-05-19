//
//  BaseRequest.h
//  BaiLingDoctor
//
//  Created by 吴昊原 on 2018/8/1.
//  Copyright © 2018 msun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^responeseComplete)(BOOL isSuccessful,id _Nullable responeseObject,NSError * _Nullable error);

@interface BaseRequest : NSObject

@property (nonatomic,strong)id _Nullable responeseObect;

- (void)postHttpRequestWithComplete:(responeseComplete _Nullable )complete;

- (void)GetHttpRequestWithComplete:(responeseComplete _Nullable )complete;

- (NSString *_Nonnull)serverUrl;

- (NSString *_Nonnull)BaseUrl;

- (NSDictionary *_Nonnull)parameters;

- (BaseRequest *_Nonnull)requestWithObject:(id _Nullable )Object;

+ (void)PostHttpRequestWithUrl:(NSString *_Nonnull)url parameters:(NSDictionary *_Nullable)parameters Complete:(responeseComplete _Nonnull )complete;
+ (void)GetHttpRequestWithUrl:(NSString *_Nonnull)url parameters:(NSDictionary *_Nullable)parameters Complete:(responeseComplete _Nonnull )complete;

/**
 下载文件

 @param url 请求地hi
 @param progress 下载进度
 */
+ (void)PostHttpDownloadFileWithUrl:(NSString *_Nonnull)url
                           progress:(void(^_Nullable)(NSProgress * _Nullable progress))progress
                  responeseComplete:(void (^_Nullable)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))responeseComplete;

/**
 上传图片

 @param imageData 图片流
 @param urlString 上传地址i
 @param name file
 */
+ (void)upLoadImage:(NSData * _Nonnull )imageData upImgurl:(NSString * _Nonnull)urlString fileName:(NSString * _Nonnull )name completion:(void (^_Nullable)(id  _Nullable responseObject))completion;

/**
 上传图片

 @param imageDatas 图片数组
 @param urlString 上传地址
 @param name 图片名称
 */
+ (void)upLoadImages:(NSArray *_Nonnull)imageDatas upImgurl:(NSString * _Nonnull )urlString fileName:(NSString * _Nullable )name completion:(void (^_Nonnull)(id _Nullable responseObject))completion;


/// 上传多图多key值
/// @param imageDatas 图片数组
/// @param urlString 请求地址
/// @param names key数组
/// @param completion 回调函数
+ (void)upLoadImages:(NSArray * _Nonnull)imageDatas upImgurl:(NSString * _Nonnull)urlString fileNames:(NSArray *_Nonnull)names completion:(void (^ _Nonnull)(id  _Nullable responseObject))completion;

+(void)postBossDemoWithUrl:(NSString * _Nonnull)url param:(NSString *_Nonnull)param success:(void(^_Nullable)(NSDictionary * _Nullable dict))success fail:(void (^ _Nullable)(NSError * _Nullable error))fail;

@end
