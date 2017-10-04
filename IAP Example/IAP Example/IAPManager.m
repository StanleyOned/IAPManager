//
//  IAPManager.m
//  IAP Example
//
//  Created by Stanle De La Cruz on 9/22/17.
//  Copyright © 2017 Stanle De La Cruz. All rights reserved.
//

#import "IAPManager.h"

NSString* ProductIdentifier;

@implementation IAPManager

NSSet* productIdentifiers;
NSSet* purchasedProductIdentifiers;
SKProductsRequest* productsRequest;
static NSString * const IAPHelperPurchaseNotification = @"IAPHelperPurchaseNotification";


- (instancetype)init:(NSSet*)productIds
{
    self = [super init];
    if (self) {
        productIdentifiers = productIds;
        purchasedProductIdentifiers = [NSSet setWithObjects:ProductIdentifier, nil];
    }
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    return self;
}


- (void) requestProducts:(void (^)(BOOL success, NSArray<SKProduct*>* products))block{

    [productsRequest cancel];
    self.ProductsRequestCompletionHandler = block;
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    NSLog(@"***Manager: %lu",(unsigned long)[productIdentifiers count]);
    productsRequest.delegate = self;
    [productsRequest start];
    
}

-(void) ProductsRequestCompletionHandler:(void (^)(BOOL success, NSArray<SKProduct*>* products))block {
    self.ProductsRequestCompletionHandler = block;
}


- (void) buyProduct:(SKProduct*)product {
    NSLog(@"Buying %@",product.productIdentifier);
    SKPayment* payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (BOOL) canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

// SKPaymentTransactionObserver

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self complete:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self fail:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restore:transaction];
            default:
                break;
        }
    }
}

- (void) complete:(SKPaymentTransaction*) transaction {
    [self deliverPurchasedNotification:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) fail:(SKPaymentTransaction*) transaction {
    
    NSError *err = transaction.error;
    NSInteger transactionError = err.code;
    if(transactionError != SKErrorPaymentCancelled) {
        NSString *error = [NSString stringWithFormat:@"Transaction Error: %@", transaction.error.localizedDescription];
        NSLog(@"%@", error);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//we wont be needing this method because we are not restoring user purchase.
- (void) restore:(SKPaymentTransaction*)transaction {
    
    NSString *productIdentifier = transaction.originalTransaction.payment.productIdentifier;
    
    if(productIdentifier != NULL) {
        
        NSLog(@"restore... %@", productIdentifier);
    }
    [self deliverPurchasedNotification:productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void) deliverPurchasedNotification:(NSString*)identifier {
    
    [purchasedProductIdentifiers setByAddingObject:identifier];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:identifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperPurchaseNotification object:identifier];
}

// SKProductsRequestDelegate

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSArray<SKProduct*>* products = response.products;
    NSLog(@"Loaded list of products...");
    self.ProductsRequestCompletionHandler(YES, products);
    [self clearRequest];
}

- (void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products");
    NSLog(@"Error: %@", error.localizedDescription);
    
    self.ProductsRequestCompletionHandler(NO, NULL);
    
    [self clearRequest];
}

-(void) clearRequest {
    productsRequest = nil;
    _ProductsRequestCompletionHandler = NULL;
    
}



@end
