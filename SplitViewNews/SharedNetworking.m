//
//  SharedNetworking.m
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import "SharedNetworking.h"

@implementation SharedNetworking

+ (id)sharedNetworking {
    static dispatch_once_t pred;
    static SharedNetworking *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)getFeedForURL:(NSString*)url
              success:(void (^)(NSDictionary *dictionary, NSError *error))successCompletion
              failure:(void (^)(void))failureCompletion {
    
    // Create NSUrlSession
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Create data download tasks
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                
                NSLog(@"Data:%@",data);
                NSLog(@"Response:%@",response);
                NSLog(@"Error:%@",error);
                
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                if (httpResp.statusCode == 200) {
                    NSError *jsonError;
                    
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                    NSLog(@"DownloadedData:%@",dictionary);
                    
                    successCompletion(dictionary,nil);
                } else {
                    NSLog(@"Fail Not 200:");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failureCompletion) failureCompletion();
                    });
                }
            }] resume];
}

@end
