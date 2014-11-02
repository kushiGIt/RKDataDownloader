//
//  RKDataDownloader.h
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/01.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class RKDataDownloader;

@protocol RKDataDownloaderDelegate;


@interface RKDataDownloader : NSObject<NSURLSessionDelegate>{
    
}

@property id<RKDataDownloaderDelegate>delegate;

-(void)startDownloads;

-(id)initWithUrlArray:(NSArray*)urlArray;

@end

@protocol RKDataDownloaderDelegate <NSObject>

@optional

-(void)fileDownloadProgress:(NSNumber*)progress;
-(void)didFinishDownloadData:(NSData*)data withError:(NSError*)readingDataError;
@end
