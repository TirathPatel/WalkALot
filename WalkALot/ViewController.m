//
//  ViewController.m
//  WalkALot
//
//  Created by Tirath Patel on 2016-07-23.
//  Copyright © 2016 Tirath Patel. All rights reserved.
//

#import "ViewController.h"
#import "HealthKitManager.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    HealthKitManager *manager = [HealthKitManager sharedManager];
    [manager requestAuthorization];

    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    HKQuantityType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKUnit *unit = [HKUnit countUnit];

    
    [manager getTotalQuantitySampleOfType:sampleType unit:unit predicate:predicate completion:^(HKQuantity *quantity, NSError *error) {
        if (!quantity) {
            NSLog(@"error");
        }
        
        NSLog(@"%@", quantity);
        
        NSNumber *number = [NSNumber numberWithDouble:[quantity doubleValueForUnit:unit]];
        
        
        NSLog(@"%@", number);
        
        self.label.text = [number stringValue];
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
