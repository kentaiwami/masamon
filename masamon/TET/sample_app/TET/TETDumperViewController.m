//
//  TETDumperViewController.m
//  TET_iOS
//
//  Created by Friedhelm Brügge on 02.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import "TETDumperViewController.h"
#import "TET_ios/TET_objc.h"


@implementation TETDumperViewController

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
    
    self.navigationItem.title=@"Dumper";
    
    _textView.text=@"";
    [self dumper];
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

- (void) dumper {
    
    // Find our documents directory
    NSArray *dirPaths; 
    NSString *documentsDir; 
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    documentsDir = [dirPaths objectAtIndex:0];
    
    NSString *infile= [documentsDir stringByAppendingPathComponent:_fileName];
    
    /* global option list */
    NSString *globaloptlist =
    [NSString stringWithFormat:@"searchpath={{%@} {%@/extractor_ios.app} {%@/extractor_ios.app/resource/cmap}}",
     documentsDir, NSHomeDirectory(), NSHomeDirectory()];    

    
    TET *tet = [[TET alloc] init];
    if (!tet) {
        [self displayError:@"TET out of memory error."];
        return;
    }
    
    @try 
    {
        NSInteger count, pcosmode, plainmetadata;
        NSInteger objtype, i, doc;
        NSString *docoptlist = @"requiredmode=minimum";
        NSMutableString *buffer = [[NSMutableString alloc]init];
        
        [tet set_option:globaloptlist];
        
        if ((doc = [tet open_document:infile optlist:docoptlist]) == -1)
        {
            NSString *errorText = [NSString stringWithFormat:@"Error %ld in %@(): %@\n",
                                   (long)[tet get_errnum], [tet get_apiname], [tet get_errmsg]];
            [self displayError:errorText];
            return;
        }
        
        /* --------- general information (always available) */
        
        pcosmode = [tet pcos_get_number:doc path:@"pcosmode"];
        
        [buffer appendFormat:@"   File name: %@\n", [tet pcos_get_string:doc path:@"filename"]];
        
        [buffer appendFormat:@" PDF version: %@\n", [tet pcos_get_string:doc path:@"pdfversionstring"]];
        
         [buffer appendFormat:@"  Encryption: %@\n",
               [tet pcos_get_string:doc path:@"encrypt/description"]];
        
         [buffer appendFormat:@"   Master pw: %@\n", [tet pcos_get_number:doc path:@"encrypt/master"] ? @"yes" : @"no"];
        
         [buffer appendFormat:@"     User pw: %@\n",
                [tet pcos_get_number:doc path:@"encrypt/user"] ? @"yes" : @"no"];
        
         [buffer appendFormat:@"Text copying: %@\n",
                [tet pcos_get_number:doc path:@"encrypt/nocopy"] ? @"yes" : @"no"];
        
         [buffer appendFormat:@"  Linearized: %@\n",
                [tet pcos_get_number:doc path:@"linearized"] ? @"yes" : @"no"];
        
        if (pcosmode == 0)
        {
            [buffer appendString:@"Minimum mode: no more information available\n\n"];
            [tet close_document:doc];
            return;
        }
        
        /* --------- more details (requires at least user password) */
        
        [buffer appendFormat:@"PDF/X status: %@\n", [tet pcos_get_string:doc path:@"pdfx"]];
        
        [buffer appendFormat:@"PDF/A status: %@\n", [tet pcos_get_string:doc path:@"pdfa"]];
        
        [buffer appendFormat:@"    XFA data: %@\n",
               (int) [tet pcos_get_number:doc path:@"type:/Root/AcroForm/XFA"]
               != pcos_ot_null ? @"yes" : @"no"];
        
        [buffer appendFormat:@"  Tagged PDF: %@\n\n",
               [tet pcos_get_number:doc path:@"tagged"] ? @"yes" : @"no"];
        
        [buffer appendFormat:@"No. of pages: %d\n",
               (int) [tet pcos_get_number:doc path: @"length:pages"]];
        
        [buffer appendFormat:@" Page 1 size: width=%g, height=%g\n",
                [tet pcos_get_number:doc path:[NSString stringWithFormat:@"pages[%d]/width", 0]],
                [tet pcos_get_number:doc path:[NSString stringWithFormat:@"pages[%d]/height", 0]]];
                                              
        count = (NSInteger) [tet pcos_get_number:doc path:@"length:fonts"];
        [buffer appendFormat:@"No. of fonts: %ld\n", (long)count];
        
        for (i=0; i < count; i++)
        {
            if ([tet pcos_get_number:doc path:[NSString stringWithFormat:@ "fonts[%ld]/embedded", (long)i]])
                [buffer appendString:@"embedded "];
            else
                 [buffer appendString:@"unembedded "];
            
             [buffer appendFormat:@"%@ font ",
                   [tet pcos_get_string:doc path:[NSString stringWithFormat:@"fonts[%ld]/type", (long)i]]];
            [buffer appendFormat:@"%@\n",
                   [tet pcos_get_string:doc path:[NSString stringWithFormat:@"fonts[%ld]/name", (long)i]]];
        }
        
        [buffer appendString:@"\n"];
        
        plainmetadata = (NSInteger) [tet pcos_get_number:doc path:@"encrypt/plainmetadata"];
        
        if (pcosmode == 1 && !plainmetadata && ((NSInteger) [tet pcos_get_number:doc path:@"encrypt/nocopy"]))
        {
            [buffer appendString:@"Restricted mode: no more information available\n\n"];
            [tet close_document:doc];
            return;
        }
        
        /* --------- document info keys and XMP metadata (requires master pw
         * or plaintext metadata)
         */
        
        count = (NSInteger) [tet pcos_get_number:doc path:@"length:/Info"];
        
        for (i=0; i < count; i++)
        {
            objtype = (NSInteger) [tet pcos_get_number:doc path:[NSString stringWithFormat:@"type:/Info[%ld]", (long)i]];
            
             [buffer appendFormat:@"%@: ", [tet pcos_get_string:doc path:[NSString stringWithFormat: @"/Info[%ld].key", (long)i]]];
            
            /* Info entries can be stored as string or name objects */
            if (objtype == pcos_ot_string || objtype == pcos_ot_name)
            {
                [buffer appendFormat:@"'%@'\n",
                       [tet pcos_get_string:doc path:[NSString stringWithFormat: @"/Info[%ld]", (long)i]]];
            }
            else
            {
                [buffer appendFormat:@"(%@ object)\n",
                       [tet pcos_get_string:doc path:[NSString stringWithFormat: @"type:/Info[%ld]", (long)i]]];
            }
        }
        
        [buffer appendFormat:@"\nXMP meta data: "];
        
        objtype = (NSInteger) [tet pcos_get_number:doc path:@"type:/Root/Metadata"];
        if (objtype == pcos_ot_stream)
        {
            NSData *contents;
            
            contents = [tet pcos_get_stream:doc optlist:@"" path:@"/Root/Metadata"];
            [buffer appendFormat:@"%lu bytes ", (unsigned long)contents.length];
            
            
         // todo convert contents to unicdoe
         //   (void) TET_utf8_to_utf16(tet, contents, "utf16", &len);
            NSString *unicode = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
             [buffer appendFormat:@"(%lu Unicode characters)\n\n", (unsigned long)unicode.length/2];
        }
        else
        {
            [buffer appendString:@"not present\n\n"];
        }
        
        [tet close_document:doc];
        
        _textView.text = buffer;
    }
    
    @catch (TETException *ex) {
        NSString *exception=@"";

        exception = [NSString stringWithFormat:@"Error %ld in %@(): %@\n",
                         (long)[ex get_errnum], [ex get_apiname], [ex get_errmsg]];
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
        tet = nil;
    }   
    
    return;
}

- (void) displayError: (NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TET error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alertView show];
}




@end
