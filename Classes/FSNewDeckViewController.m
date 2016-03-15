//
//  FSNewDeckViewController.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 03/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSNewDeckViewController.h"
#import "FSDeck.h"

@interface FSNewDeckViewController ()

@end

@implementation FSNewDeckViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapRec.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRec];
    
    //Done Button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(donePressed)];

    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void)donePressed{
    
    if (![_nameField.text isEqualToString:@""]) {
        FSDeck *newDeck = [[FSDeck alloc] init];
        newDeck.name = _nameField.text;
        newDeck.cards = [[NSMutableArray alloc] initWithArray:@[]];
        newDeck.showCheckedCards = _showCheckSwitch.isOn;
        [database saveDeck:newDeck];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sliderValueChange:(id)sender {
//    UISlider *slider = (UISlider *)sender;
//    if (slider.value > 0.0) {
//        _fontSizeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17 * slider.value];
//    }else{
//        _fontSizeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:1];
//    }
//    [_fontSizeLabel sizeToFit];
}
@end