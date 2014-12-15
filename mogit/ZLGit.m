//
//  ZLGit.m
//  mogit
//
//  Created by zhangliang on 14/12/15.
//  Copyright (c) 2014年 Bear. All rights reserved.
//

#import "ZLGit.h"

@interface ZLGit ()

@property (nonatomic, strong) NSDictionary * const kERROR_DICT;

- (BOOL)findString:(NSString *)s withKey:(NSString *)k;
- (NSString *)getErrorString:(NSString *)s withKey:(NSString *)k;
- (NSString *)checkError:(NSString *)r withErrors:(NSArray *)errors;

@end

static ZLGit * __instance;

@implementation ZLGit
@synthesize kERROR_DICT;

+ (ZLGit *)sharedInstance {
    if (__instance == nil) {
        __instance = [[super allocWithZone:NULL] init];
        __instance.kERROR_DICT = @{
                                   
                                   kERROR_CLONE_EXIST:kERROR_CLONE_EXIST_CN,
                                   kERROR_CLONE_FAIL:kERROR_CLONE_FAIL_CN,
                                   kERROR_STATUS_NOCHANGE:kERROR_STATUS_NOCHANGE_CN,
                                   kERROR_STATUS_NEED_MERGE:kERROR_STATUS_NEED_MERGE_CN,
                                   kERROR_STATUS_NO_REPO:kERROR_STATUS_NO_REPO_CN,
                                   kERROR_NOT_COMMITER:kERROR_NOT_COMMITER_CN,
                                   kERROR_FAIL_MERGE:kERROR_CLONE_FAIL_CN,
                                   
                                   };
    }
    return __instance;
}

- (void)config:(NSString *)name withPassword:(NSString *)password{
    NSString * cmd = [[NSString alloc] initWithFormat:@"%@ config --global user.name %@; %@ config --global user.email %@;%@ config --global push.default matching", kGIT, name, kGIT, name, kGIT];
    NSLog(@"gitConfig cmd=%@", cmd);
    NSString *ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"gitConfig ret=%@", ret);
}

- (NSString *)clone{
    NSString * workdir = [ZLConfigGit sharedInstance].workDir;
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@; %@ clone %@", workdir, kGIT, self.git];
    NSLog(@"initProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    
    NSLog(@"initProject ret=%@", ret);
    
    NSString * error = nil;
    
    if ([ret rangeOfString:kGit_Cloning].length > 0) {
        NSLog(@"%@", ret);
    }else
    {
        error = [self checkError:ret withErrors:@[kERROR_CLONE_EXIST, kERROR_CLONE_FAIL]];
    }
    
    if (error != nil) return error;
    NSString * name = [self name];
    return [[NSString alloc] initWithFormat:kCLONE_SUCCESS, name, workdir, name];
}

- (NSString *)status{
    NSString * name = [self name];
    NSString * commits = @"";
    NSString * cmd;
    NSString * ret;
    NSRange range;
    
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ status|grep \"Your branch is ahead of\"", [ZLConfigGit sharedInstance].workDir, name, kGIT];
    NSLog(@"statusProject cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", ret);
    
    if (ret.length > 0){
        commits = [ret stringByReplacingOccurrencesOfString:kSTATUS_HAS_COMMITS
                                                 withString:kSTATUS_HAS_COMMITS_CN];
        commits = [commits stringByReplacingOccurrencesOfString:kSTATUS_COMMITS
                                                     withString:kSTATUS_COMMITS_CN];
        commits = [commits stringByReplacingOccurrencesOfString:@"s"
                                                     withString:@""];
        commits = [commits stringByReplacingOccurrencesOfString:@"."
                                                     withString:@""];
    }
    
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ status|grep -v \"no changes added to commit\"|grep -v \"nothing added to commit\";", [ZLConfigGit sharedInstance].workDir, name, kGIT];
    NSLog(@"statusProject cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", ret);
    
    NSString * error = [self checkError:ret withErrors:@[kERROR_STATUS_NOCHANGE, kERROR_STATUS_NEED_MERGE, kERROR_STATUS_NO_REPO]];
    if (error != nil && [commits length] == 0) return error;
    
    
    range = [ret rangeOfString:kGit_UntrackedFile];
    NSString * newFiles = @"";
    if (range.length > 0){
        newFiles = [[ret substringFromIndex:range.location] substringFromIndex:86];
        newFiles = [newFiles stringByReplacingOccurrencesOfString:kSTATUS_NEW
                                                       withString:kSTATUS_NEW_CN];
    }
    
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ status|grep \"ed:\";", [ZLConfigGit sharedInstance].workDir, name, kGIT];
    NSLog(@"statusProject cmd=%@", cmd);
    NSString * changes = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", changes);
    if ([changes length] > 0){
        changes = [changes stringByReplacingOccurrencesOfString:kSTATUS_MODIFY
                                                     withString:kSTATUS_MODIFY_CN];
        changes = [changes stringByReplacingOccurrencesOfString:kSTATUS_DELETE
                                                     withString:kSTATUS_DELETE_CN];
    }
    
    return [[NSString alloc] initWithFormat:kSTATUS_CHANGED, commits, changes, newFiles];
}

