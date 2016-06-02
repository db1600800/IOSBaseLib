//
//  DealError.h
//  Philately
//
//  Created by gdpost on 15/6/25.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MsgReturn.h>


typedef void(^OKCancelBlock)(BOOL);

typedef void(^OKCancelOtherBlock)(int);

@interface PromptError : NSObject<UIAlertViewDelegate>
{
  
}

+(void) changeShowErrorMsg:(MsgReturn*)errorMsg title:(NSString*)title viewController:(UIViewController*)viewController  block:(OKCancelBlock)ablock okBtnName:(NSString*)okname cancelBtnName:(NSString*)cancelname;

+(void) changeShowErrorMsg:(MsgReturn*)errorMsg title:(NSString*)title viewController:(UIViewController*)viewController  block:(OKCancelOtherBlock)ablock okBtnName:(NSString*)okname cancelBtnName:(NSString*)cancelname out:(NSString*)outname;
  
+(void) changeShowErrorMsg:(MsgReturn*)errorMsg title:(NSString*)title viewController:(UIViewController*)viewController block:(OKCancelBlock)ablock;


@end
