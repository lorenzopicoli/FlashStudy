//
//  FSPresentationViewController.h
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 09/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPresentationViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *swipeIndicator;
@property (strong, nonatomic) IBOutlet UITextView *cardView;
- (IBAction)nextPressed:(id)sender;
- (IBAction)backPressed:(id)sender;
- (IBAction)checkPressed:(id)sender;
- (IBAction)uncheckPressed:(id)sender;
- (IBAction)twitterTapped:(id)sender;
- (IBAction)facebookTapped:(id)sender;

@property int currentCardIndex;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *sideEdgeDistanceConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *chechUncheckBottom;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topCardView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomCardView;

@property (strong, nonatomic) IBOutlet UIButton *twitterBtn;
@property (strong, nonatomic) IBOutlet UIButton *facebookBtn;

@end
