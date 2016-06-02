//
//  WebViewController.m
//  Test_JavaScriptBridge
//
//  Created by liudukun on 16/5/31.
//  Copyright © 2016年 liudukun. All rights reserved.
//

#import "WebViewController.h"
#import "WKWebViewJavascriptBridge.h"

@interface WebViewController ()<WKNavigationDelegate>
{
    WKWebView * web ;
}
@property (nonatomic,strong) WKWebViewJavascriptBridge* bridge;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    web = [[WKWebView alloc]initWithFrame:self.view.bounds];
    
    web.navigationDelegate = self;
    [self.view addSubview:web];
    [self loadPage];
}


-(void)loadPage{
//    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost"]]];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString * str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [web loadHTMLString:str baseURL:nil];
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:web ];
    [self.bridge setWebViewDelegate:self];
    [self.bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC Echo called with: %@", data);
        responseCallback(data);
    }];

    [self.bridge callHandler:@"JS Echo" data:nil responseCallback:^(id responseData) {
        NSLog(@"ObjC received response: %@", responseData);

    }];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSString *js = @"addImgClickEvent();\
    function addImgClickEvent() { \
    var imgs = document.getElementsByTagName('img'); \
    for (var i = 0; i < imgs.length; ++i) { \
    var img = imgs[i]; \
    img.onclick = function () { \
    window.location.href = 'preview_image:' + img.src; \
    }; \
    } \
    }\
    ";
    // 注入JS代码
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
//  

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"%@",navigationAction.request.URL);
    if ([navigationAction.request.URL.description hasPrefix:@"preview_image:"]) {
        // 获取原始图片的完整URL
        NSString *src = [navigationAction.request.URL.absoluteString stringByReplacingOccurrencesOfString:@"preview_image:" withString:@""];
        if (src.length > 0) {
            // 原生API展开图片
            // 这里已经拿到所点击的图片的URL了，剩下的部分，自己处理了
            // 有时候会感觉点击无响应，这是因为webViewDidFinishLoad,还没有调用。
            // 调用很晚的原因，通常是因为H5页面中有比较多的内容在加载
            // 因此，若是原生APP与H5要交互，H5要尽可能地提高加载速度
            // 不相信？在webViewDidFinishLoad加个断点就知道了
            NSLog(@"所点击的HTML中的img标签的图片的URL为：%@", src);
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


@end
