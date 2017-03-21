//
//  List.h
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/19/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

@class MCMember;
#import <Foundation/Foundation.h>

@interface MCList : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int member_count;
@property (nonatomic, strong) NSArray<MCMember *> *members;
@property (nonatomic, strong) NSDictionary *subresources;

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@end
