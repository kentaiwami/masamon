//
//  TETImageResourceTableViewController.h
//  TET_iOS
//
//  Created by Friedhelm Brügge on 01.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TETImageResourceTableViewController : UIViewController {
    IBOutlet UITableView *_tableView;
    NSString *_fileName;
    NSMutableArray *_images;
    
}

@property (nonatomic, strong) NSString *fileName;

- (void) extractImages ;
- (void) displayError: (NSString *) message ;

@end
