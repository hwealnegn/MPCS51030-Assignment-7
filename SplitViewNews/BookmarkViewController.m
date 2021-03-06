//
//  BookmarkViewController.m
//  SplitViewNews
//
//  Created by Helen Wang on 2/13/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import "BookmarkViewController.h"

@interface BookmarkViewController ()

@end

@implementation BookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.favoriteTitle = [[NSMutableArray alloc] init]; // initialize title array
    self.favoriteLink = [[NSMutableArray alloc] init]; // initialize link array
    
    if ([defaults objectForKey:@"title"] != nil) {
        [self.favoriteTitle addObjectsFromArray:[defaults objectForKey:@"title"]]; // add existing objects to array
    }
    
    if ([defaults objectForKey:@"link"] != nil) {
        [self.favoriteLink addObjectsFromArray:[defaults objectForKey:@"link"]]; // add existing objects to array
    }
    
    NSLog(@"There should be %lu cells", (unsigned long)[self.favoriteTitle count]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favoriteTitle count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell" forIndexPath:indexPath];
    
    NSLog(@"Asking for cell: %ld", (long)indexPath.row);
    
    // Configure cell here!
    cell.textLabel.text = [self.favoriteTitle objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Clicked cell:%ld", (long)indexPath.row);
    [self.delegate bookmark:self sendsURL:[NSURL URLWithString:[self.favoriteLink objectAtIndex:indexPath.row]]];
    NSLog(@"Go to link: %@", [self.favoriteLink objectAtIndex:indexPath.row]);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [self.favoriteTitle removeObjectAtIndex:indexPath.row];
        [defaults setObject:self.favoriteTitle forKey:@"title"]; // update defaults
        
        [self.favoriteLink removeObjectAtIndex:indexPath.row];
        [defaults setObject:self.favoriteLink forKey:@"link"]; // update defaults
        
        [defaults synchronize];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

// Reference: http://behindtechlines.com/2012/06/enabling-configuring-uitableview-edit-mode/
- (IBAction)editBookmarks:(id)sender {
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
        self.editLabel.title = @"Edit";
    } else {
        self.editLabel.title = @"Done";
        [self.tableView setEditing:YES animated:YES];
    }
}
@end
