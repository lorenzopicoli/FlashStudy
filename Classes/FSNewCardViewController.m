//
//  FSNewCardViewController.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 06/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSNewCardViewController.h"
#import <QuartzCore/QuartzCore.h>

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define HEIGHT_CHANGE 110
#define THREE_INCHES_DEVICES_DIFFERENCE 50

@interface FSNewCardViewController ()

@end

@implementation FSNewCardViewController{
    UITextView *activeField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapRec.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRec];
    
    //Done Button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(donePressed)];

    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self setupTextViews];
    [self registerForKeyboardNotifications];
    
    if (IS_LANDSCAPE){
        _questionTxtHeight.constant -= HEIGHT_CHANGE;
        _answerTxtHeight.constant -= HEIGHT_CHANGE;
    }else{
        if (!IS_IPHONE_5) { // The textviews are too big for a 3.5inch device
            _questionTxtHeight.constant -= THREE_INCHES_DEVICES_DIFFERENCE;
            _answerTxtHeight.constant -= THREE_INCHES_DEVICES_DIFFERENCE;
        }
    }
    
    if (_cardToBeEdited){
        _questionTxt.text = _cardToBeEdited.front;
        _answerTxt.text = _cardToBeEdited.back;
    }
    
    _scroll.scrollEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //BUG FIX
    if (!IS_LANDSCAPE) {
        _answerTxt.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
    }else{
        _answerTxt.contentInset = UIEdgeInsetsMake(7.0,0.0,0,0.0);
    }
}

- (void)setupTextViews {
    _questionTxt.layer.borderWidth = 0.5f;
    _questionTxt.layer.borderColor = [[UIColor grayColor] CGColor];
    _questionTxt.layer.cornerRadius = 5;
    _questionTxt.clipsToBounds = YES;
    
    _answerTxt.layer.borderWidth = 0.5f;
    _answerTxt.layer.borderColor = [[UIColor grayColor] CGColor];
    _answerTxt.layer.cornerRadius = 5;
    _answerTxt.clipsToBounds = YES;
}

#pragma mark Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){ //If it's going to change to Landscape
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) { //If it were in portrait before (to avoid bugs)
            _questionTxtHeight.constant -= HEIGHT_CHANGE;
            _answerTxtHeight.constant -= HEIGHT_CHANGE;
            _answerTxt.contentInset = UIEdgeInsetsMake(7.0,0.0,0,0.0);
            [self.view endEditing:YES];
            
            if (!IS_IPHONE_5) { // The textviews are too big for a 3.5inch device
                _questionTxtHeight.constant += THREE_INCHES_DEVICES_DIFFERENCE;
                _answerTxtHeight.constant += THREE_INCHES_DEVICES_DIFFERENCE;
            }
        }
    }else{
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) { //If it were in landscape before (to avoid bugs)
            _questionTxtHeight.constant += HEIGHT_CHANGE;
            _answerTxtHeight.constant += HEIGHT_CHANGE;
            _answerTxt.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
            
            if (!IS_IPHONE_5) { // The textviews are too big for a 3.5inch device
                _questionTxtHeight.constant -= THREE_INCHES_DEVICES_DIFFERENCE;
                _answerTxtHeight.constant -= THREE_INCHES_DEVICES_DIFFERENCE;
            }
        }
    }
}

#pragma mark helpers

- (void)donePressed{
    if (![_answerTxt.text isEqualToString:@""] && ![_questionTxt.text isEqualToString:@""]) {
        UIAlertView *addMore = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"More", nil)
                                                          message:NSLocalizedString(@"Would you like to add more cards?", nil)
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil), nil];
        [addMore show];
    }else{
        _cardToBeEdited = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void)save:(BOOL)addMore{
    FSCard *card = [[FSCard alloc] init];
    card.isChecked = NO;
    card.front = _questionTxt.text;
    card.back = _answerTxt.text;

    if (!_cardToBeEdited) { // If the user is creating a new card and not editing
        [currentDeck.cards addObject:card];
    }else{
        int index = (int)[currentDeck.cards indexOfObject:_cardToBeEdited];
        [currentDeck.cards removeObjectAtIndex:index];
        [currentDeck.cards insertObject:card atIndex:index];
    }

    [database saveDeck:currentDeck];

    if (addMore) {
        _questionTxt.text = @"";
        _answerTxt.text = @"";
    }else{
        _cardToBeEdited = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Text View Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _scroll.scrollEnabled = YES;
    activeField = textView;
    
    if (textView == _questionTxt && _answerTxt.isFirstResponder) { // If the user is editing the answer txtview and move to the question the screen move
        [_scroll scrollRectToVisible:self.view.bounds animated:YES];
    }
    
    return YES;
}

#pragma mark AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self save:YES];
        [_questionTxt becomeFirstResponder];
    }else{
        [self save:NO];
    }
}

#pragma mark Keyboard Management

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect convertedFrame = [self.view convertRect:keyboardFrame fromView:self.view.window]; //Fix Landscape bug
    
    CGSize kbSize = convertedFrame.size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scroll.contentInset = contentInsets;
    _scroll.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    int offset = IPAD ? 400 : 100;
    aRect.size.height = aRect.size.height - (kbSize.height + offset);
    
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [_scroll scrollRectToVisible:activeField.frame animated:YES];
    }
    
    int insetBottom = IPAD ? 100 : 0;
    contentInsets = UIEdgeInsetsMake(0, 0, insetBottom, 0);
    _scroll.contentInset = contentInsets;
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scroll.contentInset = contentInsets;
    _scroll.scrollIndicatorInsets = contentInsets;
    [_scroll scrollRectToVisible:self.view.bounds animated:YES];
    _scroll.scrollEnabled = NO;
    
    
}
@end
