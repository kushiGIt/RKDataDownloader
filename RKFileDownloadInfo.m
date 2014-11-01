//
//  RKFileDownloadInfo.m
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/01.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import "RKFileDownloadInfo.h"

@implementation RKFileDownloadInfo
-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source{
    
    if (self == [super init]) {
        self.fileTitle = title;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
    }
    
    return self;
}
@end
