//
//  DetailViewController.h
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface DetailViewController : UIViewController

//@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSDictionary *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIWebView *articleWebView;

- (IBAction)favoriteArticle:(id)sender;
- (IBAction)tweetArticle:(id)sender;


@end

