//
//  CoreDataHandler.m
//  Created by Mangesh Karekar.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CoreDataHandler.h"
#import "LngData.h"

static CoreDataHandler * coreDataHandlerInstance = nil;

@implementation CoreDataHandler

// setting singletion class

+ (CoreDataHandler *) sharedHandler {
    @synchronized(self)
    {
        if (coreDataHandlerInstance == nil) {
            
            coreDataHandlerInstance = [[CoreDataHandler alloc] init];
        }
    }
    
    return coreDataHandlerInstance;
}

#pragma mark Managed Object Functions

// this method return NSManagedObjectContext
// call this method as
// NSManagedObjectContext *moc = defaultManagedObjectContext();

-(NSManagedObjectContext*)defaultManagedObjectContext
{
    NSManagedObjectContext *moc = nil;
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate respondsToSelector:@selector(managedObjectContext)]) {
        moc = [appDelegate managedObjectContext];
    }
    
    return moc;
}


/// called to save / commit changes
// after every insert call this method...

-(BOOL)commitDefaultMOC
{
    NSManagedObjectContext *moc = [self defaultManagedObjectContext];
    NSError *error = nil;
    if (![moc save:&error]) {
        // Save failed
        NSLog(@"Core Data Save Error: %@, %@", error, [error userInfo]);
        return NO;
    }
    return YES;

}

/// to undo the changes...
-(void)rollbackDefaultMOC
{
    NSManagedObjectContext *moc = [self defaultManagedObjectContext];
    [moc rollback];
}

/// this method will remove all managed objects from persistentStorage

