//
//  FSDeck.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 01/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSDeck.h"

@implementation FSDeck

- (id)init
{
    self = [super init];
    if (self) {
        _creationDate = [NSDate date];
    }
    return self;
}

@end