- (NSString *)pull{
    NSString * name = [self name];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ pull",
                      [ZLConfigGit sharedInstance].workDir, name, kGIT];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    return [[NSString alloc] initWithFormat:kPULL_SUCCESS, name];
}

- (NSString *)sync:(NSString*)comment{
    NSString * name = [self name];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ add -A; %@ commit -m \"%@\"; %@ pull; %@ push origin master",
                      [ZLConfigGit sharedInstance].workDir, name, kGIT, kGIT, comment, kGIT, kGIT];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    
    NSString * error = [self checkError:ret withErrors:@[kERROR_NOT_COMMITER,kERROR_FAIL_MERGE]];
    if (error != nil) return error;
    return kPUSH_SUCCESS;
}

- (NSString *)branchList
{
    NSString * workdir = [ZLConfigGit sharedInstance].workDir;
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ branch", workdir, [self name],  kGIT];
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    
    NSArray * array = [ret componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    
    NSMutableArray * mutable = [NSMutableArray arrayWithArray:array];
    int index = -1;
    for (NSString * string in mutable) {
        index++;
        if (string.length == 0) {
            break;
        }
    }
    
    if (index != -1) {
        [mutable removeObjectAtIndex:index];
    }
    
    array = [NSArray arrayWithArray:mutable];
    
    NSString * output = [NSString stringWithFormat:@"%ld branch%@\n", array.count, (array.count > 1) ? @"es": @""];
    for (NSString * branch in array) {
        NSString * string = [branch stringByReplacingOccurrencesOfString:@"* " withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"  " withString:@""];
        output = [output stringByAppendingString:string];
        output = [output stringByAppendingString:@"\n"];
    }
    return output;
}

- (NSString *)mainBranch
{
    NSString * workdir = [ZLConfigGit sharedInstance].workDir;
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ branch", workdir, [self name], kGIT];
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    
    NSArray * array = [ret componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    
    NSString * output = [NSString stringWithFormat:@"main branch:   "];
    for (NSString * branch in array) {
        if ([branch hasPrefix:@"* "]) {
            output = [output stringByAppendingString:[branch stringByReplacingOccurrencesOfString:@"* " withString:@""]];
            break;
        }
    }
    return output;
}

+ (BOOL)checkGit{
    NSString * cmd = @"which git";
    NSLog(@"checkGit cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"checkGit ret=%@", ret);
    NSRange range = [ret rangeOfString:@"git"];
    NSLog(@"checkGit kGIT=%@", kGIT);
    if (range.length > 0) return YES;
    
    cmd = @"ls /usr/local/git/bin/git";
    NSLog(@"checkGit cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"checkGit ret=%@", ret);
    range = [ret rangeOfString:@"No such file or directory"];
    if (range.length == 0) {
        NSLog(@"checkGit kGIT=%@", kGIT);
        kGIT = kGIT_LOCAL;
        return YES;
    }
    
    cmd = @"ls /usr/bin/git";
    NSLog(@"checkGit cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"checkGit ret=%@", ret);
    range = [ret rangeOfString:@"No such file or directory"];
    if (range.length == 0) {
        NSLog(@"checkGit kGIT=%@", kGIT);
        kGIT = kGIT_ALT;
        return YES;
    }
    return NO;
    
}

+ (BOOL)checkGitConfig{
    NSString * cmd = [[NSString alloc] initWithFormat:@"grep \"%@\" ~/.netrc", kHOST];
    NSLog(@"checkGitConfig cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    if ([ret length] > 35){
        NSLog(@"checkGitConfig ret=%@", [ret substringToIndex:35]);
    }
    NSRange range = [ret rangeOfString:kHOST];
    return range.length > 0;
}

+ (BOOL)checkNetwork{
    NSString * cmd = [[NSString alloc] initWithFormat:@"ping -c 1 %@", kHOST];
    NSLog(@"checkNetWork cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"checkNetWork ret=%@", ret);
    NSRange r1 = [ret rangeOfString:@"100.0% packet loss"];
    NSRange r2 = [ret rangeOfString:@"cannot resolve"];
    return r1.length == 0 && r2.length == 0;
}

+ (NSString *)initWorkDir:(NSString *)dir{
    NSString * cmd = [[NSString alloc] initWithFormat:@"mkdir -p %@", dir];
    NSLog(@"initWorkDir cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initWorkDir ret=%@", ret);
    return ret;
}

- (NSString *)name{
    return [[self.git lastPathComponent] stringByDeletingPathExtension];
}

- (BOOL)findString:(NSString *)s withKey:(NSString *)k{
    NSRange range = [s rangeOfString:k];
    return range.length > 0;
}

- (NSString *)getErrorString:(NSString *)s withKey:(NSString *)k{
    NSRange range = [s rangeOfString:k];
    NSLog(@"checkError by %@ find %ld", k, range.length);
    if (range.length > 0){
        return [self.kERROR_DICT objectForKey:k];
    }
    return nil;
}

- (NSString *)checkError:(NSString *)r withErrors:(NSArray *)errors{
    NSString * ret;
    for (NSString * error in errors) {
        ret = [self getErrorString:r withKey:error];
        if (ret != nil){
            return ret;
        }
    }
    return nil;
}

@end
