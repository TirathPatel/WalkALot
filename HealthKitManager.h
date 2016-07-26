//
//  HealthKitManager.h
//  WalkALot
//
//  Created by Tirath Patel on 2016-07-23.
//  Copyright © 2016 Tirath Patel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/Healthkit.h>


@interface HealthKitManager : NSObject

+ (HealthKitManager *)sharedManager;
- (void)requestAuthorization;
- (void)getTotalQuantitySampleOfType:(HKQuantityType*)quantityType
                                unit:(HKUnit*)unit
                           predicate:(NSPredicate*)predicate
                          completion:(void (^)(HKQuantity *, NSError *))completion;


@end
