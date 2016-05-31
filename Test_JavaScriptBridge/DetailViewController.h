//
//  DetailViewController.h
//  Test_JavaScriptBridge
//
//  Created by liudukun on 16/5/31.
//  Copyright © 2016年 liudukun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

