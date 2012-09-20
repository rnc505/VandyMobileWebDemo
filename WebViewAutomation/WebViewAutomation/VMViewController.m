//
//  VMViewController.m
//  WebViewAutomation
//
//  Created by Robby Cohen on 9/18/12.
//  Copyright (c) 2012 Robby Cohen. All rights reserved.
//

#import "VMViewController.h"
@interface VMViewController ()
@end

@implementation VMViewController

-(void)submitButtonClicked:(id)sender
{
    [self.emailLabel resignFirstResponder];
    [self.passwordLabel resignFirstResponder];
    [self.statusLabel setText:@"STATUS - Waiting for keyboard to close"];
    [self performSelector:@selector(fillInValues) withObject:nil afterDelay:1.0];
    
}

-(void)fillInValues{
    [self.statusLabel setText:@"STATUS - Filling in values"];
    NSString *usernameJavascript = [NSString stringWithFormat:@"document.loginForm.username.value = \"%@\";",self.emailLabel.text];
    NSString *passwordJavascript = [NSString stringWithFormat:@"document.loginForm.password.value = \"%@\";",self.passwordLabel.text];
    isPerformingJavascript = YES;
    [self.webView stringByEvaluatingJavaScriptFromString:usernameJavascript];
    isPerformingJavascript = YES;
    [self.webView stringByEvaluatingJavaScriptFromString:passwordJavascript];
    [self.statusLabel setText:@"STATUS - Hitting Submit"];
    [self performSelector:@selector(hitSubmit) withObject:nil afterDelay:1.0];

}
-(void)hitSubmit{
    NSString *submitJavascript = [NSString stringWithFormat:@"document.loginForm.submit.click()"];
    isPerformingJavascript = YES;
    [self.webView stringByEvaluatingJavaScriptFromString:submitJavascript];
    [self.statusLabel setText:@"STATUS - Logging in..."];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.8) Gecko/20100722 Firefox/3.6.8", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    NSString *url = @"https://anchorlink.vanderbilt.edu/account/logon";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.statusLabel setText:@"STATUS - Loading UIWebView"];
    [self.submitBtn setEnabled:NO];
    [self.webView loadRequest:request];
    isPerformingJavascript = NO;
    currentElement = @"";
    self.positions = [NSMutableArray new];
    self.groups = [NSMutableArray new];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (isPerformingJavascript) {
        isPerformingJavascript = NO;
        return;
    }
    if(!self.submitBtn.enabled) {
        isPerformingJavascript = YES;
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0, %d);",150]];
        [self.statusLabel setText:@"STATUS - UIWebView loaded - Waiting for Submit to be clicked"];
        [self.submitBtn setEnabled:YES];
    } else {
        [self.statusLabel setText:@"STATUS - LOGGED IN AND LOADED"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://anchorlink.vanderbilt.edu/home/myorganizations"]]];
    }
    if([webView.request.URL.absoluteString isEqualToString:@"https://anchorlink.vanderbilt.edu/home/myorganizations"]){
        isPerformingJavascript = YES;
//        NSString *regex = @"<span class=\"groupList-group\">\\n\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s(.*?)<br />";
//        NSLog(@"%@",regex);
        NSString *body = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//        NSRegularExpression *regularExp = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
//        [regularExp enumerateMatchesInString:body options:0 range:NSMakeRange(0, [body length]-1) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//            NSLog(@"%@",result);
//        }];
        DTHTMLParser *parser = [[DTHTMLParser alloc] initWithData:[body dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
        [parser setDelegate:self];
        [parser parse];
        
        //        NSArray *matches1 = [regularExp matchesInString:body options:0 range:NSMakeRange(0, body.length-1)];
//        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:webView.request.HTTPBody];
//        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//span[@class='groupList-group']"]; // get the page title - this is xpath notation
//        NSLog(@"%@",elements);
////        TFHppleElement *element = [elements objectAtIndex:0];
////        NSString *myTitle = [element content];
////        NSLog(myTitle);
////        [xpathParser release];
////        [htmlData release];
    }
//    NSLog(@"%@",[webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]);

}

-(void)parserDidStartDocument:(DTHTMLParser *)parser
{
}
-(void)parser:(DTHTMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict {
//    NSLog(@"parser - started element %@ - with attributes %@",elementName,attributeDict);
    if ([elementName isEqualToString:@"span"]) {
        if ([[attributeDict objectForKey:@"class"] isEqualToString:@"groupList-group"]) {
            currentElement = @"Group";
        }
    } else if ([elementName isEqualToString:@"em"]){
        currentElement = @"Position";
    }
}
-(void)parser:(DTHTMLParser *)parser foundCDATA:(NSData *)CDATABlock{
//    NSLog(@"found CDATA : %@",[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding]);
}
-(void)parser:(DTHTMLParser *)parser foundCharacters:(NSString *)string{
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [string componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    string = [filteredArray componentsJoinedByString:@" "];
    if (string.length > 0 && currentElement.length > 0) {
        if([currentElement isEqualToString:@"Group"]){
            [self.groups addObject:string];
        } else if([currentElement isEqualToString:@"Position"]){
            [self.positions addObject:string];
        }
        currentElement = @"";
    }
}
-(void)parser:(DTHTMLParser *)parser foundComment:(NSString *)comment{
//    NSLog(@"parser found comment : %@",comment);
}
-(void)parser:(DTHTMLParser *)parser parseErrorOccurred:(NSError *)parseError{
//    NSLog(@"ERROR: %@",parseError);
}
-(void)parser:(DTHTMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data{
//    NSLog(@"parser - processing intruct, target: %@ and data :%@",target,data);
}
-(void)parser:(DTHTMLParser *)parser didEndElement:(NSString *)elementName {
//    NSLog(@"parser - ended element: %@",elementName);
}
-(void)parserDidEndDocument:(DTHTMLParser *)parser{
    UIView *showStuff = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    [showStuff setBackgroundColor:[UIColor whiteColor]];
    for (int i = 0; i < self.groups.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, ((double)i+.5)*44, 280, 44)];
        [label setNumberOfLines:0];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setFont:[UIFont systemFontOfSize:15.f]];
        [label setText:[[NSString alloc] initWithFormat:@"You are a %@ of %@",[self.positions objectAtIndex:i],[self.groups objectAtIndex:i]]];
        [showStuff addSubview:label];
    }
    [self.view addSubview:showStuff];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
