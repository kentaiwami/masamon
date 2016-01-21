//
//  TETGlyphInfoViewController.h
//  TET_iOS
//
//  Created by Friedhelm Brügge on 02.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TETGlyphInfoViewController : UIViewController {
    IBOutlet UITextView *_textView;
    IBOutlet UIBarButtonItem *_firstButton;
    IBOutlet UIBarButtonItem *_lastButton;
    IBOutlet UISlider *_slider;
    IBOutlet UIToolbar *_toolBar;
    IBOutlet UIActivityIndicatorView *_activity;
    NSString *_fileName;
    NSInteger _currentPage;
    NSString *_resultText;
    BOOL _isAcitive;
}

@property (nonatomic, strong) NSString *fileName;

- (void) getGlyphInfo ;
- (void) startGlyphInfo;
- (void) doneGlyphInfo;
- (void) displayError: (NSString *) message ;
- (IBAction) sliderValueChanged:(id)sender; 
- (IBAction) buttonPressed:(id)sender;

@end
