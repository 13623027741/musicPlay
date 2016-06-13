//
//  HttpTool.h
//  MusicPlay
//
//  Created by kaidan on 16/6/3.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface HttpTool : NSObject


+(void)POST:(NSString *)URLString
                             parameters:(id)parameters
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(NSError *error))failure;

+(void)GET:(NSString *)URLString
                            parameters:(id)parameters
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure;

@end
