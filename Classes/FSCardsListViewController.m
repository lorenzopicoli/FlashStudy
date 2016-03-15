//
//  FSCardsListViewController.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 06/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSCardsListViewController.h"
#import "FSCard.h"
#import "FSNewCardViewController.h"
#import "FSPresentationViewController.h"

@interface FSCardsListViewController ()

@end

@implementation FSCardsListViewController

NSMutableArray *cards;
NSInteger indexOfLongPressedCell;
FSCard *cardToBeEdited;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *cellTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    cellTap.minimumPressDuration = 0.5f;
    cellTap.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:cellTap];

    //Plus Button
    UIBarButtonItem *plus = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(plusPressed)];
    self.navigationItem.rightBarButtonItem = plus;
}

- (void)viewWillAppear:(BOOL)animated{
    cards = [currentDeck cards];
    [_cardsTable reloadData];
}

- (void)plusPressed{
    cardToBeEdited = nil;
    [self performSegueWithIdentifier:@"pushNewCard" sender:self];
}

#pragma mark Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardsCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cardsCell"];
    }
    
    FSCard *card = [cards objectAtIndex:indexPath.row];
    [[cell textLabel] setText:card.front];
    
    //    [[cell detailTextLabel] setText:card.back];
    
    //Detail
    //    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    //    cell.detailTextLabel.textColor = [UIColor colorWithRed:38.f/255.f green:38.f/255.f blue:38.f/255.f alpha:1];
    
    //Text
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    cell.textLabel.textColor = [UIColor colorWithRed:63.f/255.f green:63.f/255.f blue:63.f/255.f alpha:1];
    
    
    //Text Color
    if (card.isChecked){
        cell.textLabel.textColor = [UIColor colorWithRed:0.f green:157.f/255.f blue:26.f/255.f alpha:1];
    }else{
        cell.textLabel.textColor = [UIColor colorWithRed:224.f/255.f green:3.f/255.f blue:3.f/255.f alpha:1];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([cards count] == 0) {
        [_cardsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    } else {
        [_cardsTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    return [currentDeck.cards count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"pushToPresentation" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [currentDeck.cards removeObjectAtIndex:indexPath.row];
        [_cardsTable reloadData];
        [database saveDeck:currentDeck];
    }
}

#pragma mark Gesture recognizer

- (void)longPress: (UILongPressGestureRecognizer *) gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //Get the tap Location
        CGPoint tapLocation = [gesture locationInView:_cardsTable];
        //Get the indexpath and the row for that location and store in the variable
        indexOfLongPressedCell = [_cardsTable indexPathForRowAtPoint:tapLocation].row;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"More", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Edit", nil), nil];
        
        [actionSheet showInView:_cardsTable];
    }
}

#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    const int edit = 0;
    FSCard *card = [cards objectAtIndex:indexOfLongPressedCell];
    
    switch (buttonIndex) {
        case edit:
            [self editCard:card];
            break;
        default:
            break;
    }
}

#pragma Edit

- (void)editCard:(FSCard *) card{
    cardToBeEdited = card;
    [self performSegueWithIdentifier:@"pushNewCard" sender:self];
    
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *path = [_cardsTable indexPathForSelectedRow];
    if ([[segue identifier] isEqualToString:@"pushToPresentation"]) {
        FSPresentationViewController *pvc = [segue destinationViewController];
        pvc.currentCardIndex = (int)path.row;
    }else if ([[segue identifier] isEqualToString:@"pushNewCard"]) {
        FSNewCardViewController *ncvc = [segue destinationViewController];
        ncvc.cardToBeEdited = cardToBeEdited;
    }
}

@end