-(void)removeAllmanagedObject
{
    NSError *error;
    BOOL isDeletedAllData = NO;
    // retrieve the store URL
    NSManagedObjectContext * managedObjectContext = [self defaultManagedObjectContext];
    NSURL * storeURL = [[managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [managedObjectContext lock];
    [managedObjectContext reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
        
        isDeletedAllData = YES;
    }
    
    [managedObjectContext unlock];
    [self commitDefaultMOC];
    NSLog(isDeletedAllData ? @"YES" : @"No");
}

// call this method to delete the specified managed object from storage
-(void)deleteManagedObjectContexFromDefaultMOC:(NSString*)entity
{
    @try {
        NSManagedObjectContext *context = [self defaultManagedObjectContext];
        NSFetchRequest * allMovies = [[NSFetchRequest alloc] init];
        [allMovies setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:context]];
        [allMovies setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSError * error = nil;
        NSArray * movies = [context executeFetchRequest:allMovies error:&error];
        //error handling goes here
        for (NSManagedObject * movie in movies) {
            [context deleteObject:movie];
        }
        //NSError *saveError = nil;
        //***added for logout changes Bug-27775 by M @@@@@
        NSError *saveError = nil;
        if (![context save:&saveError]) {
            NSLog(@"Save Error: %@", saveError.localizedDescription);
        }
        //@@@@@
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in deleteManagedObjectContexFromDefaultMOC =%@",exception.description);
    }
}

-(void)deleteManagedObjectFromDefaultMOC:(NSManagedObject*)managedObject
{
    NSManagedObjectContext *moc = [self defaultManagedObjectContext];
    [moc deleteObject:managedObject];
    [self commitDefaultMOC];
}


#pragma mark Insert Update Finctions

//// this method will insert all values in dictionary to managed object of type entityname.

// Method to INSERT data with entity name

/*
 
 
 this function inserts values to sqllite via core data
 
 Warning: this function assumes that the array passed to it is already validated for errors
 
 Requirements: 1. entityNames : table to be updated
 
 2. AttributeArray : array containing dictionaries which contain attributes as keys and data to be inserted as objects
 
 */


-(BOOL)insertManagedObjectsWithEntityName:(NSString*)entityName andAttributeArray:(NSArray*)attributeArray
{
    // Managed default context
    
    NSManagedObjectContext* managedObjectContext = [self defaultManagedObjectContext];
    
    // counters
    int arrayIndx;
    int objIdx;
    // Bool
    BOOL isInsertSuccessful = NO;
    
    // GET ATTRIBUTES to be inserted
    NSDictionary* dictForAttributes = [attributeArray objectAtIndex:0];
    NSArray* attributesNamesArray = [dictForAttributes allKeys];
    
    // Loop for attribute array
    for (arrayIndx=0; arrayIndx < attributeArray.count; arrayIndx++)
    {
        NSManagedObject* managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
        // values dictionary to update
        NSDictionary* getValues = [attributeArray objectAtIndex:arrayIndx];
        
        // Loop for attribute names array
        for (objIdx=0; objIdx<attributesNamesArray.count; objIdx++)
        {
            NSString * valueToInsert = [self returnStringValueWithString:[getValues objectForKey:[attributesNamesArray objectAtIndex:objIdx]] andEntity:entityName andKeyString:[attributesNamesArray objectAtIndex:objIdx]];
            
           // NSString * valueToInsert = returnStringValue([getValues objectForKey:[attributesNamesArray objectAtIndex:objIdx]] , entityName , [attributesNamesArray objectAtIndex:objIdx]);
            //            NSLog(@"String to insert : %@",valueToInsert);
            [managedObject setValue:valueToInsert forKey:[attributesNamesArray objectAtIndex:objIdx]];
            
            NSError *error = nil;
            [managedObjectContext save:&error];
            isInsertSuccessful = YES;
        }
    }
    // commit
    [self commitDefaultMOC];
    return isInsertSuccessful;
}

// Method to UPDATE data with entity name

/*
 
this function updates sqllite entries via core data
 
 Warning: this function assumes that the array passed to it is already validated for errors
 
 Requirements: 1. entityName : table to be updated
 
 2. AttributeArray : array containing dictionaries which contain attributes as keys and data to be updated as objects
 
 */

-(BOOL)updateManagedObject:(NSString*)entityName andAttributeArray:(NSArray*)attributeArray
{
    // counters
    int arrayIndx;
    int objIndx;
    // bool
    BOOL updateSuccess = NO;
    // error handling
    NSError* error;
    // get managedobjectcontext
    NSManagedObjectContext* managedObjectContextTwo = [self defaultManagedObjectContext];
    // ATTACH the ENTITY to be searched to fetch request
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContextTwo];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDescription];
    
    // get attributes names to update
    NSDictionary* sampleDict = [attributeArray objectAtIndex:0];
    NSArray* attributeNameArray = [sampleDict allKeys]; /// get all keys from dictionary
    
    // Fetch selected values
    
    NSString* predicateString = [NSString stringWithFormat:@"%@ == %@",[attributeNameArray objectAtIndex:0],[sampleDict objectForKey:[attributeNameArray objectAtIndex:0]]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
    [fetchRequest setPredicate:predicate];
    
    NSArray* matchingData = [managedObjectContextTwo executeFetchRequest:fetchRequest error:&error];
    
    // get attribute to be searched (CONvention: the first object is to be searched)
    // NSString* AttributeToSearch = [attributeNameArray objectAtIndex:0];
    
    for (arrayIndx=0; arrayIndx < attributeArray.count; arrayIndx++) {
        
        NSDictionary* dictToUpdate = [attributeArray objectAtIndex:arrayIndx];
        // get string to search (for the attribute)
        //   NSString* searchString = [dictToUpdate objectForKey:AttributeToSearch];
        
        
        
        for (objIndx=0; objIndx < attributeNameArray.count; objIndx++)
        {
            // UPDATE VALUES
            for (NSManagedObject* obj in matchingData)
            {
                // UPDATE WITH NEW VALUE FOR THE ATTRIBUTE
                
                NSString * valueToInsert = [self returnStringValueWithString:[dictToUpdate objectForKey:[attributeNameArray objectAtIndex:objIndx]] andEntity:entityName andKeyString:[attributeNameArray objectAtIndex:objIndx]];

             //   NSString * valueToInsert = returnStringValue([dictToUpdate objectForKey:[attributeNameArray objectAtIndex:objIndx]], entityName , [attributeNameArray objectAtIndex:objIndx]);
                
                
                [obj setValue:valueToInsert forKey:[attributeNameArray objectAtIndex:objIndx]];
                
                [managedObjectContextTwo save:&error];
                updateSuccess = YES;
            }
        }
    }
    
    // save
    [self commitDefaultMOC];
    return updateSuccess;
}
//~~~~added new params for Color and DEsignation for pigletidentities By M.
-(BOOL)insertBulkValuesWithCommonLookupArray:(NSArray*)commonLookupsArray andFarmsArray:(NSArray*)farmsArray andDataEntryArray:(NSArray*)dataEntryArray andGeneticsArray:(NSArray*)geneticsArray andUserParameters:(NSArray*)userParametersArray andLocations:(NSArray*)locationsArray andOperatorArray:(NSArray*)operatorArray andBreedingComapniesArray:(NSArray*)breedingCompaniesArray andCondistionsArray:(NSArray*)conditionsArray andFlagsArray:(NSArray*)flagsArray andTransportArray:(NSArray*)transportCompaniesArray andPackingPlantsArray:(NSArray*)packingPlantsArray andTreatmentsArray:(NSArray*)treatmentsArray andAdminRoutes:(NSArray*)adminRoutes andAiStuds:(NSArray*)aiStuds andHalothane:(NSArray*)halothane andPdResults:(NSArray*)pdresults andSex:(NSArray*)sex andColor:(NSArray*)color andDesignation:(NSArray*)designation andTod:(NSArray*)tod andOrigin:(NSArray*)origin andDestination:(NSArray*)destination translated:(NSArray*)arrTrnaslated conditionScore:(NSArray*)conditionScore pigletDefects:(NSArray*)pigletDefectsArray herdCategory:(NSArray*)herdCategory lesionScoreArray:(NSArray*)_LesionScoreArray lockArray:(NSArray*)lockArray leakageArray:(NSArray*)leakageArray qualityArray:(NSArray*)qualityArray standingReflexArray:(NSArray*)standingReflexArray testTypeArray:(NSArray*)testTypeArray{
    BOOL response = YES;
    NSError* error;

    NSManagedObjectContext* managedObjectContext = [self defaultManagedObjectContext];
    
    // update common lookups
    for (int counter=0; counter<commonLookupsArray.count; counter++)
    {
        NSManagedObject* commonLooupManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Common_Lookups" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [commonLookupsArray objectAtIndex:counter];
        [commonLooupManagedObject setValuesForKeysWithDictionary:dict];
      //  [managedObjectContext save:&error];
    }
    
    // update data entry items
    /*for (int counter=0; counter<dataEntryArray.count; counter++) {
          NSManagedObject* dataEntryManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Data_Entry_Items" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [dataEntryArray objectAtIndex:counter];
      //  [dataEntryManagedObject setValuesForKeysWithDictionary:dict];
        
        [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id key, id object, BOOL *stop) {
            NSLog(@"%@ key value is =  object value is  %@", key, object);
            if([key isEqualToString:@"lC"]) {
                NSLog(@"%@ detected is ic value  %@", key, object);
            }else{
                [dataEntryManagedObject setValue:object forKey:[key lowercaseString]];
            }
            

        }];
        
    //[ save:&error];
    }*/
    //~~~~added code for piglet identites By M.
    for (int counter = 0; counter < dataEntryArray.count; counter++) {
        NSManagedObject *dataEntryManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Data_Entry_Items" inManagedObjectContext:managedObjectContext];

        NSDictionary *dict = [dataEntryArray objectAtIndex:counter];

        // Iterate through the main dictionary keys and set values in the Core Data entity
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            NSLog(@"%@ key value is =  object value is  %@", key, object);
            if ([key isEqualToString:@"dka"]) {
                // Handle the nested array
                NSArray *nestedArray = (NSArray *)object;

                // Process the nested array and save it
                for (NSDictionary *nestedDict in nestedArray) {
                    NSManagedObject *nestedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Piglet_Identities" inManagedObjectContext:managedObjectContext];

                    // Convert dictionary keys to lowercase
                       NSMutableDictionary *lowercaseDict = [NSMutableDictionary dictionary];
                       [nestedDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                           [lowercaseDict setObject:object forKey:[key lowercaseString]];
                       }];

                       // Set values for the nested entity
                       [nestedObject setValuesForKeysWithDictionary:lowercaseDict];
                    // Link the nested object to the main object
                    [dataEntryManagedObject setValue:nestedObject forKey:@"dkaItems"];
                }
            }else  if([key isEqualToString:@"lC"]) {
                NSLog(@"%@ detected is ic value  %@", key, object);
            }else {
                // Set values for the main entity
                [dataEntryManagedObject setValue:object forKey:[key lowercaseString]];
            }
        }];
    }
    
    // Update location
    
    for (int counter=0; counter<locationsArray.count; counter++) {
        NSManagedObject* locationManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [locationsArray objectAtIndex:counter];
        [locationManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    // update genetics
    
    for (int counter=0; counter<geneticsArray.count; counter++) {
        NSManagedObject* geneticsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Genetics" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [geneticsArray objectAtIndex:counter];
        [geneticsManagedObject setValuesForKeysWithDictionary:dict];
    }

    
    
    // update farms
    for (int counter=0; counter<farmsArray.count; counter++) {
        NSManagedObject* farmsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Farms" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [farmsArray objectAtIndex:counter];
        
        
        [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id key, id object, BOOL *stop) {
            NSLog(@"%@ = %@", key, object);
            [farmsManagedObject setValue:object forKey:[key lowercaseString]];

        }];
        
        
        


        
      //  [farmsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    //***** user parameters- added below code for saving data from api in User_Paramaters DB by M.
    if ([userParametersArray count] > 0){
    NSManagedObject* userParametersManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"User_Parameters" inManagedObjectContext:managedObjectContext];
        //added below for server V10 issue By M.
        NSInteger serverVer = [[NSUserDefaults standardUserDefaults] integerForKey:@"ServerVersion"];
            for (NSDictionary *dict in userParametersArray) {
                
                // Assuming your entity has properties like "upFarrowingGestationLengthMax", etc.
                [userParametersManagedObject setValue:dict[@"af_can_edit_data"] forKey:@"af_can_edit_data"];
                [userParametersManagedObject setValue:dict[@"up_date_settings_fast_entry"] forKey:@"up_date_settings_fast_entry"];
                [userParametersManagedObject setValue:dict[@"up_date_settings_input_format"] forKey:@"up_date_settings_input_format"];
                [userParametersManagedObject setValue:dict[@"up_date_settings_output_format"] forKey:@"up_date_settings_output_format"];
                [userParametersManagedObject setValue:dict[@"up_farrowing_error_gestation_length"] forKey:@"up_farrowing_error_gestation_length"];
                [userParametersManagedObject setValue:dict[@"up_farrowing_gestation_length_max"] forKey:@"up_farrowing_gestation_length_max"];
                [userParametersManagedObject setValue:dict[@"up_farrowing_gestation_length_min"] forKey:@"up_farrowing_gestation_length_min"];
                [userParametersManagedObject setValue:dict[@"up_farrowing_max_liveborn"] forKey:@"up_farrowing_max_liveborn"];
                //added below condition for server V10 issue By M.
                  if(serverVer == 10){
                    NSString *newVal=[NSString stringWithFormat:@"%@", dict[@"up_farrowing_preg_check_validation"]];
                    [userParametersManagedObject setValue:newVal forKey:@"up_farrowing_preg_check_validation"];
                }
                else{
                    [userParametersManagedObject setValue:dict[@"up_farrowing_preg_check_validation"] forKey:@"up_farrowing_preg_check_validation"];
                }
                [userParametersManagedObject setValue:dict[@"up_farrowing_warn_gestation_length"] forKey:@"up_farrowing_warn_gestation_length"];
                [userParametersManagedObject setValue:dict[@"up_farrowing_warn_when_born_max"] forKey:@"up_farrowing_warn_when_born_max"];
                [userParametersManagedObject setValue:dict[@"up_farrowing_warn_when_born_zero"] forKey:@"up_farrowing_warn_when_born_zero"];
                [userParametersManagedObject setValue:dict[@"up_fosterings_double_identity"] forKey:@"up_fosterings_double_identity"];
                [userParametersManagedObject setValue:dict[@"up_list_reports_header_first_page_only"] forKey:@"up_list_reports_header_first_page_only"];
                [userParametersManagedObject setValue:dict[@"up_list_reports_sort_order_left_to_right"] forKey:@"up_list_reports_sort_order_left_to_right"];
                [userParametersManagedObject setValue:dict[@"up_movement_optimization"] forKey:@"up_movement_optimization"];
                [userParametersManagedObject setValue:dict[@"up_open_cohort_list_farm_only"] forKey:@"up_open_cohort_list_farm_only"];
                [userParametersManagedObject setValue:dict[@"up_other_settings_cycle_centric"] forKey:@"up_other_settings_cycle_centric"];
                [userParametersManagedObject setValue:dict[@"up_period_offsets_pigs_year"] forKey:@"up_period_offsets_pigs_year"];
                [userParametersManagedObject setValue:dict[@"up_period_offsets_service"] forKey:@"up_period_offsets_service"];
                [userParametersManagedObject setValue:dict[@"up_piglet_deaths_warn_when_not_reconcile"] forKey:@"up_piglet_deaths_warn_when_not_reconcile"];
                [userParametersManagedObject setValue:dict[@"up_piglet_tmts_warn_when_not_reconcile"] forKey:@"up_piglet_tmts_warn_when_not_reconcile"];
                //added below condition for server V10 issue By M.
                  if(serverVer == 10){
                    NSString *newVal=[NSString stringWithFormat:@"%@", dict[@"up_placements_warning_before_est_empty"]];
                    [userParametersManagedObject setValue:newVal forKey:@"up_placements_warning_before_est_empty"];
                }
                else{
                    [userParametersManagedObject setValue:dict[@"up_placements_warning_before_est_empty"] forKey:@"up_placements_warning_before_est_empty"];
                }
                [userParametersManagedObject setValue:dict[@"up_report_settings_pedigree_semen"] forKey:@"up_report_settings_pedigree_semen"];
                [userParametersManagedObject setValue:dict[@"up_report_settings_print_pages_warning"] forKey:@"up_report_settings_print_pages_warning"];
                [userParametersManagedObject setValue:dict[@"up_reservations_allow_auto_adjust"] forKey:@"up_reservations_allow_auto_adjust"];
                //added below condition for server V10 issue By M.
                  if(serverVer == 10){
                    NSString *newVal=[NSString stringWithFormat:@"%@", dict[@"up_reservations_period_length"]];
                    [userParametersManagedObject setValue:newVal forKey:@"up_reservations_period_length"];
                    
                }else{
                    [userParametersManagedObject setValue:dict[@"up_reservations_period_length"] forKey:@"up_reservations_period_length"];
                }
                
                [userParametersManagedObject setValue:dict[@"up_reservations_period_style"] forKey:@"up_reservations_period_style"];
                [userParametersManagedObject setValue:dict[@"up_semen_batches_warn_no_expiry_date"] forKey:@"up_semen_batches_warn_no_expiry_date"];
                [userParametersManagedObject setValue:dict[@"up_semen_batches_warn_unlimited_doses"] forKey:@"up_semen_batches_warn_unlimited_doses"];
                [userParametersManagedObject setValue:dict[@"up_shipments_auto_empty_threshold"] forKey:@"up_shipments_auto_empty_threshold"];
                [userParametersManagedObject setValue:dict[@"up_shipments_extended_selection"] forKey:@"up_shipments_extended_selection"];
                [userParametersManagedObject setValue:dict[@"up_uom_currency"] forKey:@"up_uom_currency"];
                //added below condition for server V10 issue By M.
                  if(serverVer == 10){
                    NSString *newVal=[NSString stringWithFormat:@"%@", dict[@"up_uom_unit_of_measure"]];
                    [userParametersManagedObject setValue:newVal forKey:@"up_uom_unit_of_measure"];
                    
                }else{
                    [userParametersManagedObject setValue:dict[@"up_uom_unit_of_measure"] forKey:@"up_uom_unit_of_measure"];
                }
               
                [userParametersManagedObject setValue:dict[@"up_warnings_errors_batch_entry_save_valid"] forKey:@"up_warnings_errors_batch_entry_save_valid"];
                [userParametersManagedObject setValue:dict[@"up_warnings_errors_piglet_identity_match"] forKey:@"up_warnings_errors_piglet_identity_match"];
                [userParametersManagedObject setValue:dict[@"up_warnings_errors_reconcile_to_farrow"] forKey:@"up_warnings_errors_reconcile_to_farrow"];
                [userParametersManagedObject setValue:dict[@"up_weanings_max_weaned_number"] forKey:@"up_weanings_max_weaned_number"];
                [userParametersManagedObject setValue:dict[@"up_weanings_warn_when_batch_reconcile"] forKey:@"up_weanings_warn_when_batch_reconcile"];
                [userParametersManagedObject setValue:dict[@"up_weanings_warn_when_not_reconcile_cw"] forKey:@"up_weanings_warn_when_not_reconcile_cw"];
                [userParametersManagedObject setValue:dict[@"up_weanings_warn_when_not_reconcile_no"] forKey:@"up_weanings_warn_when_not_reconcile_no"];
                [userParametersManagedObject setValue:dict[@"up_weanings_warn_when_wean_max"] forKey:@"up_weanings_warn_when_wean_max"];
                [userParametersManagedObject setValue:dict[@"up_weanings_warn_when_wean_zero"] forKey:@"up_weanings_warn_when_wean_zero"];
            }
        // Set other properties similarly...
        
        //NSError *error = nil;
       // if (![managedObjectContext save:&error]) {
           // NSLog(@"Failed to save: %@", [error localizedDescription]);
        //}
    }
    //for (int counter=0; counter<userParametersArray.count; counter++) {
      //  NSManagedObject* userParametersManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"User_Parameters" inManagedObjectContext:managedObjectContext];
        //NSDictionary* dict = [userParametersArray objectAtIndex:counter];
        //[userParametersManagedObject setValuesForKeysWithDictionary:dict];
        /*    NSManagedObject* userParametersManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"User_Parameters" inManagedObjectContext:managedObjectContext];
            NSDictionary* dict = [userParametersArray objectAtIndex:counter];
            
            
            [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                          usingBlock:^(id key, id object, BOOL *stop) {
                NSLog(@"%@ = %@", key, object);
                [userParametersManagedObject setValue:object forKey:[key lowercaseString]];

            }];*/
    //}
    
    // operator //Operator
    for (int counter=0; counter<operatorArray.count; counter++) {
        NSManagedObject* operatorManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Operator" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [operatorArray objectAtIndex:counter];
        [operatorManagedObject setValuesForKeysWithDictionary:dict];
    }

    // breeding companies // Breeding_Companies
    for (int counter=0; counter<breedingCompaniesArray.count; counter++) {
        NSManagedObject* breedingManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Breeding_Companies" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [breedingCompaniesArray objectAtIndex:counter];
        [breedingManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    // conditions // Conditions
    for (int counter=0; counter<conditionsArray.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Conditions" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [conditionsArray objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    for (int counter=0; counter<conditionScore.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ConditionScore" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [conditionScore objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    //***added below for Piglet Defect data entry - Defects-List Bug- 28548 By M.
    for (int counter=0; counter<pigletDefectsArray.count; counter++) {
        NSManagedObject* pigletdefectsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Piglet_Defects" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [pigletDefectsArray objectAtIndex:counter];
        [pigletdefectsManagedObject setValuesForKeysWithDictionary:dict];
    }
    for (int counter=0; counter<herdCategory.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"HerdCategory" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [herdCategory objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    
    //
    for (int counter=0; counter<_LesionScoreArray.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Lesion_Scores" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [_LesionScoreArray objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    for (int counter=0; counter<lockArray.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Lock" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [lockArray objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    for (int counter=0; counter<leakageArray.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Leakage" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [leakageArray objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    for (int counter=0; counter<qualityArray.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Quality" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [qualityArray objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    for (int counter=0; counter<standingReflexArray.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Standing_Reflex" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [standingReflexArray objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    for (int counter=0; counter<testTypeArray.count; counter++) {
        NSManagedObject* conditionsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Test_Type" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [testTypeArray objectAtIndex:counter];
        [conditionsManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    // flags // Flags
    for (int counter=0; counter<flagsArray.count; counter++) {
        NSManagedObject* flagsManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Flags" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [flagsArray objectAtIndex:counter];
        [flagsManagedObject setValuesForKeysWithDictionary:dict];
    }

    // transport companies // Transport_Companies
    for (int counter=0; counter<transportCompaniesArray.count; counter++) {
        NSManagedObject* transportManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Transport_Companies" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [transportCompaniesArray objectAtIndex:counter];
        [transportManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    // packing plants // Packing_Plants
    for (int counter=0; counter<packingPlantsArray.count; counter++)
    {
        NSManagedObject* packingManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Packing_Plants" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [packingPlantsArray objectAtIndex:counter];
        [packingManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    // treatments // Treatments
    for (int counter=0; counter<treatmentsArray.count; counter++)
    {
        NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Treatments" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [treatmentsArray objectAtIndex:counter];
        [treatmentManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    //Yogita
    // _ADMIN_ROUTES // _ADMIN_ROUTES
    for (int counter=0; counter<adminRoutes.count; counter++)
    {
        NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Admin_Routes" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [adminRoutes objectAtIndex:counter];
       // [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        
        [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id key, id object, BOOL *stop) {
         //   NSLog(@"%@ = %@", key, object);
            [treatmentManagedObject setValue:object forKey:[key lowercaseString]];

        }];
    }
    // _AI_STUDS // _AI_STUDS
    
    if ([aiStuds isKindOfClass:[NSArray class]]) {
        for (int counter=0; counter<aiStuds.count; counter++) {
            NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"AI_STUDS" inManagedObjectContext:managedObjectContext];
            NSDictionary* dict = [aiStuds objectAtIndex:counter];
            [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        }
    }
  
    // _BREEDING_COMPANIES
    for (int counter=0; counter<breedingCompaniesArray.count; counter++)
    {
        NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Breeding_Companies" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [breedingCompaniesArray objectAtIndex:counter];
        [treatmentManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    // _Halothane
    for (int counter=0; counter<halothane.count; counter++)
    {
        NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Halothane" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [halothane objectAtIndex:counter];
      //  [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        
        [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id key, id object, BOOL *stop) {
         //   NSLog(@"%@ = %@", key, object);
            [treatmentManagedObject setValue:object forKey:[key lowercaseString]];

        }];
    }
    
    // _PD_RESULTS
    for (int counter=0; counter<pdresults.count; counter++)
    {
        NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Pd_Results" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [pdresults objectAtIndex:counter];
       // [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        
        [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id key, id object, BOOL *stop) {
         //   NSLog(@"%@ = %@", key, object);
            [treatmentManagedObject setValue:object forKey:[key lowercaseString]];

        }];
    }
    
    // _SEX
    for (int counter=0; counter<sex.count; counter++)
    {
        NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Sex" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [sex objectAtIndex:counter];
       // [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        
        [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id key, id object, BOOL *stop) {
         //   NSLog(@"%@ = %@", key, object);
            [treatmentManagedObject setValue:object forKey:[key lowercaseString]];

        }];
    }
    //~~~~~ for piglet_identities By M.
    // _PIGLET_COLOR
   
    
    if ([color isKindOfClass:[NSArray class]]) {
        for (int counter=0; counter<color.count; counter++) {
            NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Color" inManagedObjectContext:managedObjectContext];
            NSDictionary* dict = [color objectAtIndex:counter];
            [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        }
    }
    //~~~~~ for piglet_identities By M.
    // _DESIGNATION
  
    if ([designation isKindOfClass:[NSArray class]]) {
        for (int counter=0; counter<designation.count; counter++) {
            NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Designation" inManagedObjectContext:managedObjectContext];
            NSDictionary* dict = [designation objectAtIndex:counter];
            [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        }
    }
   //~~~~~~end of M.
   
     // _TOD
    for (int counter=0; counter<tod.count; counter++)
    {
        NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Tod" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [tod objectAtIndex:counter];
      //  [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        
        [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id key, id object, BOOL *stop) {
         //   NSLog(@"%@ = %@", key, object);
            [treatmentManagedObject setValue:object forKey:[key lowercaseString]];

        }];
    }
    
    // Destination
    
    @try {
        for (int counter=0; counter<destination.count; counter++)
        {
            NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Destination" inManagedObjectContext:managedObjectContext];
            NSDictionary* dict = [destination objectAtIndex:counter];
         //   [treatmentManagedObject setValuesForKeysWithDictionary:dict];
            
            [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                          usingBlock:^(id key, id object, BOOL *stop) {
             //   NSLog(@"%@ = %@", key, object);
                [treatmentManagedObject setValue:object forKey:[key lowercaseString]];

            }];
        }
  
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception =%@",exception.description);
    }
    
    
    // Origin
    @try {
        for (int counter=0; counter<origin.count; counter++)
        {
            NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Origin" inManagedObjectContext:managedObjectContext];
            NSDictionary* dict = [origin objectAtIndex:counter];
            
            [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                          usingBlock:^(id key, id object, BOOL *stop) {
             //   NSLog(@"%@ = %@", key, object);
                [treatmentManagedObject setValue:object forKey:[key lowercaseString]];

            }];
            
            
           // [treatmentManagedObject setValuesForKeysWithDictionary:dict];
        }
    }
    
    
    
    @catch (NSException *exception) {
        
        NSLog(@"Exception =%@",exception.description);
    }
    
    for (int counter=0; counter<arrTrnaslated.count; counter++)
    {
        NSManagedObject* treatmentManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"LngData" inManagedObjectContext:managedObjectContext];
        NSDictionary* dict = [arrTrnaslated objectAtIndex:counter];
        [treatmentManagedObject setValuesForKeysWithDictionary:dict];
    }
    
    // save data
    [managedObjectContext save:&error];
    [self commitDefaultMOC];
    return response;
}

#pragma mark Fetch Functions

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    
    return context;
}
//~~~~ added function for Piglrt Identities By M.
- (NSArray *)getValuesToListWithFetchRequest:(NSFetchRequest *)fetchRequest {
    NSManagedObjectContext *context = [self defaultManagedObjectContext];;/* Get your managed object context */
    
    NSError *error = nil;
    NSArray *resultArray = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error fetching data: %@", error.localizedDescription);
        return nil;
    }

    return resultArray;
}
-(NSArray*)getValuesBarnRoomPen:(NSString*)entityName column:(NSString*)column andPredicate:(NSPredicate*)predicate andSortDescriptors:(NSArray*)sortDescriptors{
    static NSString * fetchRequestString = @"fetchResults";
    NSArray *fetchResults;
    
    @synchronized (fetchRequestString)
    {
        NSManagedObjectContext * moc = [self defaultManagedObjectContext];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setPredicate:predicate];
        fetchRequest.resultType = NSDictionaryResultType;
        fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:[[entity propertiesByName] objectForKey:column],nil];//
        fetchRequest.returnsDistinctResults = YES;
        NSError *error = nil;
        
        if ([moc hasChanges]) {
            
            if (![moc save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful
                // during development. If it is not possible to recover from the error, display an alert
                // panel that instructs the user to quit the application by pressing the Home button.
                //
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
        NSLog(@"fetchRequest : %@",fetchRequest);
        fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
    }
    
    return fetchResults;
}

-(NSArray*)getValuesToListWithEntityName:(NSString*)entityName andPredicate:(NSPredicate*)predicate andSortDescriptors:(NSArray*)sortDescriptors
{
    static NSString * fetchRequestString = @"fetchResults";
    NSArray *fetchResults;
    
    @synchronized (fetchRequestString)
    {
        NSManagedObjectContext * moc = [self defaultManagedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptors];
        NSError *error = nil;

        if ([moc hasChanges]) {
            
            if (![moc save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful
                // during development. If it is not possible to recover from the error, display an alert
                // panel that instructs the user to quit the application by pressing the Home button.
                //
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
        NSLog(@"fetchRequest : %@",fetchRequest);
        fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
    }
    
    return fetchResults;
}
-(NSString*)getTranslatedTextForString:(NSString*)Checkstring{
    static NSString * fetchRequestString = @"fetchResults";
    NSString *fetchResults;
    
    @synchronized (fetchRequestString)
    {
        //        NSString *searchString = @"John  Sm ";
        //        NSArray *words = [searchString componentsSeparatedByString:@" "];
        
        NSMutableArray *predicateList = [NSMutableArray array];
            if ([Checkstring length] > 0) {
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"englishText == [c] %@",Checkstring];
                [predicateList addObject:pred];
            }
        // NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateList];
        NSCompoundPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateList];
        
        // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"englishText IN %@", arrayOfIds];
        NSManagedObjectContext * moc = [self defaultManagedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"LngData" inManagedObjectContext:moc]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        
        if ([moc hasChanges]){
            
            if (![moc save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
        
        fetchResults = (NSString*)[moc executeFetchRequest:fetchRequest error:&error];
    }
    
    return fetchResults;
}
-(NSArray*)getTranslatedText:(NSMutableArray*)arrayOfIds{
    static NSString * fetchRequestString = @"fetchResults";
    NSArray *fetchResults;
    
    @synchronized (fetchRequestString)
    {
//        NSString *searchString = @"John  Sm ";
//        NSArray *words = [searchString componentsSeparatedByString:@" "];
        
        NSMutableArray *predicateList = [NSMutableArray array];
        for (NSString *word in arrayOfIds) {
            if ([word length] > 0) {
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"englishText == [c] %@",word];
                [predicateList addObject:pred];
            }
        }
       // NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateList];
        NSCompoundPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateList];

       // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"englishText IN %@", arrayOfIds];
        NSManagedObjectContext * moc = [self defaultManagedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"LngData" inManagedObjectContext:moc]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        
        if ([moc hasChanges]){
            
            if (![moc save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
        
        fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
    }
    
    return fetchResults;
}

-(NSArray*)getTranslated:(NSMutableArray*)arrayOfIds{
    static NSString * fetchRequestString = @"fetchResults";
    NSArray *fetchResults;
    
    @synchronized (fetchRequestString)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"englishText IN %@", arrayOfIds];
        NSManagedObjectContext * moc = [self defaultManagedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"LngData" inManagedObjectContext:moc]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        
        if ([moc hasChanges]){
            
            if (![moc save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
        
        fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
    }
    
    return fetchResults;
}
/// this method is used to get all Attributes of entity.

-(NSArray*)getAllAttributesForEntityName:(NSString*)entityName andManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSLog(@"Attributes of %@ \n %@ ",entityName,[[entity propertiesByName] allKeys]);
    return [[entity propertiesByName] allKeys];

    
}


//// this method will fetch all objects and returns count in NSinteger.


-(int)fetchCountForEntity:(NSString*)entityName
{
    NSManagedObjectContext* context = [self defaultManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    
    NSError *error;
    NSArray *fetchResults = [context executeFetchRequest:fetchRequest error:&error];
    
    NSInteger count = [context countForFetchRequest:fetchRequest error:&error];
    
    if (fetchResults == nil) {
        // Handle the error.
        NSLog(@"executeFetchRequest failed with error: %@", [error localizedDescription]);
    }
    
    NSLog(@"count : %d",(int)count);
    
    return (int)count;

}


#pragma mark Entity Delete functions

// this function will remove all entries from the specified entity name

-(void)RemoveEntriesFromEntities:(NSString*)entityName
{
    NSManagedObjectContext* context = [self defaultManagedObjectContext];
   // BOOL isdeleted ;
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * allEntries = [context executeFetchRequest:fetchRequest error:&error];
    //error handling goes here
    
    for (NSManagedObject * object in allEntries) {
        [context deleteObject:object];
       // isdeleted = YES;
    }
    NSError *saveError = nil;
    
    [context save:&saveError];
    [self commitDefaultMOC];
}



#pragma mark Validation Functions



// THIS FUNCTION WILL CHECK FOR ENTRIES IN EACH CORE DATA TABLE and return response

-(BOOL)checkCoreDataEntries
{
    BOOL result;
    
    NSArray* entitiesArray = [NSArray arrayWithObjects:@"Access_levels",@"Account_facility", nil];
    
    
    int accessLevelTableCount =   [self fetchCountForEntity:[entitiesArray objectAtIndex:0]];
    
    int accessLevelLocationCount = [self fetchCountForEntity:[entitiesArray objectAtIndex:1]];
    
    if (accessLevelTableCount == 0 && accessLevelLocationCount == 0) {
        
        result = NO;
        return result;
        
        
    }else{
        
        result = YES;
        return result;
    }
    

    
}

// THIS FUNCTION WILL CHECK FOR ENTRIES IN PROVIDED ENTITY NAME and return response

-(BOOL)checkCoreDataEntriesInEntityAndPredicateForEntityName:(NSString*)entityName andPredicate:(NSPredicate*)predicate
{
    BOOL result;
    NSArray* sortDesc = nil;
    
    NSArray* resultsArray = [self getValuesToListWithEntityName:entityName andPredicate:predicate andSortDescriptors:sortDesc];
    if (resultsArray.count>0) {
        result = YES;
    }else{
        result = NO;
    }
    return result;

}

#pragma mark String functions
/// returns the String format for any type object

-(NSString*)returnStringValueWithString:(NSString*)valueString andEntity:(NSString*)entityName andKeyString:(id)keyString
{
    // this will return the entity's sttributes disciption... here using attributeDescription to get type of attribute.
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self defaultManagedObjectContext]];
    
    NSAttributeDescription *attributeDescription = [[entityDescription attributesByName] objectForKey:keyString];
    // NSLog(@"attributeDescription : %@",attributeDescription);
    
    if ([attributeDescription attributeType] == NSStringAttributeType)
    {
        // Convert string to String object
        valueString = [NSString stringWithFormat:@"%@",valueString];
    }
    else if ([attributeDescription attributeType] == NSUndefinedAttributeType)
    {
        // Convert string to Undefined object
        
    }
    else if ([attributeDescription attributeType] == NSInteger16AttributeType)
    {
        // Convert string to integer/number object
        valueString = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",valueString] intValue]]];
    }
    else if ([attributeDescription attributeType] == NSInteger32AttributeType)
    {
        // Convert string to integer/number object
        valueString = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",valueString] intValue]]];
    }
    else if ([attributeDescription attributeType] == NSInteger64AttributeType)
    {
        // Convert string to integer/number object
        valueString = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",valueString] intValue]]];
    }
    else if ([attributeDescription attributeType] == NSDecimalAttributeType)
    {
        // Convert string to decimal object
      //  valueString = [NSDecimalNumber decimalNumberWithDecimal:[[NSString stringWithFormat:@"%@",valueString] doubleValue]];
        double tempD = [[NSDecimalNumber decimalNumberWithString:valueString] doubleValue];
        valueString = [NSString stringWithFormat:@"%f",tempD];
        
        
    }
    else if ([attributeDescription attributeType] == NSDoubleAttributeType)
    {
        // Convert string to double object
        valueString = [NSString stringWithFormat:@"%.4f",[valueString doubleValue]];
    }
    else if ([attributeDescription attributeType] == NSFloatAttributeType)
    {
        // Convert string to float object
        valueString = [NSString stringWithFormat:@"%.4f",[valueString floatValue]];
    }
    else if ([attributeDescription attributeType] == NSBooleanAttributeType)
    {
        // Convert string to boolean object
        //  valueString = (valueString) ? @"1" : @"0";
       // valueString = [NSNumber numberWithInt:[valueString intValue]];
        valueString = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:[valueString intValue]]];
    }
    else if ([attributeDescription attributeType] == NSDateAttributeType)
    {
        // Convert string to date object
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:valueString];
        valueString = [dateFormatter stringFromDate:date];
    }
    else if ([attributeDescription attributeType] == NSBinaryDataAttributeType)
    {
        // Convert string to binary data object
        
    }
    else if ([attributeDescription attributeType] == NSObjectIDAttributeType)
    {
        // Convert string to date object
        
    }
    else if ([attributeDescription attributeType] == NSTransformableAttributeType)
    {
        // Convert string to date object
    }
    
    valueString = [self checkIfNull:valueString]; /// check if valueString is null or blank...
    
    return valueString;
}

-(NSString*)checkIfNull:(NSString*)stringToCheck
{
    if([stringToCheck isEqual:@""] || [stringToCheck isEqual:[NSNull null]])
    {
        stringToCheck = @"-";
    }
    else
    {
        stringToCheck = stringToCheck;
    }
    return stringToCheck;

}



@end
