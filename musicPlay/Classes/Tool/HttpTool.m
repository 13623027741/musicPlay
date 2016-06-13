//
//  HttpTool.m
//  MusicPlay
//
//  Created by kaidan on 16/6/3.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "HttpTool.h"

@implementation HttpTool

+(void)POST:(NSString *)URLString
                            parameters:(id)parameters
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure{
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"下载进度%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

+(void)GET:(NSString *)URLString
                            parameters:(id)parameters
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure{

    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
