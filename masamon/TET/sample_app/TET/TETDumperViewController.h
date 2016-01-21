//
//  TETDumperViewController.h
//  TET_iOS
//
//  Created by Friedhelm Brügge on 02.02.12.
//  Copyright (c) 2012 www.bruegge.biz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TETDumperViewController : UIViewController {
    IBOutlet UITextView *_textView;
    NSString *_fileName;
}

@property (nonatomic, strong) NSString *fileName;

- (void) dumper ;
- (void) displayError: (NSString *) message ;


@end
