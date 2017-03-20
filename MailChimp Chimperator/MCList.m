//
//  List.m
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/19/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

#import "MCList.h"

@interface MCList ()

@end

@implementation MCList

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary
{
    self = [super init];
    if (self) {
        _name = jsonDictionary[@"name"];
        _member_count = (int)[[jsonDictionary[@"stats"] valueForKey:@"member_count"] integerValue];
    }
    return self;
}

@end
