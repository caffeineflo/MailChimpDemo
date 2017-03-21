//
//  MCStore.h
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/15/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

@class MCMember, MCList;
#import <Foundation/Foundation.h>

@interface MCStore : NSObject

- (void)fetchListsAndMembersWithCompletion:(void (^)(NSArray<MCList *> *, NSError *))completion;

@end
