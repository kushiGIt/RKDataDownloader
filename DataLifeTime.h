//
//  DataLifeTime.h
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/10.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataLifeTime : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * key;
@property (nonatomic) NSDate * object_LifeTime;

@end
