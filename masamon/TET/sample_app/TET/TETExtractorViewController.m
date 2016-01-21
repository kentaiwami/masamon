//
//  TETExtractorViewController.m
//  TET_iOS
//
//  Created by Friedhelm Brügge on 01.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import "TETExtractorViewController.h"
#import "TET_ios/TET_objc.h"


@implementation TETExtractorViewController

@synthesize fileName = _fileName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    self.navigationItem.title=@"Extracted Text";

    [self extractText];
}


- (void) extractText {
    
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
    //NSString *loggingoptlist = [NSString stringWithFormat:@"logging {filename={%@/trace.txt} remove}", documentsDir];
    
    /* document-specific option list */
    NSString *docoptlist = @"";
    
    /* page-specific option list */
    NSString *pageoptlist = @"granularity=page";
    
    /* separator to emit after each chunk of text. This depends on the
     * application's needs;
     * for granularity=word a space character may be useful.
     */
#define SEPARATOR @"\n"
    
    int pageno = 0;
    NSMutableString *pdfText = [[NSMutableString alloc]init];;
    NSString *warningText=@"";
    
    TET *tet = [[TET alloc] init];
    if (!tet) {
        return;
    }
    
    @try {
        NSInteger n_pages;
        NSInteger doc;
        
        //[tet set_option:loggingoptlist];
        [tet set_option:globaloptlist];
        
        doc = [tet open_document:infile optlist:docoptlist];
        
        if (doc == -1)
        {
            warningText = [NSString stringWithFormat:@"Error %ld in %@(): %@\n",
                         (long)[tet get_errnum], [tet get_apiname], [tet get_errmsg]];
            [self displayError:warningText];
            return;
        }
        
        /* get number of pages in the document */
        n_pages = (NSInteger) [tet pcos_get_number:doc path:@"length:pages"];
        
        /* loop over pages in the document */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
            NSString *text;
            NSInteger page;
            
            page = [tet open_page:doc pagenumber:pageno optlist:pageoptlist];
            
            if (page == -1)
            {
                warningText = [NSString stringWithFormat:@"%@\nError %ld in %@() on page %d: %@\n",
                             warningText, (long)[tet get_errnum], [tet get_apiname], pageno, [tet get_errmsg]];
                continue;                        /* try next page */
            }
            
            /* Retrieve all text fragments; This is actually not required
             * for granularity=page, but must be used for other granularities.
             */
            while ((text = [tet get_text:page]) != nil)
            {
                [pdfText appendString:text];
                [pdfText appendString:SEPARATOR];
            }
            
            if ([tet get_errnum] != 0)
            {
                warningText  = [NSString stringWithFormat:@"%@\nError %ld in %@() on page %d: %@\n", warningText, (long)[tet get_errnum], [tet get_apiname], pageno, [tet get_errmsg]];
            }
            
            [tet close_page:page];
        }
        
        [tet close_document:doc];
    }
    
    @catch (TETException *ex) {
        NSString *exception=@"";
        if (pageno == 1) {
            exception = [NSString stringWithFormat:@"Error %ld in %@(): %@\n",
                         (long)[ex get_errnum], [ex get_apiname], [ex get_errmsg]];
        } else {
            exception = [NSString stringWithFormat:@"Error %ld in %@() on page %d: %@\n",
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
    
    
    /* show the warning(s) that occured while processing the file */
    if (warningText.length>0) {  
        [self displayError:warningText];
    }
    
    _textView.text=pdfText;
}


- (void) displayError: (NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TET error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alertView show];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
