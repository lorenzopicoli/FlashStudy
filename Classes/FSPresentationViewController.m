//
//  FSPresentationViewController.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 09/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSPresentationViewController.h"
#import "FSCard.h"
#import "FSDeck.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>

#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
#define X_AXIS_CHANGE 70
#define APPSTORE_LINK "https://itunes.apple.com/us/app/flash-study/id761476004?ls=1&mt=8"

@interface FSPresentationViewController ()

@end

typedef enum {
    kFront,
    kBack
} FSCardSide;

@implementation FSPresentationViewController{
    NSArray *_cards;
    FSCardSide _cardState;
    BOOL showAlert;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Done Button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(donePressed)];

    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.navigationItem.title = NSLocalizedString(@"Question", nil);
    
    //Twitter / Facebook Button
    
    [_twitterBtn setBackgroundImage:[UIImage imageNamed:@"btn_twitter_up.png"] forState:UIControlStateHighlighted];
    [_facebookBtn setBackgroundImage:[UIImage imageNamed:@"btn_facebook_up.png"] forState:UIControlStateHighlighted];
    
    
    _cardView.editable = NO;
    _cardView.textAlignment = NSTextAlignmentCenter;
    [_cardView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL]; //For middle alignment
    _cardView.backgroundColor = [UIColor colorWithRed:235.f/255.f green:235.f/255.f blue:235.f/255.f alpha:1.0f];
    _cardView.font = [UIFont fontWithName:@"HelveticaNeue" size:23];
    _cards = currentDeck.cards;
    
    //Right Recognizer
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipCard)];
    gesture.direction = UISwipeGestureRecognizerDirectionRight;
    [_cardView addGestureRecognizer:gesture];
    
    //Left Recognizer
    UISwipeGestureRecognizer *gesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipCard)];
    gesture2.direction = UISwipeGestureRecognizerDirectionLeft;
    [_cardView addGestureRecognizer:gesture2];
    
    //Vertical Recognizers
    UISwipeGestureRecognizer *gesture3 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPressed:)];
    gesture3.direction = UISwipeGestureRecognizerDirectionUp;
    [_cardView addGestureRecognizer:gesture3];
    
    UISwipeGestureRecognizer *gesture4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backPressed:)];
    gesture4.direction = UISwipeGestureRecognizerDirectionDown;
    [_cardView addGestureRecognizer:gesture4];
    
    _cardView.layer.borderWidth = 1.5f;
    _cardView.layer.cornerRadius = 5;
    _cardView.clipsToBounds = YES;
    
    [self updateCard: YES];
    
    if (IS_LANDSCAPE) {
        for (NSLayoutConstraint *constraint in _sideEdgeDistanceConstraints){
           constraint.constant += X_AXIS_CHANGE;
        }

        for (NSLayoutConstraint *constraint in _chechUncheckBottom){
            constraint.constant -= 30;
        }
        _topCardView.constant -= 40;
        _bottomCardView.constant -= 65;
    }
    
    [self.navigationItem setHidesBackButton:YES];
    [self performSelector:@selector(fadeImage) withObject:nil afterDelay:2];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [_cardView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    showAlert = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.navigationItem setHidesBackButton:NO];
}

- (void)donePressed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fadeImage{
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.7];
    if (_swipeIndicator.alpha != 0.0f) _swipeIndicator.alpha = 0.0f;
    [UIView commitAnimations];
}

#pragma mark Interface Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        for (NSLayoutConstraint *constraint in _sideEdgeDistanceConstraints){
            constraint.constant += X_AXIS_CHANGE;
        }
        
        for (NSLayoutConstraint *constraint in _chechUncheckBottom){
            constraint.constant -= 30;
        }
        _topCardView.constant -= 40;
        _bottomCardView.constant -= 65;
    }else{
        for (NSLayoutConstraint *constraint in _sideEdgeDistanceConstraints){
            constraint.constant -= X_AXIS_CHANGE;
        }
        
        for (NSLayoutConstraint *constraint in _chechUncheckBottom){
            constraint.constant += 30;
        }
        _topCardView.constant += 40;
        _bottomCardView.constant += 65;
    }
}


#pragma mark Observe

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    //Center vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
}

#pragma mark Heper Methods

