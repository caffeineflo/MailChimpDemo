//
//  MCListTableViewController.m
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/15/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

#import "MCList.h"
#import "MCListTableViewController.h"
#import "MCStore.h"
#import "MCMember.h"
#import "MCSubscriberDetailViewController.h"

@interface MCListTableViewController ()

@property (nonatomic, strong) MCStore *store;
@property (nonatomic, strong) NSArray<MCList *> *lists;

@end

@implementation MCListTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = @"MailChimp Lists and Subscribers";
        
        _store = [[MCStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshData];
}

- (void)refreshData
{
    // Ideally for slow network connections or when fetching more data I would show a loading screen or a Alert saying still fetching.
    [self.store fetchListsIncludingMembersWithCompletion:^(NSArray<MCList *> *lists, NSError *error){
        if (error) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Couldn't fetch MailChimp Lists and Members"
                                                                                     message:[NSString stringWithFormat:@"An error occurred fetching the data requested. The error we're getting is:%@", error.localizedDescription]
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self refreshData];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            self.lists = lists;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.lists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lists[section].member_count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.lists[section].name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.lists[indexPath.section].members[indexPath.row].FNAME, self.lists[indexPath.section].members[indexPath.row].LNAME];
    cell.detailTextLabel.text = self.lists[indexPath.section].members[indexPath.row].email_address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSubscriberDetailViewController *detailVC = [[MCSubscriberDetailViewController alloc] initWithMember:self.lists[indexPath.section].members[indexPath.row]];
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
