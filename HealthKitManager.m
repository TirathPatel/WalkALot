//
//  HealthKitManager.m
//  WalkALot
//
//  Created by Tirath Patel on 2016-07-23.
//  Copyright © 2016 Tirath Patel. All rights reserved.
//

#import "HealthKitManager.h"

@interface HealthKitManager ()

@property (nonatomic, retain) HKHealthStore *healthStore;

@end


@implementation HealthKitManager

+ (HealthKitManager *)sharedManager {
    static dispatch_once_t pred = 0;
    static HealthKitManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[HealthKitManager alloc] init];
        instance.healthStore = [[HKHealthStore alloc] init];
    });
    return instance;
}

# pragma mark - HealthKit Authorization

- (void)requestAuthorization {
    
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        return;
    }
    
    [self.healthStore requestAuthorizationToShareTypes:[self dataTypesToShare] readTypes:[self dataTypesToRead] completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"HealthKitManager: requestAuthorization for HealthKit failed");
        }
    }];
}

- (NSSet*)dataTypesToRead {
    HKObjectType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKCharacteristicType *ageType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    return [NSSet setWithObjects:stepCountType, ageType, nil];
}

- (NSSet*)dataTypesToShare {
    return nil;
}

# pragma mark - Reading HealthKit Data

- (void)getTotalQuantitySampleOfType:(HKQuantityType*)quantityType
                            unit:(HKUnit*)unit
                      predicate:(NSPredicate*)predicate
                     completion:(void (^)(HKQuantity *, NSError *))completion {
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType
                                                           predicate:predicate
                                                               limit:HKObjectQueryNoLimit
                                                     sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                         
                                                         if (!results) {
                                                             if (completion) {
                                                                 completion(nil, error);
                                                             }
                                                             return;
                                                         }
                                                         
                                                         if (completion) {
                                                             double sum = 0;
                                                             for (HKQuantitySample *sample in results) {
                                                                 sum += [sample.quantity doubleValueForUnit:unit];
                                                             }
                                                             HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:sum];
                                                             
                                                             completion(quantity, error);
                                                             
                                                         }
                                                         
                                                         
                                                     }];
    
    [self.healthStore executeQuery:query];
}

@end
