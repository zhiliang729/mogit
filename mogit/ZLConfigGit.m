//
//  ZLConfigGit.m
//  mogit
//
//  Created by zhangliang on 14/12/15.
//  Copyright (c) 2014年 Bear. All rights reserved.
//

#import "ZLConfigGit.h"
#import "ShellTask.h"

static NSString * kDBPlistPath;
static NSString * const kDBPlistName = @"mogit.plist";
static NSString * const kWORKDIR = @"WORK_DIR";
static NSString * const kDefaultWorkDir = @"~/Desktop/ZLgit";
static NSString * const kPROJECTS = @"PROJECT_GITS";
static NSString * const kNOW_PROJECT = @"NOW_PROJECT";

static ZLConfigGit * __instance;

@implementation ZLConfigGit

- (void)sync{
    NSDictionary * _dict = @{kWORKDIR:self.workDir, kNOW_PROJECT:self.nowProject, kPROJECTS:self.projectGits};
    NSLog(@"sync config=%@", _dict);
    [_dict writeToFile:kDBPlistPath atomically:YES];
}

+ (void)clearConfig
{
    NSString * dir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString * bundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString * cmd = [[NSString alloc] initWithFormat:@"rm -r \"%@/%@\"", dir, bundle];
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    if (ret.length > 0) {
        NSLog(@"error:%@", ret);
    }
}

+ (ZLConfigGit *)sharedInstance {
    if (__instance == nil) {
        NSLog(@"get config from %@", kDBPlistName);
        NSString * dir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
        NSLog(@"get suppor dir %@", dir);
        NSString * bundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSLog(@"get bundle %@", bundle);
        NSString * cmd = [[NSString alloc] initWithFormat:@"mkdir -p \"%@/%@\"", dir, bundle];
        NSLog(@"mkdir config dir cmd=%@", cmd);
        NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
        NSLog(@"mkdir config ret=%@", ret);
        kDBPlistPath = [[NSString alloc] initWithFormat:@"%@/%@/%@", dir, bundle, kDBPlistName];
        NSLog(@"config path=%@", kDBPlistPath);
        
        __instance = [[super allocWithZone:NULL] init];
        NSDictionary * _dict = [NSDictionary dictionaryWithContentsOfFile:kDBPlistPath];
        if (_dict == nil){
            _dict = @{kWORKDIR:kDefaultWorkDir, kNOW_PROJECT:@"", kPROJECTS:@[]};
            [_dict writeToFile:kDBPlistName atomically:YES];
            NSLog(@"init config=%@", _dict);
        }
        __instance.workDir = [_dict objectForKey:kWORKDIR];
        __instance.projectGits = [[NSMutableArray alloc] initWithArray:[_dict objectForKey:kPROJECTS]];
        __instance.nowProject = [_dict objectForKey:kNOW_PROJECT];
    }
    NSLog(@"get config now project=%@", __instance.nowProject);
    
    return __instance;
}

@end
