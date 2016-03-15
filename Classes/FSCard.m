//
//  FSCard.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 01/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSCard.h"

#define kFront @"Front"
#define kBack @"Back"
#define kChecked @"Check"

@implementation FSCard

#pragma mark NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_front forKey:kFront];
    [encoder encodeObject:_back forKey:kBack];
    [encoder encodeInt:_isChecked forKey:kChecked];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *front = [decoder decodeObjectForKey:kFront];
    NSString *back = [decoder decodeObjectForKey:kBack];
    BOOL checked = [decoder decodeIntForKey:kChecked];
    _front = front;
    _back = back;
    _isChecked = checked;
    return self;
}

@end