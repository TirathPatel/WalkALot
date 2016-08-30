//
//  UserDataManager.h
//  WalkALot
//
//  Created by Tirath Patel on 2016-08-29.
//  Copyright © 2016 Tirath Patel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataManager : NSObject

+ (UserDataManager*)sharedManager;

@property (assign) int stepGoal;

- (void)saveData;
- (void)loadData;

@end
