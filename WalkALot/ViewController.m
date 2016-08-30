//
//  ViewController.m
//  WalkALot
//
//  Created by Tirath Patel on 2016-07-23.
//  Copyright © 2016 Tirath Patel. All rights reserved.
//

#import "ViewController.h"
#import "HealthKitManager.h"
#import "UserDataManager.h"

@interface ViewController ()

@property (nonatomic, strong) HealthKitManager *healthKitManager;
@property (nonatomic) NSInteger currentStepCount;
@property (nonatomic) NSInteger currentStepGoal;

@property (nonatomic, strong) IBOutlet UIView *progressContainer;
@property (nonatomic, strong) IBOutlet UIView *summaryContainer;
@property (nonatomic, strong) IBOutlet UIImageView *stepCountImage;
@property (nonatomic, strong) IBOutlet UIImageView *stepGoalImage;
@property (nonatomic, strong) IBOutlet UILabel *stepCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *stepGoalLabel;


@property (nonatomic, strong) IBOutlet UILabel *label;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentStepGoal = 10000; // temporary
    
    self.healthKitManager = [HealthKitManager sharedManager];
    [self.healthKitManager requestAuthorization];
    [self setCurrentStepCount];
    
    self.summaryContainer.layer.cornerRadius = 15.0f;
    self.stepGoalImage.layer.cornerRadius = 10.0f;
    self.stepCountImage.layer.cornerRadius = 10.0f;
    
    
    [UserDataManager sharedManager].stepGoal = 1000;
    
}

- (void)setCurrentStepCount {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [NSDate date];
    
    HKQuantityType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    HKUnit *unit = [HKUnit countUnit];
    
    [self.healthKitManager getTotalQuantitySampleOfType:sampleType
                                                   unit:unit
                                              predicate:predicate
                                             completion:^(HKQuantity *quantity, NSError *error) {
                                                 if (!quantity) {
                                                     NSLog(@"Error loading step count");
                                                     return;
                                                 }
                                                 self.currentStepCount = [quantity doubleValueForUnit:unit];//[NSNumber numberWithDouble:[quantity doubleValueForUnit:unit]];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [self updateView];
                                                 });
                                                 NSLog(@"Success loading healthkit data");
    }];
}

- (void)updateView {
    NSInteger progressPercentage = 100.0 * (CGFloat)self.currentStepCount / (CGFloat)self.currentStepGoal;
    
    self.label.text = [NSString stringWithFormat:@"%ld%%", (long)progressPercentage];
    NSLog(@"Updated UI");
    [self drawProgressBar];
    
    self.stepGoalLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentStepGoal];
    self.stepCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentStepCount];
}

- (void)drawProgressBar {
    
    CGFloat progressPercentage = 100.0 * (CGFloat)self.currentStepCount / (CGFloat)self.currentStepGoal;
    CGFloat endAngle = 2 * M_PI * (progressPercentage / 100.0) - M_PI_2;
    CGFloat startAngle = -M_PI_2;
    
    CAShapeLayer *progressCircle = [CAShapeLayer layer];
    progressCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.progressContainer.frame.size.width/2, self.progressContainer.frame.size.height/2) radius:self.progressContainer.frame.size.width/2 startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
    progressCircle.fillColor = [UIColor clearColor].CGColor;
    progressCircle.lineWidth = 20;
    if (progressPercentage < 33) {
        progressCircle.strokeColor = [UIColor redColor].CGColor;
    } else if (progressPercentage < 67) {
        progressCircle.strokeColor = [UIColor orangeColor].CGColor;
    } else {
        progressCircle.strokeColor = [UIColor greenColor].CGColor;
    }
    
    CAShapeLayer *innerCircle = [CAShapeLayer layer];
    innerCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.progressContainer.frame.size.width/2, self.progressContainer.frame.size.height/2) radius:self.progressContainer.frame.size.width/2 startAngle:startAngle endAngle:2 * M_PI - M_PI_2 clockwise:YES].CGPath;
    innerCircle.fillColor = [UIColor clearColor].CGColor;
    innerCircle.lineWidth = 20;
    innerCircle.strokeColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0f].CGColor;

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 2;
    animation.removedOnCompletion = NO;
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [progressCircle addAnimation:animation forKey:@"drawProgressCircleAnimation"];
    
    [self.progressContainer.layer addSublayer:innerCircle];
    [self.progressContainer.layer addSublayer:progressCircle];


}

#pragma mark - IBActions

- (IBAction)setGoalAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Daily Walking Goal" message:@"Set your daily step goal, the higher the better!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
