//
//  IAPManager.h
//  IAP Example
//
//  Created by Stanle De La Cruz on 9/22/17.
//  Copyright © 2017 Stanle De La Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IAPManager : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver>
- (instancetype)init:(NSSet*)productIds;
- (void) requestProducts:(void (^)(BOOL success, NSArray<SKProduct*>* products))block;
@property (nonatomic, copy) void (^ProductsRequestCompletionHandler)(BOOL success, NSArray<SKProduct*>* products);
- (BOOL) canMakePayments;
- (void) buyProduct:(SKProduct*)product;
@end
