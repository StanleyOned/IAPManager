//
//  IAPPuzzlePlanetProducts.h
//  IAP Example
//
//  Created by Stanle De La Cruz on 9/25/17.
//  Copyright © 2017 Stanle De La Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPManager.h"

@interface IAPProducts : NSObject

@property (nonatomic, retain) IAPManager *store;

+ (id)sharedManager;
@end
