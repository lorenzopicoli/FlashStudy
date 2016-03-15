//
//  FSDeckListViewController.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 02/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSDeckListViewController.h"
#import "FSDeck.h"
#import "FSCard.h"

@interface FSDeckListViewController ()
@end

@implementation FSDeckListViewController

NSMutableArray *decks;
NSInteger indexOfLongPressedCell;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *cellTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    cellTap.minimumPressDuration = 0.5f;
    cellTap.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:cellTap];
    
    decks = [[NSMutableArray alloc] init];
    
    //NavBar buttons
    UIBarButtonItem *plus = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newDeckPressed)];
    self.navigationItem.rightBarButtonItem = plus;
    
    //Edit Button
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)];
    
    self.navigationItem.leftBarButtonItem = edit;
    
    //Navbar
    UIImage *image = [UIImage imageNamed:@"navbar.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationItem.title = @"Decks";
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    currentDeck = nil;
    decks = [database getAllDecks];
    [_decksTable reloadData];
}


#pragma mark Nav Bar Buttons

- (void)newDeckPressed{
    [self performSegueWithIdentifier:@"pushNewDeck" sender:self];
}

- (void)editPressed{
    [_decksTable setEditing:!_decksTable.isEditing animated:YES];
}

#pragma mark Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"decksCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"decksCell"];
    }
    
    FSDeck *deck = [decks objectAtIndex:indexPath.row];
    
    //Percentage Calculation
    NSMutableArray *cards = [[database getDeckWithID:deck._id] cards];
    
    if (![cards count]) {
        cell.detailTextLabel.text = @"";
    }else{
        double checkedCards = 0.0;
        for (FSCard *card in cards){
            if (card.isChecked) {
                checkedCards++;
            }
        }
        
        double percentage = (checkedCards/[cards count]) * 100;
        int castedPercentage = (int) percentage;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d%% complete", nil), castedPercentage];
    }
    //Detail
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:38.f/255.f green:38.f/255.f blue:38.f/255.f alpha:1];
    
    //Text
    [[cell textLabel] setText:deck.name];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    cell.textLabel.textColor = [UIColor colorWithRed:63.f/255.f green:63.f/255.f blue:63.f/255.f alpha:1];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([decks count] == 0) {
        [_decksTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    } else {
        [_decksTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    return [decks count];
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
    currentDeck = [decks objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"pushCardsList" sender:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [database deleteDeck:[decks objectAtIndex:indexPath.row]];
        [decks removeObjectAtIndex:indexPath.row];
        [_decksTable reloadData];
    }
}


#pragma mark Gesture recognizer

- (void)longPress: (UILongPressGestureRecognizer *) gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //Get the tap Location
        CGPoint tapLocation = [gesture locationInView:_decksTable];
        //Get the indexpath and the row for that location and store in the variable
        indexOfLongPressedCell = [_decksTable indexPathForRowAtPoint:tapLocation].row;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"More", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Shuffle", nil),
                                                                          NSLocalizedString(@"Swap the cards' side", nil), nil];
        
        [actionSheet showInView:_decksTable];
    }
}

#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    const int shuffle = 0;
    const int swap = 1;
    FSDeck *deck = [decks objectAtIndex:indexOfLongPressedCell];
    
    switch (buttonIndex) {
        case shuffle:
            [self shuffleCardsOfDeck:deck];
            break;
        case swap:
            [self swapCardsOfDeck:deck];
            break;
        default:
            break;
    }
}

#pragma mark Shuffle / Swap

- (void)shuffleCardsOfDeck: (FSDeck *)deck{
    
    NSMutableArray *cards = deck.cards;
    [cards shuffle];
    deck.cards = cards;
    [database saveDeck:deck];
}

- (void)swapCardsOfDeck: (FSDeck *)deck{
    
    NSMutableArray *cards = deck.cards;
    NSMutableArray *newCards = [NSMutableArray new];
    for (FSCard *card in cards){
        NSString *oldFront = card.front;
        card.front = card.back;
        card.back = oldFront;
        [newCards addObject:card];
    }
    deck.cards = newCards;
    [database saveDeck:deck];
}

@end

#pragma mark Interface Orientation

@interface UINavigationController (RotationAll)
-(NSUInteger)supportedInterfaceOrientations;
@end

@implementation UINavigationController (RotationAll)
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
@end









