//
//  BookmarkToWebViewDelegate.h
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BookmarkToWebViewDelegate <NSObject>

- (void)bookmark:(id)sender sendsURL:(NSURL*)url;

@end
