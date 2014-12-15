//
//  ZLGit.h
//  mogit
//
//  Created by zhangliang on 14/12/15.
//  Copyright (c) 2014年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShellTask.h"
#import "ZLConfigGit.h"

static NSString * const kHOST = @"code.dapps.douban.com";
static NSString * const kERROR_CLONE_FAIL = @"not found";
static NSString * const kERROR_CLONE_FAIL_CN = @"请检查git地址，初始化项目失败";
static NSString * const kERROR_CLONE_EXIST = @"already exists";
static NSString * const kERROR_CLONE_EXIST_CN = @"本地已经存在项目目录";
static NSString * const kERROR_INVALID_GIT_CN = @"请输入合法的git地址";
static NSString * const kCLONE_SUCCESS = @"项目%@成功初始化到本地目录：%@/%@";
static NSString * const kERROR_STATUS_NO_REPO = @"No such file or directory";
static NSString * const kERROR_STATUS_NO_REPO_CN = @"本地项目目录不存在，请重新设定项目地址";
static NSString * const kERROR_STATUS_NOCHANGE = @"nothing to commit";
static NSString * const kERROR_STATUS_NOCHANGE_CN = @"当前项目没有任何改动";
static NSString * const kERROR_STATUS_NEED_MERGE = @"both modified";
static NSString * const kERROR_STATUS_NEED_MERGE_CN = @"发生冲突，请联系和你合作的工程师帮助解决!!";
static NSString * const kSTATUS_CHANGED = @"当前项目本地改动:\n%@\n%@\n%@\n";
static NSString * const kSTATUS_HAS_COMMITS = @"# Your branch is ahead of 'origin/master' by";
static NSString * const kSTATUS_HAS_COMMITS_CN = @"当前已经提交到本地的有";
static NSString * const kSTATUS_COMMITS = @"commit";
static NSString * const kSTATUS_COMMITS_CN = @"个改动\n请联系和你合作的工程师，检查GIT帐号配置!!\n并且把你加为当前项目的commiter!!";
static NSString * const kSTATUS_NEW = @"#	";
static NSString * const kSTATUS_NEW_CN = @"新加了:\t";
static NSString * const kSTATUS_MODIFY = @"#	modified:   ";
static NSString * const kSTATUS_MODIFY_CN = @"修改了:\t";
static NSString * const kNEED_PUSH = @"Your branch is ahead of";
static NSString * const kSTATUS_DELETE = @"#	deleted:    ";
static NSString * const kSTATUS_DELETE_CN = @"删除了:\t";
static NSString * const kPULL_SUCCESS = @"你真棒！已经同步%@项目最新修改到本地";
static NSString * const kERROR_NOT_COMMITER = @"fatal: could not read Username";
static NSString * const kERROR_NOT_COMMITER_CN = @"提交失败，请联系和你合作的工程师，检查GIT帐号配置!!\n并且把你加为当前项目的commiter!!";
static NSString * const kERROR_FAIL_MERGE = @"Failed to merge";
static NSString * const kERROR_FAIL_MERGE_CN = @"你的修改提交到远端时发生冲突，请联系和你合作的工程师帮助解决";
static NSString * const kPUSH_SUCCESS = @"你真棒！ 已经成功将你的修改提交到远端 ：）";
static NSString * const kGIT_LOCAL = @"/usr/local/git/bin/git";
static NSString * const kGIT_ALT = @"/usr/bin/git";
static NSString * const kGit_UntrackedFile = @"Untracked files";
static NSString * const kGit_Cloning = @"Cloning into ";

static NSString * kGIT = @"git";

@interface ZLGit : NSObject

@property (nonatomic, strong) NSString * git;

- (void)config:(NSString *)name withPassword:(NSString *)password;
- (NSString *)clone;
- (NSString *)status;
- (NSString *)pull;
- (NSString *)sync:(NSString*)comment;

- (NSString *)branchList;
- (NSString *)mainBranch;


+ (BOOL)checkGit;
+ (BOOL)checkGitConfig;
+ (BOOL)checkNetwork;
+ (NSString *)initWorkDir:(NSString *)dir;
+ (ZLGit *)sharedInstance;

@end
