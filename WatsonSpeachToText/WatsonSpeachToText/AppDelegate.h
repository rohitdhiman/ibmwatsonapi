//
//  AppDelegate.h
//  WatsonSpeachToText
//
//  Created by Rohit on 16/01/16.
//  Copyright © 2016 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UINavigationController *navigationController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) verifyConnection;

@end

