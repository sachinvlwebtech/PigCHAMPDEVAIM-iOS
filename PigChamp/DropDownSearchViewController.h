//
//  DropDownSearchViewController.h
//  PigChamp
//
//  Created by Nikhil Nandre on 11/12/20.
//  Copyright © 2020 Venturelabour. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol senddataProtocol <NSObject>
-(void)sendDataToDynamicForm:(NSMutableArray *)arrDropSelectedData :(NSDictionary*)dictData;
@end


@interface DropDownSearchViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UITableView *tableviewSearch;
- (IBAction)btnCancelClicked:(id)sender;
- (IBAction)btnOkClicked:(id)sender;


@property(nonatomic,assign)id delegate;

@property (nonatomic, strong) UISearchController * searchController;
@property (nonatomic, strong) NSMutableArray * filteredItems,*arrDataToSend;
@property (nonatomic, weak) NSArray * displayedItems,*arrDropDownData;
@property(nonatomic,retain)NSDictionary * dictData;
@end

NS_ASSUME_NONNULL_END
