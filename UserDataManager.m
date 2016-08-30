//
//  UserDataManager.m
//  WalkALot
//
//  Created by Tirath Patel on 2016-08-29.
//  Copyright © 2016 Tirath Patel. All rights reserved.
//

#import "UserDataManager.h"

NSString * const kStepGoal = @"kStepGoal";

@implementation UserDataManager

- (id)init {
    self = [super init];
    if (self) {
        self.stepGoal = 10000;
    }
    return self;
}


+ (UserDataManager*)sharedManager {
    static dispatch_once_t pred = 0;
    static UserDataManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[UserDataManager alloc] init];
    });
    return instance;
}

- (void)saveData {
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSNumber numberWithInt:self.stepGoal] forKey:kStepGoal];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadData {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kStepGoal]) {
        self.stepGoal = [[[NSUserDefaults standardUserDefaults]
                                objectForKey:kStepGoal] intValue];
    } else {
        self.stepGoal = 10000;
    }
}

@end
