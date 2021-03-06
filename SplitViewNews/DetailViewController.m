//
//  DetailViewController.m
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import "DetailViewController.h"
#import "BookmarkViewController.h"
#import "MasterViewController.h"
#import "Favorite.h"
#import <QuartzCore/QuartzCore.h>
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
        self.detailDescriptionLabel.text = self.detailItem[@"title"];
        NSURL *url = [NSURL URLWithString:self.detailItem[@"link"]];
        [self.articleWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    // Save current article in NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.detailItem[@"link"]!=nil) {
        [defaults setObject:self.detailItem[@"link"] forKey:@"lastArticleViewed"]; // save current article
        [defaults setObject:self.detailItem[@"title"] forKey:@"lastArticleTitle"]; // and its title
    }
    [defaults synchronize];
    
    // Display star if article is in favorites
    if ([defaults objectForKey:@"title"] != nil) {
        NSLog(@"There are articles saved in favorites");
        
        // Check if selected article is already in array
        for (NSString *article in [defaults objectForKey:@"title"]){
            if ([article isEqualToString:self.detailItem[@"title"]]) { // article already saved
                [self.starImage setHidden:NO];
                break;
            }
            NSLog(@"This article is NOT in favorites");
            [self.starImage setHidden:YES];
        }
    }
    
    
    //NSLog(@"NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    // Loading view (displayed when web view is loading)
    // Reference for rounded corners: http://stackoverflow.com/questions/1509547/uiview-with-rounded-corners
    self.articleWebView.delegate = self;
    self.loadingView.layer.cornerRadius = 5;
    self.loadingView.layer.masksToBounds = YES;
    [self.loadingActivity startAnimating];
    
    self.bookmarkTitles = [[NSMutableArray alloc] init]; // initialize title array
    self.bookmarkLinks = [[NSMutableArray alloc] init]; // initialize link array
    
    // Set last article viewed as initial article displayed
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.articleWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[defaults stringForKey:@"lastArticleViewed"]]]];
    
    NSLog(@"NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    NSString *lastArticle = [defaults stringForKey:@"lastArticleViewed"];
    NSLog(@"Last article: %@", lastArticle);
    [defaults synchronize];

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
    [self.starImage setHidden:NO]; // display star
}

- (IBAction)favoriteArticle:(id)sender {
    NSLog(@"Favorited article!");
    [self.starImage setHidden:NO]; // display star
    
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
    
    // Create Favorite object and store to disk (NSCoding)
    Favorite *favoriteArticle = [[Favorite alloc] init];
    favoriteArticle.title = [NSArray arrayWithArray:self.bookmarkTitles];
    favoriteArticle.link = [NSArray arrayWithArray:self.bookmarkLinks];
    
    // File path
    NSError* err = nil;
    NSURL *docs = [[NSFileManager new] URLForDirectory:NSDocumentationDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
    
    // Write
    NSData* favoriteData = [NSKeyedArchiver archivedDataWithRootObject:favoriteArticle];
    NSURL* file = [docs URLByAppendingPathComponent:@"favorites.plist"];
    [favoriteData writeToURL:file atomically:NO];
    NSLog(@"DOCS: %@",file);
    
    // Read
    NSData* data = [[NSData alloc] initWithContentsOfURL:file];
    Favorite *favoriteRetrieved = (Favorite*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"Retrieved: %@ %@", favoriteRetrieved.title[0], favoriteRetrieved.link[0]);
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

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadingView setHidden:YES];
}

@end
