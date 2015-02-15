//
//  DetailViewController.m
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import "DetailViewController.h"
#import "BookmarkViewController.h"
#import "BookmarkToWebViewDelegate.h"

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
    
    // Test UIWebView display
    //[self.articleWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
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
    
    if ([defaults objectForKey:@"title"] != nil) {
        NSArray *copyArray = [defaults objectForKey:@"title"]; // create copy of existing array
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:copyArray]; // create temp mutable array
        
        // check if selected article is already in array
        for (NSString *article in tempArray){
            if (article == self.detailItem[@"title"]) { // article already saved
                break;
            }
            // if article is not found
            [tempArray addObject:self.detailItem[@"title"]]; // add new article
            [defaults setObject:tempArray forKey:@"title"]; // save updated array to defaults
        }
    } else {
        [defaults setObject:self.detailItem[@"title"] forKey:@"title"]; // initialize with first input
    }
    
    [defaults synchronize];
    
/*    // Save relevant article information to NSUserDefaults (dictionary)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // where should this be initialized?
    
    // should be array/dictionary? to store all articles in?
    //[defaults setObject:self.detailItem[@"title"] forKey:@"title"];
    [defaults setObject:self.detailItem[@"link"] forKey:@"link"];
    [defaults synchronize];

    // Copy current contents of array into temporary array
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    tempArray = [defaults objectForKey:@"title"];
    [tempArray addObject:self.detailItem[@"title"]];
    [defaults setObject:tempArray forKey:@"title"];
    [defaults synchronize];

    
    NSLog(@"NSUserDefaults: %@", [defaults objectForKey:@"title"]);
    */
}
@end
