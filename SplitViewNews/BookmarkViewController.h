//
//  BookmarkViewController.h
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookmarkToWebViewDelegate <NSObject>

- (void)bookmark:(id)sender sendsURL:(NSURL*)url;

@end

@interface BookmarkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<BookmarkToWebViewDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *favoriteTitle;
@property (strong, nonatomic) NSMutableArray *favoriteLink;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)editBookmarks:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editLabel;

@end
