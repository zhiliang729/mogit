//
//  DBAppDelegate.m
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import "DBAppDelegate.h"
#import "ZLConfigGit.h"
#import "ZLGit.h"

@implementation DBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//     Insert code here to initialize your application
    
    [ZLConfigGit clearConfig];
    
    ZLConfigGit * gitHub = [ZLConfigGit sharedInstance];
    
    gitHub.nowProject = @"git@github.com:zhiliang729/Xtrace.git";
    
    [ZLGit initWorkDir:gitHub.workDir];
    
    if ([gitHub.projectGits indexOfObject:gitHub.nowProject] == NSNotFound ){
        [gitHub.projectGits addObject:gitHub.nowProject];
    }
    [gitHub sync];
    
    ZLGit * git = [ZLGit sharedInstance];
    git.git = gitHub.nowProject;
    [git config:@"zhiliang729@163.com" withPassword:@"zhili782099"];
    
    [git clone];
    [git status];
    NSLog(@"%@", [git branchList]);
    NSLog(@"%@", [git mainBranch]);
}

@end
