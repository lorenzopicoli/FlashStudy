//
//  FSDeckListViewController.h
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 02/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSDeckListViewController;

@interface FSDeckListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *decksTable;

@end
