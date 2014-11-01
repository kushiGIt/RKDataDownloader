//
//  RKFileDownloadInfo.m
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/01.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import "RKFileDownloadInfo.h"

@implementation RKFileDownloadInfo
-(id)initWithDownloadSource:(NSString *)source{
    
    dispatch_semaphore_t semaphone =dispatch_semaphore_create(0);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        
        if (self == [super init]) {
            
            self.downloadSource = source;
            self.downloadProgress = 0.0;
            self.isDownloading = NO;
            self.downloadComplete = NO;
            self.taskIdentifier = -1;
        
        }
        
        dispatch_semaphore_signal(semaphone);
    
    });
    
    dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
    
    return self;
}
@end
