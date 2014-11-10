//
//  RKDataDownloader.m
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/01.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import "RKDataDownloader.h"


@interface RKDataDownloader()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSURLSessionDownloadTask *sessionTask;

@property (nonatomic) NSMutableDictionary*taskDataDic;

@property (nonatomic) double taskCount;

@property (nonatomic) int completeTaskCount;

@property (nonatomic) NSMutableDictionary*complrteDataDic;

@property (nonatomic) NSMutableDictionary*completeDataErrorDic;

@property BOOL isInitWithArray;

@end

@implementation RKDataDownloader{
    NSCache*dataCashe;
}

-(id)initWithUrlArray_background:(NSArray*)urlArray{
    
    dispatch_semaphore_t semaphone =dispatch_semaphore_create(0);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        
        if (self==[super init]) {
            
            [self saveContext];
            
            self.taskDataDic=[[NSMutableDictionary alloc]init];
            self.completeDataErrorDic=[[NSMutableDictionary alloc]init];
            self.complrteDataDic=[[NSMutableDictionary alloc]init];
            
            for (NSString*sorceURL in [self encodeUrlFromJapaneseUrl:urlArray]) {
                
                [self.taskDataDic setObject:[NSNumber numberWithDouble:0.0] forKey:sorceURL];
            
            }
            
            self.taskCount=(double)self.taskDataDic.count;
            
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.RKDownloader"];
            sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
            
            self.session=[NSURLSession sessionWithConfiguration:sessionConfiguration delegate:(id)self delegateQueue:nil];
            
            self.isInitWithArray=YES;
            
            self.completeTaskCount=0;
        
        }
        
        dispatch_semaphore_signal(semaphone);
    
    });
    
    dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
    
    return self;
}
-(id)initWithUrlArray_defaults:(NSArray *)urlArray{
    
    dispatch_semaphore_t semaphone =dispatch_semaphore_create(0);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        
        if (self==[super init]) {
            
            self.taskDataDic=[[NSMutableDictionary alloc]init];
            self.completeDataErrorDic=[[NSMutableDictionary alloc]init];
            self.complrteDataDic=[[NSMutableDictionary alloc]init];
            
            for (NSString*sorceURL in [self encodeUrlFromJapaneseUrl:urlArray]) {
                
                [self.taskDataDic setObject:[NSNumber numberWithDouble:0.0] forKey:sorceURL];
                
            }
            
            self.taskCount=(double)self.taskDataDic.count;
            
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
            
            self.session=[NSURLSession sessionWithConfiguration:sessionConfiguration delegate:(id)self delegateQueue:nil];
            
            self.isInitWithArray=YES;
            
            self.completeTaskCount=0;
            
        }
        
        dispatch_semaphore_signal(semaphone);
        
    });
    
    dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
    
    return self;
    
}
-(void)startDownloads{
    
    if (self.isInitWithArray==YES) {
        
        for (int i=0; i<[self.taskDataDic.allKeys count]; i++) {
            
            self.sessionTask = [self.session downloadTaskWithURL:[NSURL URLWithString:self.taskDataDic.allKeys[i]]];
            [self.sessionTask resume];
            
        }
        
        self.isInitWithArray=NO;
    
    }else{
        
        [[NSException exceptionWithName:@"RKDownloader init exception" reason:@"you must use -(void)initWithArray: first. You musu not use -(id)init." userInfo:nil]raise];
        
    }
    
    
}
#pragma mark - NSURLSession Delegate method implementation
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    if ([self.delegate respondsToSelector:@selector(didFinishDownloadData:withError:dataWithUrl:)] || [self.delegate respondsToSelector:@selector(didFinishAllDownloadsWithDataDictinary:withErrorDic:)]) {
        
        __block NSError*readingDataError;
        __block NSData*downloededData;
        __block NSString*urlStr;
        
        dispatch_semaphore_t semaphone =dispatch_semaphore_create(0);
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
            
            downloededData=[NSData dataWithContentsOfURL:location options:NSDataReadingUncached error:&readingDataError];
            urlStr=[NSString stringWithFormat:@"%@",[[downloadTask originalRequest]URL]];
            
            if (downloededData.length==0) {
                
                [self.complrteDataDic setObject:[NSNull null] forKey:urlStr];
                
            }else{
                
                [self.complrteDataDic setObject:downloededData forKey:urlStr];
                
            }
            
            if (readingDataError==nil) {
                
                 [self.completeDataErrorDic setObject:[NSNull null] forKey:urlStr];
            
            }else{
                
                [self.completeDataErrorDic setObject:readingDataError forKey:urlStr];
            
            }
            
            dispatch_semaphore_signal(semaphone);
        
        });
        dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
        
        if ([self.delegate respondsToSelector:@selector(didFinishDownloadData:withError:dataWithUrl:)]) {
            
            [self.delegate didFinishDownloadData:downloededData withError:readingDataError dataWithUrl:urlStr];
            
        }
        
    }

}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if (error != nil) {
        
        NSLog(@"Download completed with error: %@",error);
        NSLog(@"%@",[NSString stringWithFormat:@"%@",[[task originalRequest]URL]]);
        
        [self.complrteDataDic setObject:[NSNull null] forKey:[NSString stringWithFormat:@"%@",[[task originalRequest]URL]]];
        [self.completeDataErrorDic setObject:error forKey:[NSString stringWithFormat:@"%@",[[task originalRequest]URL]]];
        self.completeTaskCount--;
        self.taskCount--;
        
        
    }else{
        
        NSLog(@"Download finished successfully.");
        
    }
    
    self.completeTaskCount++;

    
    
    if ([self.delegate respondsToSelector:@selector(didFinishAllDownloadsWithDataDictinary:withErrorDic:)]){
        
        if (self.completeTaskCount==self.taskCount) {
            
            [self.delegate didFinishAllDownloadsWithDataDictinary:self.complrteDataDic withErrorDic:self.completeDataErrorDic];
            
        }
    }
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        
        NSLog(@"Unknown transfer size");
        
    }else{
        
        if ([self.delegate respondsToSelector:@selector(fileDownloadProgress:)]) {
            
            __block double progress=0.0;
            
            
            [self.taskDataDic setObject:[NSNumber numberWithDouble:(double)totalBytesWritten / (double)totalBytesExpectedToWrite] forKey:[NSString stringWithFormat:@"%@",[[downloadTask originalRequest]URL]]];
            
            
            dispatch_group_t group = dispatch_group_create();
            NSLock *RegulationsInProgress;
            
            for (NSNumber *progressNum in [self.taskDataDic allValues]) {
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_group_async(group, queue, ^{
                    
                    [RegulationsInProgress lock];
                    
                    @try {
                        
                        progress=progress+[progressNum doubleValue];
                    
                    }
                    @finally {
                        
                        [RegulationsInProgress unlock];
                    
                    }
                
                });
            
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            
            [self.delegate fileDownloadProgress:[NSNumber numberWithDouble:progress/self.taskCount]];
            
        }
        
    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([downloadTasks count] == 0) {
            
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    completionHandler();
                    
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"ダウンロードが完了しました。";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                
                }];
            }
        }
    }];

}
-(NSArray*)encodeUrlFromJapaneseUrl:(NSArray*)originalUrlArray{
    
    NSLock*addArrayLock=[[NSLock alloc]init];
    NSMutableArray*encodedUrlArray=[[NSMutableArray alloc]init];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    for (NSString*urlStr in originalUrlArray) {
        
    dispatch_group_async(group, queue, ^{
        
        [addArrayLock lock];
        
        @try {
            
            CFStringRef originalString=(__bridge CFStringRef)urlStr;
            CFStringRef encodedString=CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,originalString,NULL,(CFStringRef)@"<>{}|^[]`", kCFStringEncodingUTF8);
            NSString*escapedUrl=(__bridge NSString*)encodedString;
            
            [encodedUrlArray addObject:escapedUrl];
        
        }
        @finally {
            
            [addArrayLock unlock];
        
        }
    
    });
    
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    return encodedUrlArray;
}
#pragma mark - Cheak duplication url
+(NSArray*)cheakDuplicationURLString:(NSArray*)needCheakArray cheakDuplicateFromCashe:(BOOL)isCheakDuplicationCashe cheakDuplicateFromURLArray:(BOOL)isCheakDuplicationArray withCasheKey:(NSString*)keyStr{
    
    __block NSSet*set;
    __block NSCache*dataCashe=[[NSCache alloc]init];
    
    dispatch_semaphore_t semaphone =dispatch_semaphore_create(0);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        
        if (isCheakDuplicationCashe&&isCheakDuplicationArray) {
            
            NSMutableArray*allKeys=[[NSMutableArray alloc]initWithArray:[[dataCashe objectForKey:keyStr] allKeys]];
            [allKeys addObjectsFromArray:needCheakArray];
            
            set=[[NSSet alloc]initWithArray:allKeys];
            
            
        }else if(isCheakDuplicationArray){
            
            set=[[NSSet alloc]initWithArray:needCheakArray];
            
        }else if (isCheakDuplicationCashe){
            
            NSMutableArray*allKeys=[[NSMutableArray alloc]initWithArray:[[dataCashe objectForKey:keyStr] allKeys]];
            [allKeys addObjectsFromArray:needCheakArray];
            
            set=[[NSSet alloc]initWithArray:allKeys];
            
        }
        
        
        dispatch_semaphore_signal(semaphone);
        
    });
    
    dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
    
    
    return [set allObjects];
    
}
#pragma mark - save to coredata
- (NSURL*)createStoreURL {
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *path = [[directories lastObject] stringByAppendingPathComponent:@"RKDataDownloader.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    
    return storeURL;

}
- (NSURL*)createModelURL {
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *path = [mainBundle pathForResource:@"RKDataLifeTimeModel" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:path];
    
    return modelURL;

}
- (NSManagedObjectContext*)createManagedObjectContext {
    
    NSURL *modelURL = [self createModelURL];
    NSURL *storeURL = [self createStoreURL];
    
    NSError *error = nil;
    
    NSManagedObjectModel *managedObjectModel=[[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    NSManagedObjectContext *managedObjectContent = [[NSManagedObjectContext alloc] init];
    [managedObjectContent setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    return managedObjectContent;

}
-(void)saveContext{
    
    /*
     
     NSManagedObject * checkForDuplicate = [self checkDupulicationInEntity:NSStringFromClass([Hoge class])  withKey:@"hoge" withValue:@"hogehoge"];
     if (regionCheckForDuplicate == NULL) {
     
     }else{
     
     }
     
     */
    
    NSManagedObjectContext*context=[[NSManagedObjectContext alloc]init];
    context=[self createManagedObjectContext];
    
    DataLifeTime*dataInfo=[NSEntityDescription insertNewObjectForEntityForName:@"DataLifeTime" inManagedObjectContext:context];
    
    dataInfo.data=[[NSString stringWithFormat:@"test data"] dataUsingEncoding:NSUTF8StringEncoding];
    dataInfo.key=@"a";
    dataInfo.object_LifeTime=10.5f;
    
    NSError *error = nil;
    
    if([context save:&error]) {
        
        NSLog(@"Save object to CoreData successfully");
        
    } else {
        
        NSLog(@"Save object to CoreData unsuccessfully");
        
    }
    
    [self getContext];
    
}
-(void)getContext{
    
    NSManagedObjectContext*context=[[NSManagedObjectContext alloc]init];
    context=[self createManagedObjectContext];
    
    NSEntityDescription*entity=[NSEntityDescription entityForName:@"DataLifeTime" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    
    NSString *searchString = @"a";
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"key == %@",searchString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];
    
    if([fetchResults count] > 0) {
        
        NSMutableString *str = [NSMutableString stringWithFormat:@"Found %lu Datas \n",(unsigned long)[fetchResults count]];
        int i = 0;
        for (DataLifeTime *ent in fetchResults) {
            [str appendFormat:@"Num:%d key:%@ data:%@ life_time:%f \n",i,ent.key,ent.data,ent.object_LifeTime];
            i++;
        }
        
        NSLog(@"%@",str);
        
    } else {
        
        NSLog(@"Data is None!");
    
    }
    
}
-(void)deleteEntityInDataLifeTime{
    
    NSManagedObjectContext*managedObjectContext=[[NSManagedObjectContext alloc]init];
    managedObjectContext=[self createManagedObjectContext];
    
    NSFetchRequest * requestDelete = [[NSFetchRequest alloc] init];
    [requestDelete setEntity:[NSEntityDescription entityForName:@"DataLifeTime" inManagedObjectContext:managedObjectContext]];
    [requestDelete setIncludesPropertyValues:NO];
    
    NSError * error = nil;
    NSArray * dataArray = [managedObjectContext executeFetchRequest:requestDelete error:&error];
    
    for (NSManagedObject * data in dataArray) {
        [managedObjectContext deleteObject:data];
    }
    
    NSError *saveError = nil;
    if([managedObjectContext save:&saveError]) {
        
        NSLog(@"Delete object to CoreData successfully");
        
    } else {
        
        NSLog(@"Delete object to CoreData unsuccessfully");
        
    };

}
- (NSManagedObject *)checkDupulicationInEntity:(NSString *) entityName withKey:(NSString *)keyString withValue:(NSString *)valueString{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", keyString, valueString];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [[self createManagedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    if (results.count > 0) {
        return [results objectAtIndex:0];
    }
    
    return NULL;
}
@end
