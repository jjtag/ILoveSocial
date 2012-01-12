//
//  NewFeedSharePhoto+Addition.h
//  SocialFusion
//
//  Created by He Ruoyun on 12-1-12.
//  Copyright (c) 2012年 TJU. All rights reserved.
//

#import "NewFeedSharePhoto.h"

@interface NewFeedSharePhoto (Addition)
+ (NewFeedSharePhoto *)insertNewFeed:(int)sytle getDate:(NSDate*)getDate Owner:(User*)myUser Dic:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NewFeedSharePhoto *)feedWithID:(NSString *)statusID inManagedObjectContext:(NSManagedObjectContext *)context;
-(NSString*)getName;
-(NSString*)getShareComment;
-(NSString*)getPhotoComment;
@end