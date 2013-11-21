
#import "WebViewController.h"

@implementation WebViewController
@synthesize url = _url;

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Valuta" style:UIBarButtonItemStylePlain target:self action:nil];
    
    CGRect appBounds = [UIScreen mainScreen].bounds;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, appBounds.size.height)];
    
    UIScrollView *webScroll = [[webView subviews]lastObject];
    [webScroll setBounces:NO];
    [webView setScalesPageToFit:YES];
    webView.delegate = self;
    webView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_url];
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
    [self.view addSubview:webView];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HUD hide:YES];
}

@end