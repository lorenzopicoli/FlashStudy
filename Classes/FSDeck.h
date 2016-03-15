//
//  FSDeck.h
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 01/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCard.h"

@interface FSDeck : NSObject

@property int _id;
@property BOOL showCheckedCards;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *creationDate;

@end
