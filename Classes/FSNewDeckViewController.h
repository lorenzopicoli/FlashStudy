//
//  FSNewDeckViewController.h
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 03/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSNewDeckViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UISwitch *showCheckSwitch;
@property (strong, nonatomic) IBOutlet UILabel *fontSizeLabel;
- (IBAction)sliderValueChange:(id)sender;

@end
