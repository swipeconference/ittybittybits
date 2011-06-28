//
//  IBAAbstractCoreDataService.m
//  IttyBittyBits
//
//  Created by Oliver Jones on 24/06/11.
//  Copyright 2011 Itty Bitty Apps Pty. Ltd. All rights reserved.
//

#import "IBAAbstractCoreDataService.h"
#import "../Foundation/IBAFoundation.h"


@interface IBAAbstractCoreDataService ()

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSPersistentStoreCoordinator *)newPersistentStoreCoordinatorWithObjectModel:(NSManagedObjectModel *)model 
                                                                      storeURL:(NSURL*)storeURL;

- (void) handleUnresolvedError:(NSError *)error;
@end

@implementation IBAAbstractCoreDataService

IBA_SYNTHESIZE(defaultManagedObjectContext, 
               managedObjectModel, 
               persistentStoreCoordinator,
               delegate);

- (id) initWithObjectModelURL:(NSURL *)modelURL
                     storeURL:(NSURL *)storeURL
{
    if ((self = [super init]))
    {
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        IBA_PROPERTY_IVAR(managedObjectModel) = model;
        IBA_PROPERTY_IVAR(persistentStoreCoordinator) = [self newPersistentStoreCoordinatorWithObjectModel:model 
                                                                                                  storeURL:storeURL];
        IBA_PROPERTY_IVAR(defaultManagedObjectContext) = [self newManagedObjectContext];
    }
    
    return self;
}

/*!
 Deallocates the memory occupied by the receiver.
 */
- (void)dealloc
{
    self.delegate = nil;
    
    IBA_RELEASE_PROPERTY(defaultManagedObjectContext);
    IBA_RELEASE_PROPERTY(managedObjectModel);
    IBA_RELEASE_PROPERTY(persistentStoreCoordinator);
    
    [super dealloc];

}

/*!
 \brief     Subclasses should override this method to better handle unresolved errors.
 \details   The default implementation calls abort() and will crash the app.
 */
- (void) handleUnresolvedError:(NSError *)error
{
    // FIXME: Not so much handling going on here.

    /*
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
     */
    
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
}

/*!
 \brief     Save the managed object context.
 */
- (void)save
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.defaultManagedObjectContext;
    if ([managedObjectContext hasChanges] && [managedObjectContext save:&error] == NO)
    {
        if ([self.delegate respondsToSelector:@selector(dataService:didFailToSaveManagedObjectContext:withError:)] == NO ||
            [self.delegate dataService:self didFailToSaveManagedObjectContext:managedObjectContext withError:error] == NO)
        {
            [self handleUnresolvedError:error];
        }
    }     
}

/*!
 \brief     Create a new object context tied to the service's persistent store.
 */
- (NSManagedObjectContext *)newManagedObjectContext 
{
	NSManagedObjectContext *context = [NSManagedObjectContext new];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
	return context;
}

/*!
 \brief     Subclasses can override this this method to respond to errors adding the persistent store to the coordinator.
 \return    YES to retry creating the persistent store coordinator; otherwise NO.
 
 Typical reasons for an error here include:
 * The persistent store is not accessible;
 * The schema for the persistent store is incompatible with current managed object model.
 Check the error message to determine what the actual problem was.
 
 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
 
 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
 * Simply deleting the existing store:
 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
 
 * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
 
 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
 */
- (BOOL) shouldRetryAddingPersistentStoreForModel:(NSManagedObjectModel *)model 
                                         storeURL:(NSURL *)storeURL 
                                        withError:(NSError *)error
{
    [self handleUnresolvedError:error];
    return NO;
}

/*!
 \brief     Factory method to create a persistent store cooridinator with the specified \a model and \a storeURL.
 */
- (NSPersistentStoreCoordinator *)newPersistentStoreCoordinatorWithObjectModel:(NSManagedObjectModel *)model 
                                                                      storeURL:(NSURL*)storeURL
{
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    BOOL retry = NO;
    do {
        NSError *error = nil;
        if ([coordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                      configuration:nil 
                                                URL:storeURL 
                                            options:nil 
                                              error:&error] == NO)
        {
            retry = [self shouldRetryAddingPersistentStoreForModel:model storeURL:storeURL withError:error];   
        }
    } while (retry);        
    
    return coordinator;
}

@end