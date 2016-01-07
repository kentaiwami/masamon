//
//  TETExtractorViewController.h
//  TET_iOS
//
//  Created by Friedhelm Brügge on 01.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TETExtractorViewController : UIViewController {
    NSString *_fileName;
    IBOutlet UITextView *_textView;
}

@property (nonatomic, strong) NSString *fileName;

- (void) extractText;
- (void) displayError: (NSString *) message ;

@end
