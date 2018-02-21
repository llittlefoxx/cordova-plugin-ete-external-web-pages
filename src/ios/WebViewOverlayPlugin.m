//  WebViewOverlayPlugin.m

#import "WebViewOverlayPlugin.h"
#import "CDVInAppBrowser.h"

@interface WebViewOverlayPlugin()

@property (nonatomic, weak) UINavigationController* internalNavigationController;
@property (nonatomic, weak) WebViewOverlayViewController* webViewController;

@end

@implementation WebViewOverlayPlugin

- (void)open:(CDVInvokedUrlCommand*)command {
    
    NSLog(@"WebViewOverlayPlugin :: open");
    NSString* urlString = command.arguments[0];
    // NSString* urlString = @"https://www.whoishostingthis.com/tools/user-agent/";
    NSString * webViewType = command.arguments[1];
    
    NSURL* url = [NSURL URLWithString:urlString];
    NSLog(@"test -> :: %@",urlString);
    NSString* titleString = nil;
    
    if (command.arguments.count > 2) {
        titleString = command.arguments[2];
        NSLog(@"title  -> :: %@",titleString);
    }
    
    UINavigationController* navController;
    WebViewOverlayViewController* webViewController = [[WebViewOverlayViewController alloc] initWithURL:url Parameters:nil];
    self.webViewController = webViewController;
    if (self.viewController.navigationController != nil) {
        navController = self.viewController.navigationController;
        [self.viewController.navigationController pushViewController:webViewController animated:NO];
    } else {
        navController = [[UINavigationController alloc] initWithRootViewController:webViewController];
        self.internalNavigationController = navController;
        [self.viewController presentViewController:navController animated:NO completion:nil];
    }
    
    webViewController.commandDelegate = self.commandDelegate;
    webViewController.command = command;
    webViewController.title = titleString;
    if ([webViewType isEqualToString :@"simple"]){
        
        [navController setNavigationBarHidden : NO animated : NO];
        [navController setToolbarHidden : YES animated : NO];
        
    }else if ([webViewType isEqualToString :@"extended"]){
        
        [navController setNavigationBarHidden : NO animated : NO];
        [navController setToolbarHidden : NO animated : NO];
        
    }else if ([webViewType isEqualToString :@"fullscreen"]){
        
        [navController setNavigationBarHidden : YES animated : NO];
        [navController setToolbarHidden : YES animated : NO];
        
    }
}

- (void)close:(CDVInvokedUrlCommand*)command {
    NSLog(@"WebViewOverlayPlugin :: close");
    
    [self.webViewController.navigationController dismissViewControllerAnimated:NO completion:nil];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end

@interface WebViewOverlayViewController()

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) UIBarButtonItem* buttonBack;
@property (nonatomic, strong) UIBarButtonItem* buttonNext;

@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) NSArray* parameters;

@end

@implementation WebViewOverlayViewController

- (instancetype)initWithURL:(NSURL*)url Parameters:(NSArray*)parameters {
    self = [super init];
    _url = url;
    _parameters = parameters;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // [self.navigationController setToolbarHidden : YES animated : YES];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.webView setDelegate:self];
    self.webView.scrollView.bounces = NO;
    self.webView.scalesPageToFit = YES;
    self.webView.autoresizingMask = self.view.autoresizingMask;
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    [self configureWebView];
}

- (void)configureWebView {
    
    
    UIImage * closeImage =[UIImage imageNamed :@"wvo_close"];
    UIImage * previousImage =[UIImage imageNamed :@"wvo_previous"];
    UIImage * nextImage =[UIImage imageNamed :@"wvo_next"];
    
    closeImage =[closeImage imageWithRenderingMode : UIImageRenderingModeAlwaysOriginal];
    previousImage =[previousImage imageWithRenderingMode : UIImageRenderingModeAlwaysOriginal];
    nextImage =[nextImage imageWithRenderingMode : UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem * buttonClose =[[UIBarButtonItem alloc]initWithImage : closeImage style : UIBarButtonItemStylePlain target : self  action :@selector(actionBack :)];
    buttonClose.tintColor = nil;
    self.navigationItem.leftBarButtonItem = buttonClose;
    
    self.buttonBack =[[UIBarButtonItem alloc] initWithImage : previousImage style : UIBarButtonItemStylePlain target : self action :@selector(navigateBack :)];
    
    self.buttonNext =[[UIBarButtonItem alloc]initWithImage : nextImage style : UIBarButtonItemStylePlain target : self action :@selector(navigateNext :)];
    
    self.toolbarItems = @[self.buttonBack, self.buttonNext];
    
    [self updateToolbarButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
    if (self.title == nil){
        
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    [self updateToolbarButtons];
}

- (void)updateToolbarButtons {
    self.buttonBack.enabled = self.webView.canGoBack;
    self.buttonNext.enabled = self.webView.canGoForward;
}

- (void)navigateBack:(id)sender {
    [self.webView goBack];
}

- (void)navigateNext:(id)sender {
    [self.webView goForward];
}

- (void)actionBack:(id)sender {
    if ([self.navigationController.viewControllers indexOfObject:self] != 0) {
        // we are pushed on a outer navigationcontroller and so we pop just ourself
        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self.navigationController setToolbarHidden:YES animated:NO];
    } else {
        // we are the root and that is only possible if the navigation controller was manually generated in the plugin
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successful in opening WebOverlayingPlugin"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
    }
}

- (void)dealloc {
    self.webView.delegate = nil;
    [self.webView stopLoading];
}


// This selector is called when something is loaded in our webview
// By something I don't mean anything but just "some" :
//  - main html document
//  - sub iframes document
//
// But all images, xmlhttprequest, css, ... files/requests doesn't generate such events :/

- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[request URL] absoluteString];
    
    //NSLog(@"request : %@",requestString);
    
    if ([requestString hasPrefix:@"js-frame:"]) {
        
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        NSString *function = (NSString*)[components objectAtIndex:1];
        if ([function isEqualToString:@"closeMeNow"])
        {
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Close function executed"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
        }
        
        return NO;
    }
    
    return YES;
}


@end