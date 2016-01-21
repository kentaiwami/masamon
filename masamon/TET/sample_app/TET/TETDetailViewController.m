//
//  TETDetailViewController.m
//  TET_iOS
//
//  Created by Friedhelm Brügge on 01.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import "TETDetailViewController.h"
#import "TETExtractorViewController.h"
#import "TETImageResourceTableViewController.h"
#import "TETGlyphInfoViewController.h"
#import "TETDumperViewController.h"

@implementation TETDetailViewController

@synthesize fileName = _fileName;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // PDFlib orange toolbar
    _toolBar.tintColor=[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:15.0/255.0 alpha:1];
    
    self.navigationItem.title=_fileName;
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    
    NSURL *url = [NSURL fileURLWithPath:[documentPath stringByAppendingPathComponent:_fileName]];
   [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)actionButtonPressed:(id)sender {

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Run TET Test" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Extract Text", @"Extract Images", @"Glyph Info", @"Dumper" , nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            TETExtractorViewController *detailViewController = [[TETExtractorViewController alloc] initWithNibName:@"TETExtractorViewController" bundle:nil];
            
            detailViewController.fileName = _fileName;
            
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
            break;
        case 1:
        {
            TETImageResourceTableViewController *detailViewController = [[TETImageResourceTableViewController alloc] initWithNibName:@"TETImageResourceTableViewController" bundle:nil];
            
            detailViewController.fileName = _fileName;
            
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
            
            break;
        case 2:
        {
            TETGlyphInfoViewController *detailViewController = [[TETGlyphInfoViewController alloc] initWithNibName:@"TETGlyphInfoViewController" bundle:nil];
            
            detailViewController.fileName = _fileName;
            
            [self.navigationController pushViewController:detailViewController animated:YES];
        }

            
            break;
        case 3:
        {
            TETDumperViewController *detailViewController = [[TETDumperViewController alloc] initWithNibName:@"TETDumperViewController" bundle:nil];
            
            detailViewController.fileName = _fileName;
            
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
            
            
            break;        
        default:
            break;
    }
}





@end
