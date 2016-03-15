//
//  FSCardsListViewController.h
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 06/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSCardsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *cardsTable;

@end
