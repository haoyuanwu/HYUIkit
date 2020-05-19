//
//  BaseRequest.m
//  BaiLingDoctor
//
//  Created by 吴昊原 on 2018/8/1.
//  Copyright © 2018 msun. All rights reserved.
//

#import "BaseRequest.h"
#import <AFNetworking.h>

@implementation BaseRequest

- (void)postHttpRequestWithComplete:(responeseComplete)complete{
    //2.下载管理类的对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //3.告知默认传输的数据类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *url = [[self BaseUrl] stringByAppendingString:[self serverUrl]];
    NSDictionary *parameters = [self parameters];
    NSLog(@"请求地址(post)：%@ \n 请求参数:%@",url,parameters);
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        BaseRequest *baseReq = [self requestWithObject:dic];
        complete(YES,baseReq.responeseObect,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        complete(NO,nil,error);
    }];
}

- (void)GetHttpRequestWithComplete:(responeseComplete)complete{
    //2.下载管理类的对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //3.告知默认传输的数据类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [[self BaseUrl] stringByAppendingString:[self serverUrl]];
    NSDictionary *parameters = [self parameters];
    NSLog(@"请求地址(get)：%@ \n 请求参数:%@",url,parameters);
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        BaseRequest *baseReq = [self requestWithObject:dic];
        complete(YES,baseReq.responeseObect,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        complete(NO,nil,error);
    }];
}

- (NSString *)serverUrl{
    return @"";
}

- (NSString *)BaseUrl{
    return @"";
}

- (NSDictionary *)parameters{
    return @{};
}

- (BaseRequest *)requestWithObject:(id)Object{
    return [[BaseRequest alloc] init];
}


+ (void)PostHttpRequestWithUrl:(NSString *)url parameters:(NSDictionary *)parameters Complete:(responeseComplete)complete{
    //2.下载管理类的对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //3.告知默认传输的数据类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            complete(YES,dic,nil);
        }else{
            complete(YES,responseObject,nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s === 请求报错：%@",__func__,error.description);
        complete(NO,nil,error);
    }];
}



+ (void)GetHttpRequestWithUrl:(NSString *)url parameters:(NSDictionary *)parameters Complete:(responeseComplete)complete{
    //2.下载管理类的对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //3.告知默认传输的数据类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            complete(YES,dic,nil);
        }else{
            complete(YES,responseObject,nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s === 请求报错：%@",__func__,error.description);
        complete(NO,nil,error);
    }];
}

+ (void)PostHttpDownloadFileWithUrl:(NSString *)url
                           progress:(void(^)(NSProgress *progress))progress
                  responeseComplete:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))responeseComplete{
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    /* 下载路径 */
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress){
        progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        /* 设定下载到的位置 */
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"下载完成");
        NSURL *fileUrl = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        responeseComplete(response,fileUrl,error);
    }];
    [downloadTask resume];
    
}

/**
 上传图片
 @param completion 返回的数据
 */
+ (void)upLoadImage:(NSData *)imageData upImgurl:(NSString *)urlString fileName:(NSString *)name completion:(void (^)(id  _Nullable responseObject))completion{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"text/plain",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         nil];
    
    manager.requestSerializer.timeoutInterval = 100;
    
    //post请求
    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDate * nowDate = [NSDate date];
        NSDateFormatter*formatter = [[NSDateFormatter alloc]init];//格式化
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* startTime = [formatter stringFromDate:nowDate];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", startTime];//图片格式
        
        [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"jpg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败：%@",error);
        completion(error);
    }];
}

/// 上传多张图片每张图片不同key值
/// @param imageDatas 照片数组
/// @param urlString 请求地址
/// @param name 图片key值
/// @param completion 回调消息
+ (void)upLoadImages:(NSArray *)imageDatas upImgurl:(NSString *)urlString fileName:(NSString *)name completion:(void (^)(id  _Nullable responseObject))completion{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"text/plain",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         nil];
    
    manager.requestSerializer.timeoutInterval = 100;
    
    //post请求
    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        // formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
        // 这里的_photoArr是你存放图片的数组
        for (int i = 0; i < imageDatas.count; i++) {
            
            UIImage *image = imageDatas[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString  stringWithFormat:@"%@.jpg", dateString];
            
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpeg"]; //
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败：%@",error.localizedDescription);
        completion(error);
    }];
}


/// 上传多张图片每张图片不同key值
/// @param images 照片数组
/// @param urlString 请求地址
/// @param names key值数组
/// @param completion 回调消息
+ (void)upLoadImages:(NSArray *)images upImgurl:(NSString *)urlString fileNames:(NSArray *)names completion:(void (^)(id  _Nullable responseObject))completion{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"text/plain",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         nil];
    
    manager.requestSerializer.timeoutInterval = 100;
    
    //post请求
    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        // formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
        // 这里的_photoArr是你存放图片的数组
        for (int i = 0; i < images.count; i++) {
            
            UIImage *image = images[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString  stringWithFormat:@"%@.jpg", dateString];
            NSString *name = names[i];
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpeg"]; //
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败：%@",error.localizedDescription);
        completion(error);
    }];
}

+(void)postBossDemoWithUrl:(NSString*)url param:(NSString*)param success:(void(^)(NSDictionary *dict))success  fail:(void (^)(NSError *error))fail
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];//不设置会报-1016或者会有编码问题
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; //不设置会报-1016或者会有编码问题
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //不设置会报 error 3840
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",@"text/plain",nil]];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    [request addValue:@"application/json"forHTTPHeaderField:@"Content-Type"];
    NSData *body =[param dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:body];
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject,NSError * _Nullable error) {
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        success(dic);
        
    }] resume];
}


@end
