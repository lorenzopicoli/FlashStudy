//
//  FSNewCardViewController.h
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 06/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSNewCardViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *questionTxt;
@property (strong, nonatomic) IBOutlet UITextView *answerTxt;
@property FSCard *cardToBeEdited;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *questionTxtHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *answerTxtHeight;
@property (strong, nonatomic) IBOutlet UIScrollView *scroll;
@end
