//
//  Member.h
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/19/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMember : NSObject

@property (nonatomic, strong) NSString *FNAME;
@property (nonatomic, strong) NSString *LNAME;
@property (nonatomic, strong) NSString *email_address;
@property (nonatomic, strong) NSDictionary *subresources;

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@end
