//
//  FSDatabase.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 01/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSDatabase.h"
#import "sqlite3.h"
#import "FSDeck.h"

@implementation FSDatabase{
    sqlite3 *database;
}

//Const
const NSString *dbName = @"FS";
const NSString *tableName = @"decks"; // IMPORTANT! IF YOU CHANGE THE TABLE NAME, REMEMBER TO CHANGE THE TABLE CREATION OR IT WONT WORK!
const NSString *tableCreation = @"create table if not exists decks(_id integer primary key autoincrement, cards blob, name text, creationDate blob, showCheckedCards integer);";

- (NSMutableArray *)getAllDecks{
    [self open];
    NSString *query = [NSString stringWithFormat:@"select _id, cards, name, creationDate, showCheckedCards from %@ order by _id", tableName];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil);
    NSMutableArray *decks;
    if (result == SQLITE_OK) {
        decks = [[NSMutableArray alloc] init];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            FSDeck *deck = [[FSDeck alloc] init];
            
            NSData *data;
            
            deck._id = sqlite3_column_int(stmt, 0); // ID
            data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 1) length:sqlite3_column_bytes(stmt, 1)];
            deck.cards = [NSKeyedUnarchiver unarchiveObjectWithData:data]; // Cards
            deck.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]; // Name
            data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 3) length:sqlite3_column_bytes(stmt, 3)];
            deck.creationDate = [NSKeyedUnarchiver unarchiveObjectWithData:data]; //Creation Date
            deck.showCheckedCards = sqlite3_column_int(stmt, 4);
            [decks addObject:deck];
        }
    }else{
        NSLog(@"Error preparing the stmt");
        return nil;
    }
    sqlite3_finalize(stmt);
    [self close];
    return decks;
}

- (FSDeck *)getDeckWithID:(int) param{
    [self open];
    NSString *query = [NSString stringWithFormat:@"select _id, cards, name, creationDate, showCheckedCards from %@ where _id = %d", tableName, param];
    FSDeck *deck = [[FSDeck alloc] init];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSData *data;
            
            deck._id = sqlite3_column_int(stmt, 0); // ID
            data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 1) length:sqlite3_column_bytes(stmt, 1)];
            deck.cards = [NSKeyedUnarchiver unarchiveObjectWithData:data]; // Cards
            deck.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]; // Name
            data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 3) length:sqlite3_column_bytes(stmt, 3)];
            deck.creationDate = [NSKeyedUnarchiver unarchiveObjectWithData:data]; //Creation Date
            deck.showCheckedCards = sqlite3_column_int(stmt, 4);
        }
    }
    return deck;
}

- (BOOL)saveDeck:(FSDeck *) deck{
    [self open];
    
    NSData *creationDate = [NSKeyedArchiver archivedDataWithRootObject:deck.creationDate];
    NSData *cards = [NSKeyedArchiver archivedDataWithRootObject:deck.cards];
    
    NSString *query = [NSString stringWithFormat:@"insert or replace into %@(_id, cards, name, creationDate, showCheckedCards) VALUES (?,?,?,?,?);", tableName];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil);
    
    if (result == SQLITE_OK) {
        
        if (deck._id > 0) { //Checks if the deck is being updated or if it's a new one
            sqlite3_bind_int(stmt, 1, deck._id);
        }
        
        sqlite3_bind_blob(stmt, 2, [cards bytes], (int)[cards length], nil);
        sqlite3_bind_text(stmt, 3, [deck.name UTF8String], -1, nil);
        sqlite3_bind_blob(stmt, 4, [creationDate bytes], (int)[creationDate length], nil);
        sqlite3_bind_int(stmt, 5, deck.showCheckedCards);
        
        result = sqlite3_step(stmt);
        if (result != SQLITE_DONE) {
            NSLog(@"Error saving the deck");
        }
        
        sqlite3_finalize(stmt);
    }else{
        [self close];
        return NO;
    }
    [self close];
    return YES;
}


- (BOOL)deleteDeck:(FSDeck *) deck{
    [self open];
    
    sqlite3_stmt *stmt;
    
    NSString *query = [NSString stringWithFormat:@"delete from %@ where _id= %d;", tableName, deck._id];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        result = sqlite3_step(stmt);
        if (result != SQLITE_DONE) {
            [self close];
            return NO;
        }
    }else{
        [self close];
        return NO;
    }
    
    [self close];
    return YES;
}


// Private Methods

- (NSString *)getFilePath{
    NSString *name = [NSString stringWithFormat:@"%@.db", dbName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    NSString *filePath = [dir stringByAppendingPathComponent:name];
    return filePath;
}

- (BOOL)open{
    
    NSString *filename = [self getFilePath];
    int result = sqlite3_open([filename UTF8String], &database);
    if (result == SQLITE_OK) {
        
        //If the DB was sucefully opened
        char *error;
        
        //Create the table if needed
        result = sqlite3_exec(database, [tableCreation UTF8String], NULL, NULL, &error);
        
        if (result != SQLITE_OK) {
            //If something wrong happened
            NSString *errorMessage = [NSString stringWithCString:error encoding:NSUTF8StringEncoding];
            NSLog(@"Error creating the table: %@", errorMessage);
            return NO;
        }
    }else{
        NSLog(@"Database could not be opened");
        return NO;
    }
    return YES;
}
- (BOOL)close{
    int result;
    result = sqlite3_close(database);
    if (result != SQLITE_OK) {
        return NO;
    }
    return YES;
}

@end
