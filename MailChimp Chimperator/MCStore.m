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

- (void)fetchEndpoint:(NSString *)endpoint completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion
{
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:[NSString stringWithFormat:@"apikey %@", MCAPIKey] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            NSLog(@"ERROR: GET for %@ gave error %@", url.absoluteString, error.localizedDescription);
        } else {
            completion(data, response, error);
        }
    }];
    [dataTask resume];
}

- (void)fetchRootSubresourcesWithCompletion:(void (^)(NSDictionary *, NSError *))completion
{
    [self fetchEndpoint:MCAPIBaseURLString completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        // Usually the User would get it's own model to save these subresouces under, but since we don't need any other info from this endpoint than the
        // hateoas subresouces we store it here.
        NSDictionary *rootSubresources = [self parseSubresourcesFromArray:jsonObject[@"_links"]];
        self.rootSubresources = rootSubresources;
        NSLog(@"%@", self.rootSubresources);
        
        completion(rootSubresources, error);
    }];
}

- (void)fetchListsWithCompletion:(void (^)(NSArray<MCList *> *, NSError *))completion
{
    [self fetchEndpoint:self.rootSubresources[@"lists"] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
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
    [self fetchEndpoint:list.subresources[@"members"] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSMutableArray *tempMembers = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in jsonObject[@"members"]) {
            MCMember *member = [[MCMember alloc] initWithJSONDictionary:dict];
            member.subresources = [self parseSubresourcesFromArray:dict[@"_links"]];
            [tempMembers addObject:member];
        }
        
        completion(tempMembers, error);
    }];
}

- (void)fetchListsAndMembersWithCompletion:(void (^)(NSArray<MCList *> *, NSError *))completion
{
    if (!self.rootSubresources) {
        
        [self fetchRootSubresourcesWithCompletion:^(NSDictionary *rootSubresouces, NSError *error){
            
            [self fetchListsWithCompletion:^(NSArray<MCList *> *lists, NSError *err){
                
                for (MCList *list in lists) {
                    [self fetchMembersForList:list completion:^(NSArray<MCMember *> *members, NSError *error){
                        list.members = members;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(lists, err);
                        });
                    }];
                }
                
            }];
        }];
        
    }
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
