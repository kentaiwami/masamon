//
//  TETGlyphInfoViewController.m
//  TET_iOS
//
//  Created by Friedhelm Brügge on 02.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import "TETGlyphInfoViewController.h"
#import "TET_ios/TET_objc.h"



@implementation TETGlyphInfoViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    _toolBar.tintColor=[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:15.0/255.0 alpha:1];
    _activity.hidden=YES;
    _textView.text=@"";
    [self startGlyphInfo];
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

- (IBAction) sliderValueChanged:(id)sender {   
    if ((int) _slider.value!=_currentPage) {
        [self startGlyphInfo];
    }
} 

- (IBAction) buttonPressed:(id)sender {
    if (sender == _firstButton) {
        [_slider setValue:_slider.minimumValue animated:YES];
    }
    if (sender == _lastButton) {
        [_slider setValue:_slider.maximumValue animated:YES];
    }
    if (_slider.value!=_currentPage) {
        [self startGlyphInfo];
    }
}

- (void) startGlyphInfo {
    if (_isAcitive) return;
    _activity.hidden=NO;
    [_activity startAnimating];
    _isAcitive=YES;
    _textView.text = [NSString  stringWithFormat: @"Loading page %d...", (int) _slider.value ];
    [self performSelectorInBackground:@selector(getGlyphInfo) withObject:nil];
}

- (void) doneGlyphInfo {
    _activity.hidden=YES;
    _isAcitive=NO;
    _textView.text = _resultText;
}


- (void) getGlyphInfo {    
    
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
    
    /* document-specific option list */
    NSString *docoptlist = @"";
    
    /* page-specific option list */
    NSString *pageoptlist = @"granularity=word";
    int pageno = 0;
    
    TET *tet = [[TET alloc] init];
    if (!tet) {
        [self displayError:@"TET out of memory error."];
        return;
    }
    
    @try 
    {
        NSInteger n_pages;
        NSInteger doc;
        NSMutableString *buffer = [[NSMutableString alloc]init];
        
        [tet set_option:globaloptlist];
        
        doc = [tet open_document:infile optlist:docoptlist];
        
        if (doc == -1)
        {  
            NSString *errorText = [NSString stringWithFormat:@"Error %ld in %@(): %@\n",
                                   (long)[tet get_errnum], [tet get_apiname], [tet get_errmsg]];
            
            [self displayError:errorText];
            return;
        }
        
        /* get number of pages in the document */
        n_pages = [tet pcos_get_number:doc path:@"length:pages"];
        _slider.maximumValue=n_pages;
        _slider.minimumValue=1;
        _lastButton.title=[NSString stringWithFormat:@"Page %ld", (long)n_pages];
        
        
        /* Select page to work with */
        pageno=_slider.value;
        _currentPage=pageno;
        
        self.navigationItem.title=[NSString stringWithFormat:@"Page %ld", (long)_currentPage];
        
        NSString *text;
        NSInteger page;
               
        page = [tet open_page:doc pagenumber:pageno optlist:pageoptlist];
        
        if (page == -1)
        {
            NSString *errorText = [NSString stringWithFormat:@"Error %ld in %@() on page %d: %@\n",
                                   (long)[tet get_errnum], [tet get_apiname], pageno, [tet get_errmsg]];
            [self displayError:errorText];
            return;                        /* try next page */
        }
        
        /* Administrative information */
        [buffer appendFormat:@"[ Document: '%@' ]\n", [tet pcos_get_string:doc path: @"filename"]];
        [buffer appendFormat:@"[ Document options: '%@' ]\n", docoptlist];
        [buffer appendFormat:@"[ Page options: '%@' ]\n", pageoptlist];
        [buffer appendFormat:@"[ ----- Page %d ----- ]\n", pageno];
        
        /* Retrieve all text fragments */
        while ((text = [tet get_text:page]))
        {
            [buffer appendFormat:@"[%@]\n",                                   text];
            
            /* Loop over all glyphs and print their details */
            while ( [tet get_char_info:page]>=0) 
            {
                if (tet.fontid<0) break;
                
                NSString *fontname;
                
                /* Fetch the font name with pCOS (based on its ID) */
                fontname = [tet pcos_get_string:doc path:[NSString stringWithFormat: @"fonts[%ld]/name", (long)tet.fontid]];
                
                /* Print the character */
                [buffer appendFormat:@"U+%04lX", (long)tet.uv];
                
                /* ...and its ASCII representation if appropriate */
                if (tet.uv >= 0x20 && tet.uv <= 0x7F)
                    [buffer appendFormat:@" '%c'", (unsigned char) tet.uv ];
                
                /* Print font name, size, and position */
                [buffer appendFormat: @" %@ size=%.2f x=%.2f y=%.2f", fontname, tet.fontsize, tet.x, tet.y];
                
                /* Examine the "type" member */
                if (tet.type == TET_CT_SEQ_START)
                    [buffer appendFormat: @" ligature_start"];
                
                else if (tet.type == TET_CT_SEQ_CONT)
                    [buffer appendFormat: @" ligature_cont"];
                
                /* Separators are only inserted for granularity > word */
                else if (tet.type == TET_CT_INSERTED)
                    [buffer appendString: @" inserted"];
                
                /* Examine the bit flags in the "attributes" member */
                if (tet.attributes != TET_ATTR_NONE)
                {
                    if (tet.attributes & TET_ATTR_SUB)
                        [buffer appendString: @"/sub"];
                    if (tet.attributes & TET_ATTR_SUP)
                        [buffer appendString: @"/sup"];
                    if (tet.attributes & TET_ATTR_DROPCAP)
                        [buffer appendString: @"/dropcap"];
                    if (tet.attributes & TET_ATTR_SHADOW)
                        [buffer appendString: @"/shadow"];
                    if (tet.attributes & TET_ATTR_DEHYPHENATION_PRE)
                        [buffer appendString: @"/dehyphenation_pre"];
                    if (tet.attributes & TET_ATTR_DEHYPHENATION_ARTIFACT)
                        [buffer appendString: @"/dehyphenation_artifact"];
                    if (tet.attributes & TET_ATTR_DEHYPHENATION_POST)
                        [buffer appendString: @"/dehyphenation_post"];
                }
                [buffer appendString: @"\n"];
            }
            [buffer appendString: @"\n"];
        }
        
        if ([tet get_errnum] != 0)
        {
            NSString *errorText = [NSString stringWithFormat:@"Error %ld in %@() on page %d: %@\n",
                                   (long)[tet get_errnum], [tet get_apiname], pageno, [tet get_errmsg]];
            [self displayError:errorText];
        }

        _resultText = buffer;
        
        [tet close_page:page];
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

    [self performSelectorOnMainThread:@selector(doneGlyphInfo) withObject:nil waitUntilDone:YES];
  
    return;
}


- (void) displayError: (NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TET error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alertView show];
}


@end
