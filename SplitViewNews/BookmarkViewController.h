//
//  BookmarkViewController.h
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarkToWebViewDelegate.h"

@interface BookmarkViewController : UIViewController

@property (weak, nonatomic) id<BookmarkToWebViewDelegate> delegate;

@end