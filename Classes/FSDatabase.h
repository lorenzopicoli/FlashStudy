//
//  FSDatabase.h
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 01/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDeck.h"
@interface FSDatabase : NSObject

- (NSMutableArray *)getAllDecks;
- (BOOL)saveDeck:(FSDeck *) deck;
- (BOOL)deleteDeck:(FSDeck *) deck;
- (FSDeck *)getDeckWithID:(int) param;
@end
