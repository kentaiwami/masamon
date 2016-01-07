//
//  TETViewController.m
//  TET_iOS
//
//  Created by Friedhelm Brügge on 01.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import "TETViewController.h"
#import "TETDetailViewController.h"

@implementation TETViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // PDFlib orange navigationBar
    self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:15.0/255.0 alpha:1];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *resourcePath = bundle.resourcePath;
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    NSArray *resourceFiles = [fileManager contentsOfDirectoryAtPath: resourcePath error:nil];
    
    // Copy all resource .PDFs to document directory
    _files = [[NSMutableArray alloc] init ];
    for (NSString *fileName in resourceFiles) {
        NSString *extension;
        if (fileName.length < 4) {
            extension = @"";
        } else {
            extension = [fileName substringWithRange:NSMakeRange(fileName.length-4, 4)];
        }
        if ([[extension uppercaseString] isEqualToString:@".PDF"]) {
            NSString *documentsFile = [documentPath stringByAppendingPathComponent:fileName];
            if (![fileManager fileExistsAtPath:documentsFile]) {
                NSString *resourcesFile = [resourcePath stringByAppendingPathComponent:fileName];
                [fileManager copyItemAtPath:resourcesFile toPath:documentsFile error:nil];
            
            }
        }
    }
    
    // add all .PDF filenames in the documents directory
    NSArray *documentFiles = [fileManager contentsOfDirectoryAtPath: documentPath error:nil];

    for (NSString *fileName in documentFiles) {
        NSString *extension = [fileName substringWithRange:NSMakeRange(fileName.length-4, 4)];
        if ([[extension uppercaseString] isEqualToString:@".PDF"]) {
            [_files addObject:fileName];
        }
    }
    
    
    self.navigationItem.title=@"TET Examples";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text=[_files objectAtIndex:indexPath.row];    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     
     TETDetailViewController *detailViewController = [[TETDetailViewController alloc] initWithNibName:@"TETDetailViewController" bundle:nil];
 
    detailViewController.fileName = [_files objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
     
}



@end
