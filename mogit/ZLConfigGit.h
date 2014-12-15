//
//  ZLConfigGit.h
//  mogit
//
//  Created by zhangliang on 14/12/15.
//  Copyright (c) 2014年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZLConfigGit : NSObject

@property (nonatomic, strong) NSString * workDir;
@property (nonatomic, strong) NSString * nowProject;
@property (nonatomic, strong) NSMutableArray * projectGits;

+ (void)clearConfig;

+ (ZLConfigGit *)sharedInstance;

- (void)sync;

@end
