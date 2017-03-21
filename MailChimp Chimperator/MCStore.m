//
//  MCStore.m
//  MailChimp Chimperator
//
//  Created by Florian Harr on 3/15/17.
//  Copyright © 2017 Florian Harr. All rights reserved.
//

#import "MCStore.h"
#import "MCList.h"
#import "MCMember.h"

NSString * const MCAPIBaseURLString = @"https://us14.api.mailchimp.com/3.0/";
NSString * const MCAPIKey = @"8ac1de26a49c4cca30ca8c0b62b8e68c-us14";

@interface MCStore () <NSURLSessionDelegate>

@property (nonatomic) NSURLSession *session;

@property (nonatomic, strong) NSDictionary *rootSubresources;

@end

@implementation MCStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:nil];
    }
    return self;
}

- (void)fetchEndpoint:(NSString *)endpoint completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    // MCAPI 3.0 allows for OAuth 2, so ideally this would be a NSURLCredentials object with the OAuth 2 token and therefore stored in the keychain.
    [req addValue:[NSString stringWithFormat:@"apikey %@", MCAPIKey] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            completion(nil, error);
        } else {
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            completion(jsonObject, error);
        }
    }];
    [dataTask resume];
}

- (void)fetchRootSubresourcesWithCompletion:(void (^)(NSDictionary *, NSError *))completion
{
    [self fetchEndpoint:MCAPIBaseURLString completion:^(NSDictionary *jsonObject, NSError *error) {
        // Usually the User would get it's own model class to parse these subresouces to, but since we don't need any other info from this endpoint than the
        // hateoas subresouces we store it here.
        NSDictionary *rootSubresources = [self parseSubresourcesFromArray:jsonObject[@"_links"]];
        self.rootSubresources = rootSubresources;
        
        completion(rootSubresources, error);
    }];
}

- (void)fetchListsWithCompletion:(void (^)(NSArray<MCList *> *, NSError *))completion
{
    // As a way to stay in compliance with the hateoas architecture, we're relying on the subresources given from the root endpoint.
    // With more time and a bigger project, I would also parse and take in the schema's that are provided, but I'll rely on hateoas and
    // given types for this example.
    [self fetchEndpoint:self.rootSubresources[@"lists"] completion:^(NSDictionary *jsonObject, NSError *error) {
        NSMutableArray *tempLists = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in jsonObject[@"lists"]) {
            MCList *list = [[MCList alloc] initWithJSONDictionary:dict];
            list.subresources = [self parseSubresourcesFromArray:dict[@"_links"]];
            [tempLists addObject:list];
        }
        
        completion(tempLists, error);
    }];
}

- (void)fetchMembersForList:(MCList *)list completion:(void (^)(NSArray<MCMember *> *, NSError *))completion
{
    [self fetchEndpoint:list.subresources[@"members"] completion:^(NSDictionary *jsonObject, NSError *error) {
        NSMutableArray *tempMembers = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in jsonObject[@"members"]) {
            MCMember *member = [[MCMember alloc] initWithJSONDictionary:dict];
            member.subresources = [self parseSubresourcesFromArray:dict[@"_links"]];
            [tempMembers addObject:member];
        }
        
        completion(tempMembers, error);
    }];
}

- (void)fetchListsIncludingMembersWithCompletion:(void (^)(NSArray<MCList *> *, NSError *))completion
{
    [self fetchRootSubresourcesWithCompletion:^(NSDictionary *rootSubresouces, NSError *error){
        [self fetchListsWithCompletion:^(NSArray<MCList *> *lists, NSError *err){
            
            // To make sure the completion block gets called only once and to make sure we have all the resources we need, I use a dispatch_group
            // that fires once after all members have been fetched. Alternatively, this could be moved to the VC and handeled there individually.
            dispatch_group_t dispatchGroup = dispatch_group_create();
            for (MCList *list in lists) {
                dispatch_group_enter(dispatchGroup);
                [self fetchMembersForList:list completion:^(NSArray<MCMember *> *members, NSError *e){
                    list.members = members;
                    dispatch_group_leave(dispatchGroup);
                }];
            }
            
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
                completion(lists, err);
            });
        }];
    }];
}


#pragma mark - Helper methods

//
// To stay consistent with the structure/pattern, this would normally be parsed on the model, but due to the (root)subresources being
// kept here it makes sense to parse subresources here and inject them.
//
- (NSDictionary *)parseSubresourcesFromArray:(NSArray *)subresources
{
    NSMutableDictionary *links = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dict in subresources) {
        [links setValue:dict[@"href"] forKey:dict[@"rel"]];
    }
    
    return links;
}

@end
