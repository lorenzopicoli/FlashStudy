//
//  FSCard.h
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 01/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCard : NSObject <NSCoding>

@property (strong, nonatomic) NSString *front;
@property (strong, nonatomic) NSString *back;
@property BOOL isChecked;

@end
