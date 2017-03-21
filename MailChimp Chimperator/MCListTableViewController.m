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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [self.store fetchListsAndMembersWithCompletion:^(NSArray<MCList *> *lists, NSError *error){
        if (error) {
            
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
    
    cell.textLabel.text = self.lists[indexPath.section].members[indexPath.row].email_address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSubscriberDetailViewController *detailVC = [[MCSubscriberDetailViewController alloc] initWithMember:self.lists[indexPath.section].members[indexPath.row]];
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
