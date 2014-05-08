//
//  VETargetViewController.m
//  Veespo
//
//  Created by Alessio Roberto on 11/10/13.
//  Copyright (c) 2013 Veespo Ltd. All rights reserved.
//

#import "VETargetViewController.h"

#import "VEELookBackManager.h"

@interface VETargetViewController () <UISearchBarDelegate, UIScrollViewDelegate> {
    NSMutableArray *target;
    NSMutableArray *searchResults;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation VETargetViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *searchButton;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.navigationController.navigationBar.tintColor = UIColorFromHex(0x231F20);
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(showSearchBar)
                        ];
    } else {
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Navbar"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"NavbarShadow"]];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor: [UIColor whiteColor]};
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x231F20);
        searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(showSearchBar)
                        ];
    }
    self.navigationItem.rightBarButtonItem = searchButton;
    
    searchResults = [[NSMutableArray alloc] init];
    target = [[NSMutableArray alloc] init];
    
    for (NSDictionary *tar in _targetList) {
       [target addObject:tar];
    }
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = UIColorFromHex(0x231F20);
    
    // create a new Search Bar and add it to the table view
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        [self.searchBar setBackgroundColor:UIColorFromHex(0x231F20)];
    else {
        [self.searchBar setBarTintColor:UIColorFromHex(0x231F20)];
        [self.searchBar setTintColor:[UIColor whiteColor]];
    }
    [self.searchBar setShowsCancelButton:YES];
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // scroll the search bar off-screen
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)filterData
{
    [searchResults removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.desc1 contains[cd] %@", self.searchBar.text];
    searchResults = [[target filteredArrayUsingPredicate:predicate] mutableCopy];
}

- (void)showSearchBar
{
    // scroll the search bar on-screen
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - SearchBar delegate

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self filterData];
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self viewWillAppear:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UIScrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *headerImageView;
    UILabel *newsTitleLbl;
    UIView *headerBackground;
    UIView *headerView;
    
    headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    headerBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    newsTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 300, 18)];
    
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView setClipsToBounds:NO];
    
    headerBackground.backgroundColor = UIColorFromHex(0x231F20);
    
    headerImageView.backgroundColor = [UIColor clearColor];
    headerImageView.image = [UIImage imageNamed:@"header_tabella.png"];
    [headerImageView setContentMode:UIViewContentModeScaleToFill];
    
    newsTitleLbl.textColor = [UIColor whiteColor];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        newsTitleLbl.backgroundColor = [UIColor clearColor];
    }
    newsTitleLbl.textAlignment = NSTextAlignmentCenter;
    newsTitleLbl.text = NSLocalizedString(@"Target List", nil);
    newsTitleLbl.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    
    [headerView addSubview:headerBackground];
    [headerView addSubview:headerImageView];
    [headerView addSubview:newsTitleLbl];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searchResults.count == 0) {
        return target.count;
    } else
        return searchResults.count;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColorFromHex(0xFFFFFF) : UIColorFromHex(0xF1F1F2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    if (searchResults.count == 0) {
     NSDictionary *dict = [target objectAtIndex:indexPath.row];
        cell.textLabel.text = dict[@"desc1"];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:17];
    } else {
        NSDictionary *dict = [searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = dict[@"desc1"];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:17];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
#ifdef VEESPO
    NSDictionary *dict = [target objectAtIndex:indexPath.row];
    
    NSDictionary *p = @{@"question": @{
                                @"text": NSLocalizedString(@"Veespo Question", nil)
                                }
                        };
    
    VEVeespoViewController *veespoViewController = [[VEVeespoViewController alloc] initWidgetWithToken:self.token target:dict[@"target"] targetParameters:nil parameters:p detailsView:nil];
    
    veespoViewController.closeVeespoViewController = ^(NSDictionary *data){
        [self dismissViewControllerAnimated:YES completion:^{
            [[VEELookBackManager sharedManager] stopRecording];
        }];
    };
    
    [veespoViewController showWidget:^(NSDictionary *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", nil)
                                                        message:NSLocalizedString(@"Veespo Error", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"Veespo Error: %@", error);
        [self dismissViewControllerAnimated:YES completion:^{
            [[VEELookBackManager sharedManager] stopRecording];
        }];
    }];

    [[VEELookBackManager sharedManager] startRecording];
#endif

}

@end
