//
//  MCSubscriberDetailViewController.m
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/15/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

#import "MCSubscriberDetailViewController.h"
#import "MCMember.h"

@interface MCSubscriberDetailViewController ()

@property(nonatomic, strong) MCMember *member;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation MCSubscriberDetailViewController

- (instancetype)initWithMember:(MCMember *)member
{
    self = [super init];
    if (self) {
        _member = member;
        self.navigationItem.title = member.email_address;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.member.FNAME, self.member.LNAME];
    self.emailLabel.text = self.member.email_address;
}

@end
