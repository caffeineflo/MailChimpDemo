//
//  MCSubscriberDetailViewController.h
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/15/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

@class MCMember;
#import <UIKit/UIKit.h>

@interface MCSubscriberDetailViewController : UIViewController

- (instancetype)initWithMember:(MCMember *)member;

@end
