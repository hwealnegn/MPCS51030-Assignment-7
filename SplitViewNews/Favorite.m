//
//  Favorite.m
//  SplitViewNews
//
//  Created by helenwang on 2/21/15.
//  Copyright (c) 2015 Helen Wang. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.link forKey:@"link"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    self.title = [decoder decodeObjectForKey:@"title"];
    self.link = [decoder decodeObjectForKey:@"link"];
    return self;
}

@end
