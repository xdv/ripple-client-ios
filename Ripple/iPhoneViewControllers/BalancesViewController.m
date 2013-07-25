//
//  BalancesViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/22/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "BalancesViewController.h"
#import "RippleJSManager.h"
#import "SendTransactionViewController.h"
#import "SendGenericViewController.h"
#import "RPNewTransaction.h"
#import "AppDelegate.h"

@interface BalancesViewController () <UITableViewDataSource, UITableViewDelegate, RippleJSManagerBalanceDelegate> {
    NSDictionary * balances;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIButton    * navLogout;

@end

@implementation BalancesViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Send"]) {
        SendGenericViewController * view = [segue destinationViewController];
        
        RPNewTransaction * t = [RPNewTransaction new];
        t.Date = [NSDate date];
        t.Currency = sender;
        
        view.transaction = t;
    }
}


-(IBAction)buttonLogout:(id)sender
{
    [[RippleJSManager shared] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)RippleJSManagerBalances:(NSDictionary*)_balances
{
    if (balances.count != _balances.count) {
        balances = _balances;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        balances = _balances;
        [self.tableView reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else {
        return balances.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // Receive cell
            //NSString *address = [[RippleJSManager shared] rippleWalletAddress];
            cell = [tableView dequeueReusableCellWithIdentifier:@"xrp"];
            cell.textLabel.text = @"Receive";
            //cell.detailTextLabel.text = address;
            cell.detailTextLabel.text = nil;
        }
        else {
            // Send
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.textLabel.text = @"Send";            
        }
        
    }
    else {
        // Currencies
        NSString * key = [[balances allKeys] objectAtIndex:indexPath.row];
        NSNumber * amount = [balances objectForKey:key];
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
        [formatter setMaximumFractionDigits:2]; // Set this if you need 2 digits
        
        //        if ([key isEqualToString:@"XRP"]) {
        //            NSString *address = [[RippleJSManager shared] rippleWalletAddress];
        //            cell = [tableView dequeueReusableCellWithIdentifier:@"xrp"];
        //            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
        //            cell.detailTextLabel.text = address;
        //        }
        //        else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
        //        }
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // Receive
            [self performSegueWithIdentifier:@"Receive" sender:nil];
        }
        else {
            // Send
            [self performSegueWithIdentifier:@"SendGeneric" sender:nil];
            
//            NSString *address = [[RippleJSManager shared] rippleWalletAddress];
//            if (address) {
//                UIPasteboard *pb = [UIPasteboard generalPasteboard];
//                [pb setString:address];
//                
//                UIAlertView *alert = [[UIAlertView alloc]
//                                      initWithTitle: @"Copied to clipboard"
//                                      message: address
//                                      delegate: nil
//                                      cancelButtonTitle:@"OK"
//                                      otherButtonTitles:nil];
//                [alert show];
//            }
        }
    }
    else {
        NSString * key = [[balances allKeys] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"Send" sender:key];
//        if ([key isEqualToString:@"XRP"]) {
//            // Send XRP only
//            [self performSegueWithIdentifier:@"Send" sender:key];
//        }
    }
}

-(void)appEnteredForeground
{
    //[[RippleJSManager shared] connect];
}

-(void)appEnteredBackground
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Refresh stories every time app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name: UIApplicationDidBecomeActiveNotification object:nil];
    
    // Close any stories when entering background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
    [RippleJSManager shared].delegate_balances = self;
    
    AppDelegate * appdelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    appdelegate.viewControllerBalance = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
