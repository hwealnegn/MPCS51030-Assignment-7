//
//  MasterViewController.m
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NewsTableViewCell.h"
#import "SharedNetworking.h"

@interface MasterViewController ()

@property NSMutableArray *objects;

@end

@implementation MasterViewController

- (void)refreshTable {
    NSLog(@"Refreshing");
    
    [[SharedNetworking sharedNetworking] getFeedForURL:@"http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=8&q=http%3A%2F%2Fnews.google.com%2Fnews%3Foutput%3Drss"
                                               success:^(NSDictionary *dictionary, NSError *error) {
                                                   self.objects = dictionary[@"responseData"][@"feed"][@"entries"];
                                                   [self.tableView reloadData];
                                                   
                                                   // Indicate network activity
                                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                                                   
                                               } failure:^{
                                                   NSLog(@"Problem with data");
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Unable to connect to network." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                       [alert show];
                                                   });
                                               }];
    
    
    [self.refreshControl endRefreshing];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.objects = [[NSMutableArray alloc] init];
    
    // Add UIRefreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Auto-resizing table view cells
    //self.tableView.estimatedRowHeight = 150.0;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"Size changed; need to reload table");
        [self.tableView reloadData];
    }];
    
    [[SharedNetworking sharedNetworking] getFeedForURL:@"http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=8&q=http%3A%2F%2Fnews.google.com%2Fnews%3Foutput%3Drss"
                                               success:^(NSDictionary *dictionary, NSError *error) {
                                                   self.objects = dictionary[@"responseData"][@"feed"][@"entries"];
                                                   [self.tableView reloadData];
                                                   
                                                   // Indicate network activity
                                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                                                   
                                               } failure:^{
                                                       NSLog(@"Problem with data");
                                                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Unable to connect to network." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                            [alert show];
                                               }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSLog(@"Show detail");
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSDictionary *link = [self.objects objectAtIndex:indexPath.row];
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:link];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleCell" forIndexPath:indexPath];

    // Configure cell here!
    
    cell.articleTitle.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    // Used NSDateFormatter to display only day, month, and year
    // References: http://iosdevelopertips.com/cocoa/date-formatters-examples-take-3.html & http://nshipster.com/nsformatter/
    NSString *date = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"publishedDate"];
    NSString *subDate = [date substringWithRange:NSMakeRange(5, 11)];
    NSDateFormatter *DateFormatted = [[NSDateFormatter alloc] init];
    [DateFormatted setDateFormat:@"dd MMM yyyy"];
    NSDate *articleDate = [DateFormatted dateFromString:subDate]; // date string
    
    [DateFormatted setDateStyle:NSDateFormatterMediumStyle];
    NSString *modifiedDate = [DateFormatted stringFromDate:articleDate];
    
    cell.publishDate.text = modifiedDate;
    
    cell.articleSnippet.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"contentSnippet"];
    
    // Configure cell appearance for night view
    [self setPreferenceDefaults];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL enabled = [defaults boolForKey:@"night_view_preference"];
    if (enabled) {
        // set night view preferences
        self.tableView.backgroundColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor blackColor];
        cell.articleTitle.textColor = [UIColor whiteColor];
        cell.publishDate.textColor = [UIColor whiteColor];
        cell.articleSnippet.textColor = [UIColor whiteColor];
    }
    
    // Adjust cell layout/size for dynamic type
    //cell.articleTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    //cell.publishDate.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    //cell.articleSnippet.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    //[cell layoutIfNeeded];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)setPreferenceDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"YES" forKey:@"night_view_preference"]; // defaults YES
    [defaults registerDefaults:appDefaults];
    
//    NSLog(@"NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

@end
