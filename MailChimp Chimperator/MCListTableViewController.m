//
//  MCListTableViewController.m
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/15/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

#import "MCListTableViewController.h"
#import "MCStore.h"

@interface MCListTableViewController ()

@property (nonatomic, strong) MCStore *store;

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
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


@end
