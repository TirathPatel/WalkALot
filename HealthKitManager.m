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

/*- (void)readDailyStepCountForDate:(NSDate*)date {
 
 NSCalendar *calendar = [NSCalendar currentCalendar];
 
 NSDate *now = date;
 
 NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
 
 NSDate *startDate = [calendar dateFromComponents:components];
 
 NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
 
 HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
 NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
 
 HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
 if (!results) {
 NSLog(@"An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: %@.", error);
 abort();
 }
 
 dispatch_async(dispatch_get_main_queue(), ^{
 
 for (HKQuantitySample *sample in results) {
 double joules = [sample.quantity doubleValueForUnit:[HKUnit countUnit]];
 NSLog(@"%f", joules);
 }
 });
 }];
 
 [self.healthStore executeQuery:query];
 
 }*/