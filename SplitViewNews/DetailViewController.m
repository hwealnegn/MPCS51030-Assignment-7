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
}
@end
