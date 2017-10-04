//
//  ViewController.m
//  IAP Example
//
//  Created by Stanle De La Cruz on 9/22/17.
//  Copyright © 2017 Stanle De La Cruz. All rights reserved.
//

#import "ViewController.h"
#import "IAPProducts.h"
#import <StoreKit/StoreKit.h>

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>


@property (strong,nonatomic) UITableView *table;
@property(nonatomic, readonly) NSArray<SKProduct *> *products;


@end

@implementation ViewController

static NSString * const IAPHelperPurchaseNotification = @"IAPHelperPurchaseNotification";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.table.delegate = self;
    self.table.dataSource = self;
    
    [self.view addSubview:self.table];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchase:) name:IAPHelperPurchaseNotification object:nil];
    
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handlePurchase:(NSNotification*)notification {
    NSString* productId = notification.object;
    NSLog(@"Do something with this productID: %@", productId);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_table reloadData];
    [self loadProductsFromiTunes];
}

- (void) loadProductsFromiTunes {
    
    [[[IAPProducts sharedManager] store] requestProducts:^(BOOL success, NSArray<SKProduct*>* products) {
        
        if(success) {
            _products = products;
            NSLog(@"%@",@[products[0].productIdentifier]);
            [_table reloadData];
        } else {
            NSLog(@"Make sure you have your IAP keys setup on itunes");
        }
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    cell.textLabel.text = [_products objectAtIndex:indexPath.row].localizedTitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SKProduct* product = [_products objectAtIndex:indexPath.row];
    if([[[IAPProducts sharedManager] store] canMakePayments]) {
        [[[IAPProducts sharedManager] store] buyProduct:product];
    }
}


@end
