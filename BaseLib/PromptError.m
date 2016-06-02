//
//  DealError.m
//  Philately
//
//  Created by gdpost on 15/6/25.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import "PromptError.h"

#import "SqlApp.h"
#import "ErrorObject.h"
#import "Toast+UIView.h"
#import "SVProgressHUD.h"
@implementation PromptError


static OKCancelBlock okBlock=nil;
static OKCancelOtherBlock okOtherBlock=nil;

+(void) changeShowErrorMsg:(MsgReturn*)errorMsg title:(NSString*)title viewController:(UIViewController*)viewController  block:(OKCancelBlock)ablock okBtnName:(NSString*)okname cancelBtnName:(NSString*)cancelname
{
   
    
    
    okBlock = ablock ;
    
    SqlApp *sql=[[SqlApp alloc] init];
    
    ErrorObject *error1=[sql selectPM_CODEERRORMSG:errorMsg.errorCode];
    if(error1==nil || (error1!=nil && error1.errorDesc==nil)||(error1!=nil && [error1.errorDesc isEqualToString:@""]))
    {
        error1=[[ErrorObject alloc] init];
        error1.errorDesc=errorMsg.errorDesc;
        error1.errorCode=errorMsg.errorCode;
        error1.errorType=errorMsg.errorType;
        
    }
    
    ErrorObject *error2=[sql selectPM_DESCERRORMSG:error1];
    
    
    if (error2.errorType==nil) {
        error2.errorType=@"01";
    }
    
    
    

        
        //初始化AlertView
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:error2.errorDesc
                                                       delegate:self
                                              cancelButtonTitle:okname
                                              otherButtonTitles:cancelname,nil];
        [alert show];
    

    
  
}


+(void) changeShowErrorMsg:(MsgReturn*)errorMsg title:(NSString*)title viewController:(UIViewController*)viewController  block:(OKCancelOtherBlock)ablock okBtnName:(NSString*)okname cancelBtnName:(NSString*)cancelname out:(NSString*)outname
{
    
    
    
    okOtherBlock = ablock ;
    
    SqlApp *sql=[[SqlApp alloc] init];
    
    ErrorObject *error1=[sql selectPM_CODEERRORMSG:errorMsg.errorCode];
    if(error1==nil || (error1!=nil && error1.errorDesc==nil)||(error1!=nil && [error1.errorDesc isEqualToString:@""]))
    {
        error1=[[ErrorObject alloc] init];
        error1.errorDesc=errorMsg.errorDesc;
        error1.errorCode=errorMsg.errorCode;
        error1.errorType=errorMsg.errorType;
        
    }
    
    ErrorObject *error2=[sql selectPM_DESCERRORMSG:error1];
    
    
    if (error2.errorType==nil) {
        error2.errorType=@"01";
    }
    
    
    
    
    
    //初始化AlertView
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                    message:error2.errorDesc
                                                   delegate:self
                                          cancelButtonTitle:okname
                                          otherButtonTitles:cancelname,outname,nil];
    [alert show];
    
    
    
    
}

+(void) changeShowErrorMsg:(MsgReturn*)errorMsg title:(NSString*)title viewController:(UIViewController*)viewController  block:(OKCancelBlock)ablock ;
{
    okBlock = ablock ;
    
    SqlApp *sql=[[SqlApp alloc] init];
   
    ErrorObject *error1=[sql selectPM_CODEERRORMSG:errorMsg.errorCode];
    if(error1==nil || (error1!=nil && error1.errorDesc==nil)||(error1!=nil && [error1.errorDesc isEqualToString:@""]))
    {
        error1=[[ErrorObject alloc] init];
        error1.errorDesc=errorMsg.errorDesc;
        error1.errorCode=errorMsg.errorCode;
        error1.errorType=errorMsg.errorType;
        
    }
    
     ErrorObject *error2=[sql selectPM_DESCERRORMSG:error1];
    
    
    if (error2.errorType==nil) {
       error2.errorType=@"01";
    }
  
  
    
    if([error2.errorType isEqualToString:@"01"]||[error2.errorType isEqualToString:@"03"])//01
    { //对话框
   
        
    //初始化AlertView
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                    message:error2.errorDesc
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil,nil];

    alert.tag = 0;
 
    [alert show];
    
    }else if([error2.errorType isEqualToString:@"02"])//02
    {//toast
    
        if(title!=nil)
        {
        NSString *msg=[NSString stringWithFormat:@"%@%@",title,error2.errorDesc];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (errorMsg.errorPic) {
                    [SVProgressHUD showErrorWithStatus:msg duration:2];
                }else
                {
                   [SVProgressHUD showSuccessWithStatus:msg duration:2];
                }
            });
         
            //[viewController.view makeToast:msg];
        }else{
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (errorMsg.errorPic) {
                         [SVProgressHUD showErrorWithStatus:error2.errorDesc duration:2];
                  }else
                  {
             [SVProgressHUD showSuccessWithStatus:error2.errorDesc duration:2];
                  }
               });
         //[viewController.view makeToast:error2.errorDesc];
        }
        
    }else if([error2.errorType isEqualToString:@"05"])//03
    {
        
        //初始化AlertView
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:error2.errorDesc
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:@"取消",nil];
            [alert show];
    }
}




//根据被点击按钮的索引处理点击事件
+(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickButtonAtIndex:%d",buttonIndex);
    if(buttonIndex==0)
    {
        if(okBlock!=nil)
        okBlock(true);
        if (okOtherBlock) {
          
            okOtherBlock(0);
              okOtherBlock=nil;
        }
      
    }else  if(buttonIndex==1)
    {
         if(okBlock!=nil)
        okBlock(false);
        if (okOtherBlock) {
           
            okOtherBlock(1);
             okOtherBlock=nil;
        }
        
    }else  if(buttonIndex==2)
    {
        if(okBlock!=nil)
            okBlock(nil);
        if (okOtherBlock) {
           
            okOtherBlock(2);
             okOtherBlock=nil;
        }
        
    }
    
    
}



@end
