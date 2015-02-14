//
//  SharedNetworking.h
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedNetworking : NSObject

+ (id)sharedNetworking;

- (void)getFeedForURL:(NSString*)url
              success:(void (^)(NSDictionary *dictionary, NSError *error))successCompletion
              failure:(void (^)(void))failureCompletion;

@end