- (void)flipCard{
    FSCard *card = [_cards objectAtIndex:_currentCardIndex];
    
    //Flip to answer
    if (_cardState == kFront) {
        [UIView transitionWithView:_cardView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            
            _cardView.text = card.back;
            
            if (_swipeIndicator.alpha != 0.0f)
                _swipeIndicator.alpha = 0.0f;
            
            _twitterBtn.alpha = 0.0f;
            _facebookBtn.alpha = 0.0f;
            
        } completion:nil];
        
        _cardState = kBack;
        self.navigationItem.title = NSLocalizedString(@"Answer", nil);
        
        //Flip to question
    }else{
        [UIView transitionWithView:_cardView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            
            _cardView.text = card.front;
            _twitterBtn.alpha = 0.0f;
            _facebookBtn.alpha = 0.0f;
            
        } completion:nil];
        
        _cardState = kFront;
        self.navigationItem.title = NSLocalizedString(@"Question", nil);
    }
    
    
    [UIView animateWithDuration:0.3f delay:0.5f options:0 animations:^{
        _twitterBtn.alpha = 1.0f;
        _facebookBtn.alpha = 1.0f;
    }completion:nil];
}

- (void)updateCard:(BOOL)front{
    UIViewAnimationOptions trans = front ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown;
    FSCard *card = [_cards objectAtIndex:_currentCardIndex];
    [UIView transitionWithView:_cardView duration:0.5f options:trans animations:^{ _cardView.text = card.front;} completion:nil];
    _cardState = kFront;
    if (card.isChecked) {
        _cardView.layer.borderColor = [[UIColor greenColor] CGColor];
    }else{
        _cardView.layer.borderColor = [[UIColor redColor] CGColor];
    }
}

#pragma mark IBActions
- (IBAction)nextPressed:(id)sender {
    
    BOOL allCardsChecked = [self checkIfAllCardsChecked];
    
    if (showAlert && allCardsChecked) {
        UIAlertView *finished = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congratulations", nil)
                                                           message:NSLocalizedString(@"You checked all cards!", nil)
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"OK", nil];
        [finished show];
        showAlert = NO;
    }
    
    _currentCardIndex++;
    
    if (_currentCardIndex >= [_cards count]) {
        _currentCardIndex = 0;
    }
    
    //Check if the next card is checked and if the user wants to see it
    if ([[_cards objectAtIndex:_currentCardIndex] isChecked] && !currentDeck.showCheckedCards && [_cards count] != 1 && !allCardsChecked) {
        [self nextPressed:nil]; // If the user don't want to see it go to the next card
    }else{
        [self updateCard: YES]; // If the user wants to see it update the UI
    }
}

- (IBAction)backPressed:(id)sender {
    
    BOOL allCardsChecked = [self checkIfAllCardsChecked];

    _currentCardIndex--;
    
    if (_currentCardIndex < 0) {
        _currentCardIndex = (int)[_cards count] - 1;
    }
    
    // Check if the next card is checked and if the user wants to see it
    if ([[_cards objectAtIndex:_currentCardIndex] isChecked] && !currentDeck.showCheckedCards && [_cards count] != 1 && !allCardsChecked) {
        [self backPressed:nil]; // If the user don't want to see it go to the next card
        
    }else{
        [self updateCard: NO]; // If the user wants to see it update the UI
    }
}

- (IBAction)checkPressed:(id)sender {
    FSCard *card = [_cards objectAtIndex:_currentCardIndex];
    card.isChecked = YES;
    [currentDeck.cards replaceObjectAtIndex:_currentCardIndex withObject:card]; //Replace the old one with the new
    _cardView.layer.borderColor = [[UIColor greenColor] CGColor];
    [database saveDeck:currentDeck];
}

- (IBAction)uncheckPressed:(id)sender {
    FSCard *card = [_cards objectAtIndex:_currentCardIndex];
    card.isChecked = NO;
    [currentDeck.cards replaceObjectAtIndex:_currentCardIndex withObject:card]; //Replace the old one with the new
    _cardView.layer.borderColor = [[UIColor redColor] CGColor];
    [database saveDeck:currentDeck];
}


#pragma mark Helper

- (BOOL)checkIfAllCardsChecked{
    BOOL allCardsChecked = YES;
    
    for (FSCard *card in _cards){
        if (!card.isChecked) {
            allCardsChecked = NO;
            break;
        }
    }
    return allCardsChecked;
}

#pragma mark Social

- (IBAction)twitterTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:[self getCardText]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

- (IBAction)facebookTapped:(id)sender {
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                }
                    break;
            }};
        
        [fbController setInitialText:[self getCardText]];
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }

}

- (NSString *)getCardText{
    
    NSString *initialText;
    NSString *additionalText = NSLocalizedString(@" I'm learning with flashcards, check this app: ", nil);
    
    if (_cardState == kFront) {
        initialText = [[_cards objectAtIndex:_currentCardIndex] front];
        initialText = [initialText stringByAppendingString:[NSString stringWithFormat:@"%@ %s", additionalText, APPSTORE_LINK]];
    }else
    {
        initialText = [[_cards objectAtIndex:_currentCardIndex] back];
        initialText = [initialText stringByAppendingString:[NSString stringWithFormat:@"%@ %s", additionalText, APPSTORE_LINK]];
    }
    return initialText;
}

@end
