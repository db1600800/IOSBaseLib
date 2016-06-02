//
//  EncryptAlgorithms.m
//  PublicFramework
//
//  Created by admin on 16/1/11.
//  Copyright (c) 2016年 gdpost. All rights reserved.
//

#import "EncryptAlgorithms.h"

@implementation EncryptAlgorithms

short int wordkey;
int C1;
int C2;
int C3;
NSString *function;

// 解密函数
- (NSString*) Decrypt:(NSString *)S
{
    NSMutableArray *Result=[[NSMutableArray alloc] init ];
    NSString *str;
    int i,j;
    
    
    
    
    for(i=0; i < S.length/2; i++) // 将字符串两个字母一组进行处理
    {
        j = ( ([S  characterAtIndex:2*i]) -C3)*26;//相应的，解密处要改为相同的数
        
        j +=  ([S  characterAtIndex:2*i+1])-C3;
        
        
        str=[NSString stringWithFormat:@"%c",j]; // 设置str长度为1
        
        [Result addObject:str]; // 追加字符，还原字符串
    }
    
    // 保存中间结果
    NSMutableString *newResult=[[NSMutableString alloc] init ];
    
    for(i=0; i<[Result count]; i++) // 依次对字符串中各字符进行操作
    {
        NSString *dd= Result[i];
        unichar ddunichar;
        if ([dd isEqual:@""]) {
            ddunichar= 0x00;
        }else
        {
            ddunichar=[dd characterAtIndex:0];
        }
        
        
        int newvalue= ( ddunichar)^(wordkey>>8); // 将密钥移位后与字符异或
        
        
        [newResult appendString:[NSString stringWithFormat:@"%c",newvalue]];
        
        wordkey = ((ddunichar)+wordkey)*C1+C2; // 产生下一个密钥
        
    }
    return newResult;
}

-(void) init:(NSString*) key
{
    NSMutableString *tempkey=[[NSMutableString alloc] init];
    for(int i=0; i < [key length]; i++)
    {
        [tempkey appendFormat:@"%d", ([key  characterAtIndex:i]-[@"A"  characterAtIndex:0])];
    }
    
  
    
    if (tempkey.length>=20) {
        function= [tempkey substringWithRange:NSMakeRange(0,2)];
        wordkey= [[tempkey substringWithRange:NSMakeRange(2,5)] intValue];
        C1= [[tempkey substringWithRange:NSMakeRange(7,5)] intValue];
        C2= [[tempkey substringWithRange:NSMakeRange(12,6)] intValue];
        C3= [[tempkey substringWithRange:NSMakeRange(18,2)] intValue];
    }
    
    
    
}

@end
