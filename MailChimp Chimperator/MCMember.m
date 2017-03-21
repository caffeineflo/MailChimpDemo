//
//  Member.m
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/19/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

#import "MCMember.h"

@implementation MCMember

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary
{
    self = [super init];
    if (self) {
        _FNAME = [jsonDictionary[@"merge_fields"] valueForKey:@"FNAME"];
        _LNAME = [jsonDictionary[@"merge_fields"] valueForKey:@"LNAME"];
        _email_address = jsonDictionary[@"email_address"];
    }
    return self;
}

@end
