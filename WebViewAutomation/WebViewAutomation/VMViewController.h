//
//  VMViewController.h
//  WebViewAutomation
//
//  Created by Robby Cohen on 9/18/12.
//  Copyright (c) 2012 Robby Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMViewController : UIViewController <UIWebViewDelegate,DTHTMLParserDelegate>
{
    BOOL isPerformingJavascript;
    NSString *currentElement;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UITextField *emailLabel;
@property (nonatomic, retain) IBOutlet UITextField *passwordLabel;
@property (nonatomic, retain) IBOutlet UIButton *submitBtn;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) NSMutableArray *groups;
@property (nonatomic, retain) NSMutableArray *positions;
-(IBAction)submitButtonClicked:(id)sender;
@end
