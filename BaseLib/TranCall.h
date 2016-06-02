//
//  TranCall.h
//  Philately
//
//  Created by gdpost on 15/6/17.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceInvoker.h"

@protocol TranCallDelegate;

@interface TranCall : NSObject<ServiceInvokerDelegate>
{
    ServiceInvoker *serviceInvoker;
}


@property (strong, nonatomic) id<TranCallDelegate>  delegate;

@property (strong, nonatomic) UIViewController *viewController;

-(void)jyTranCall:(SysBaseInfo *) sysBaseInfo  cstmMsg:(CstmMsg*)cstmMsg  formName:(NSString*)formName business:(NSDictionary*)business delegate:(id<TranCallDelegate>)delegate viewController:(UIViewController*)viewController;

@end



@protocol TranCallDelegate<NSObject>

@required

//业务请求返回数据
-(void) ReturnData:(MsgReturn*)msgReturn;

-(void) ReturnError:(MsgReturn*)msgReturn;

@end