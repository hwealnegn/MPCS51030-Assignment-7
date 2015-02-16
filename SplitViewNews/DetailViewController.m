//
//  DetailViewController.m
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import "DetailViewController.h"
#import "BookmarkViewController.h"
#import <Social/Social.h>

@interface DetailViewController () <BookmarkToWebViewDelegate>

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDictionary *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
        NSLog(@"Setter override");
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        //self.detailDescriptionLabel.text = [self.detailItem description];
        self.detailDescriptionLabel.text = self.detailItem[@"title"];
        NSURL *url = [NSURL URLWithString:self.detailItem[@"link"]];
        [self.articleWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    self.bookmarkTitles = [[NSMutableArray alloc] init]; // initialize title array
    self.bookmarkLinks = [[NSMutableArray alloc] init]; // initialize link array
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"popoverSegue"]) {
        NSLog(@"Prepare for segue");
        BookmarkViewController *bvc = (BookmarkViewController*)segue.destinationViewController;
        bvc.delegate = self;
    }
}

- (void)bookmark:(id)sender sendsURL:(NSURL *)url {
    NSLog(@"Sending message from bookmarks");
    [self.articleWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)favoriteArticle:(id)sender {
    NSLog(@"Favorited article!");
    
    // Save relevant article information to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"There are %lu objects in bookmarks", (unsigned long)[self.bookmarkTitles count]);
    
    // Save article titles
    if ([defaults objectForKey:@"title"] != nil) {
        NSLog(@"There's something");
        
        NSInteger exists = 0;
        
        [self.bookmarkTitles addObjectsFromArray:[defaults objectForKey:@"title"]];
        
        // check if selected article is already in array
        for (NSString *article in self.bookmarkTitles){
            if ([article isEqualToString:self.detailItem[@"title"]]) { // article already saved
                exists = 1;
                break;
            }
        }
        
        // if article is not found
        if (exists == 0) {
            [self.bookmarkTitles addObject:self.detailItem[@"title"]]; // add new article
            [defaults setObject:self.bookmarkTitles forKey:@"title"]; // save updated array to defaults
        }

    } else {
        NSLog(@"Initialize title array in NSUserDefaults");
        
        [self.bookmarkTitles addObject:self.detailItem[@"title"]]; // add article to array
        
        [defaults setObject:self.bookmarkTitles forKey:@"title"]; // save array in defaults
    }
    
    NSLog(@"There are %lu objects in bookmarks", (unsigned long)[self.bookmarkTitles count]);
    
    // Save article links
    if ([defaults objectForKey:@"link"] != nil) {
        NSLog(@"There's something");
        
        NSInteger exists = 0;
        
        [self.bookmarkLinks addObjectsFromArray:[defaults objectForKey:@"link"]];
        
        // check if selected article is already in array
        for (NSString *article in self.bookmarkLinks){
            if ([article isEqualToString:self.detailItem[@"link"]]) { // article already saved
                exists = 1;
                break;
            }
        }
        
        // if article is not found
        if (exists == 0) {
            [self.bookmarkLinks addObject:self.detailItem[@"link"]]; // add new article
            [defaults setObject:self.bookmarkLinks forKey:@"link"]; // save updated array to defaults
        }
        
    } else {
        NSLog(@"Initialize link array in NSUserDefaults");
        
        [self.bookmarkLinks addObject:self.detailItem[@"link"]]; // add article to array
        
        [defaults setObject:self.bookmarkLinks forKey:@"link"]; // save array in defaults
    }
    
    [defaults synchronize];
    
    NSLog(@"NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

// Reference: http://www.appcoda.com/ios-programming-101-integrate-twitter-and-facebook-sharing-in-ios-6/
- (IBAction)tweetArticle:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) { // check if Twitter service is accessible
        SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweet setInitialText:@"Must read!"];
        [self presentViewController:tweet animated:YES completion:nil];
        
        NSLog(@"Tweet!");
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Tweet" message:@"You cannot send a tweet right now. Sorry!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        NSLog(@"Cannot tweet!");
    }
}
@end
