//
//  TETImageResourceTableViewController.m
//  TET_iOS
//
//  Created by Friedhelm Brügge on 01.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import "TETImageResourceTableViewController.h"
#import "TET_ios/TET_objc.h"


@implementation TETImageResourceTableViewController

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

    self.navigationItem.title=@"Images";
    
    [self extractImages];
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
#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.imageView.image=[_images objectAtIndex:indexPath.row];
    cell.imageView.contentMode=UIViewContentModeScaleAspectFit;
    cell.textLabel.text=[NSString stringWithFormat:@"Image %d", (int)indexPath.row+1];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%0.f x %0.f pixel", cell.imageView.image.size.width, cell.imageView.image.size.height];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


- (void) extractImages {  
    _images = [[NSMutableArray alloc] init];

    // Find our documents directory
    NSArray *dirPaths; 
    NSString *documentsDir; 
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    documentsDir = [dirPaths objectAtIndex:0];
    
    /* for simplicity we use hardcoded filenames */
    NSString *infile= [documentsDir stringByAppendingPathComponent:_fileName];
    
    /* global option list */
    NSString *globaloptlist =
    [NSString stringWithFormat:@"searchpath={{%@} {%@/extractor_ios.app} {%@/extractor_ios.app/resource/cmap}}",
     documentsDir, NSHomeDirectory(), NSHomeDirectory()];
    
    /* option list to switch on TET logging */
    NSString *loggingoptlist = [NSString stringWithFormat:@"logging {filename={%@/trace.txt} remove}", documentsDir];

    /* document-specific option list */
    NSString *docoptlist = @"";
    
    /* page-specific option list */
    NSString *pageoptlist = @"";

    volatile long pageno = 0;
    NSString *warningText=@"";
        
    TET *tet = [[TET alloc] init];
    if (!tet) {
        [self displayError:@"TET out of memory error."];
        return;
    }
    
    
    @try {
        NSInteger pageno, n_pages;
        NSInteger imageid, n_images;
        NSInteger doc;
        
        [tet set_option:loggingoptlist];
        [tet set_option:globaloptlist];
        
        doc = [tet open_document:infile optlist:docoptlist];
        
        if (doc == -1)
        {
            warningText = [NSString stringWithFormat:@"Error %ld in %@(): %@\n",
                         (long)[tet get_errnum], [tet get_apiname], [tet get_errmsg]];
            [self displayError:warningText];
            return;
        }
        
        /* Images will only be merged upon opening a page.
         * In order to enumerate all merged image resources
         * we open all pages before extracting the images.
         */
        
        /* get number of pages in the document */
        n_pages = (NSInteger) [tet pcos_get_number:doc path:@"length:pages"];
        
        /* loop over pages in the document */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
            NSInteger page;
            
            page = [tet open_page:doc pagenumber:pageno optlist:pageoptlist];
            
            if (page == -1)
            {
                warningText = [NSString stringWithFormat:@"%@\nError %ld in %@() on page %ld: %@\n",
                             warningText, (long)[tet get_errnum], [tet get_apiname], (long)pageno, [tet get_errmsg]];
                continue;                          /* try next page */
            }
            
            if ([tet get_errnum] != 0)
            {
                warningText = [NSString stringWithFormat:@"%@\nError %ld in %@() on page %ld: %@\n",
                             warningText, (long)[tet get_errnum], [tet get_apiname], (long)pageno, [tet get_errmsg]];
            }
            [tet close_page:page];
        }
        
        /* get number of image resources in the document */
        n_images = [tet pcos_get_number:doc path: @"length:images"];
        
        /* loop over image resources in the document */
        for (imageid = 0; imageid < n_images; imageid++)
        {
            /* examine image type */
            int mergetype = [tet pcos_get_number:doc path:[NSString stringWithFormat: @"images[%ld]/mergetype", (long)imageid]];
            
            /* skip images which have been consumed by merging */
            if (mergetype == 0 || mergetype == 1)
            {
                //[tet get_image_info:imageid];
                
                /*
                 * Fetch the image data 
                 */               
                NSData *imageData = [tet get_image_data:doc imageid:imageid optlist:nil];
                UIImage *image = [UIImage imageWithData:imageData];
                
                NSLog(@"%0.1f/%0.1f", image.size.width, image.size.height);
                [_images addObject:image];                
             }
        }        
        [tet close_document:doc];
    }
    @catch (TETException *ex) {
        NSString *exception=@"";
        if (pageno == 1) {
            exception = [NSString stringWithFormat:@"Error %ld in %@(): %@\n",
                         (long)[ex get_errnum], [ex get_apiname], [ex get_errmsg]];
        } else {
            exception = [NSString stringWithFormat:@"Error %ld in %@() on page %ld: %@\n",
                         (long)[ex get_errnum], [ex get_apiname], pageno, [ex get_errmsg]];
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TET crashed" message:exception 
                                                           delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alertView show];
    }
    @catch (NSException *ex) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[ex name] message:[ex reason]
                                                           delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    @finally {
        if (tet)
            tet = nil;
    }   
        
    if (warningText.length>0) {  
        [self displayError:warningText];
    }
}

- (void) displayError: (NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TET error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alertView show];
}


@end
