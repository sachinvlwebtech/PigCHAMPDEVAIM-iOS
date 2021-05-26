//
//  DropDownSearchViewController.m
//  PigChamp
//
//  Created by Nikhil Nandre on 11/12/20.
//  Copyright © 2020 Venturelabour. All rights reserved.
//

#import "DropDownSearchViewController.h"
#import <UIKit/UIKit.h>

@interface DropDownSearchViewController ()
@end

@implementation DropDownSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableviewSearch.tableFooterView = [[UIView alloc]
    initWithFrame:CGRectZero];
    
  //  self.view.backgroundColor = [UIColor clearColor];
   // self.view.opaque = false;
    
    // Create a list to hold search results (filtered list)
    self.filteredItems = [[NSMutableArray alloc] init];
    self.arrDataToSend = [[NSMutableArray alloc] init];

    // Initially display the full list.  This variable will toggle between the full and the filtered lists.
    self.displayedItems = _arrDropDownData;
    
    // Here's where we create our UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //  self.searchController.hidesNavigationBarDuringPresentation = NO;
    //self.navigationItem.titleView = searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
    
    // Add the UISearchBar to the top header of the table view
    self.tableviewSearch.tableHeaderView = self.searchController.searchBar;
    [self.tableviewSearch registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.displayedItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * CellIdentifier = @"Cell";
    //UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [[self.displayedItems objectAtIndex:indexPath.row] valueForKey:@"visible"];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.arrDataToSend addObject:[self.displayedItems objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// When the user types in the search bar, this method gets called.
- (void)updateSearchResultsForSearchController:(UISearchController *)aSearchController
{
    NSLog(@"updateSearchResultsForSearchController");
    
    NSString *searchString = aSearchController.searchBar.text;
    NSLog(@"searchString=%@", searchString);
    
    // Check if the user cancelled or deleted the search term so we can display the full list instead.
    if (![searchString isEqualToString:@""])
    {
        [self.filteredItems removeAllObjects];
                
        NSArray *allObjects = _arrDropDownData;
        for (id obj in allObjects)
        {
            if ([[obj valueForKey:@"visible"] localizedCaseInsensitiveContainsString:searchString])
            {
                [self.filteredItems addObject:obj];
            }
        }
        self.displayedItems = self.filteredItems;
        NSLog(@"%@",self.filteredItems);
    }
    else
    {
        self.displayedItems = _arrDropDownData;
    }
    [self.tableviewSearch reloadData];
}

- (IBAction)btnCancelClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnOkClicked:(id)sender {
//    [self.delegate sendDataToDynamicForm:_arrDataToSend :_dictData];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (_arrDataToSend.count>0) {
        [self.delegate sendDataToDynamicForm:_arrDataToSend :_dictData];
    }
    else{
        [self.delegate sendDataToDynamicForm:nil :nil];
    }
}
@end
