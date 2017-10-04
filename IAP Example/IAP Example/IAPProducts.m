//
//  IAPPuzzlePlanetProducts.m
//  IAP Example
//
//  Created by Stanle De La Cruz on 9/25/17.
//  Copyright © 2017 Stanle De La Cruz. All rights reserved.
//

#import "IAPProducts.h"

@implementation IAPProducts
@synthesize store;

static NSString * const key1 = @"IAP Keys";


+ (id)sharedManager {
    static IAPProducts *sharedManager = nil;
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        store = [[IAPManager alloc] init:[NSSet setWithObjects:key1, nil]];
    }
    return self;
}

@end
