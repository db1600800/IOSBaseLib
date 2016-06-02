

#import "RSAUtil.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"

#define DocumentsDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define OpenSSLRSAKeyDir [DocumentsDir stringByAppendingPathComponent:@".openssl_rsa"]
#define OpenSSLRSAPublicKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"publicKey.pem"]
#define OpenSSLRSAPrivateKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"privateKey.pem"]

@implementation RSAUtil


- (id)init{
    if (self = [super init]) {
        //load RSA if it is exsit
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:OpenSSLRSAKeyDir]) {
            [fm createDirectoryAtPath:OpenSSLRSAKeyDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }return self;
}

+ (id)shareInstance{
    static RSAUtil *_opensslWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _opensslWrapper = [[self alloc] init];
    });
    return _opensslWrapper;
}





-(RSA*)generateRSA:(int)keySize
{
    
    RSA *mRsa = RSA_generate_key(keySize,RSA_F4,NULL,NULL);//公钥指数默认指定为RSA_F4(。。。)
    return mRsa;
}

-(NSString*)getPublicKeyStringX509:(RSA*) rsa
{
    //    d2i_RSAPublicKey() and i2d_RSAPublicKey() decode and encode a PKCS#1 RSAPublicKey structure.
    //
    //    d2i_RSA_PUBKEY() and i2d_RSA_PUBKEY() decode and encode an RSA public key using a SubjectPublicKeyInfo (certificate public key) structure.
    //
    //    d2i_RSAPrivateKey(), i2d_RSAPrivateKey() decode and encode a PKCS#1 RSAPrivateKey structure.
    
    //获取公钥字符串X509
    
    //http://www.cnblogs.com/emyueguang/p/4028992.html
    // 2. 从RSA结构中提取公钥到BUFF，以便将它传输给对方
    // 512位的RSA其公钥提出出来长度是74字节，而私钥提取出来有超过300字节
    // 为保险起见，建议给它们预留一个512字节的空间
    unsigned char PublicKey[2000];
    unsigned char *PKey = PublicKey; // 注意这个指针不是多余，是特意要这样做的，
    int PublicKeyLen = i2d_RSA_PUBKEY(rsa, &PKey);//x509
    
    
    NSMutableData * tempPublic = [NSMutableData dataWithCapacity:0];
    [tempPublic appendBytes:PublicKey length:PublicKeyLen];
    NSString *publicKeyX509String=[tempPublic base64EncodedString];
    
   // NSLog(@"publicKeyX509: %@",publicKeyX509String);
    
    return publicKeyX509String;
}

-(NSString*)getPublicKeyStringPKCS1:(RSA*) rsa
{
    
    //    d2i_RSAPublicKey() and i2d_RSAPublicKey() decode and encode a PKCS#1 RSAPublicKey structure.
    //
    //    d2i_RSA_PUBKEY() and i2d_RSA_PUBKEY() decode and encode an RSA public key using a SubjectPublicKeyInfo (certificate public key) structure.
    //
    //    d2i_RSAPrivateKey(), i2d_RSAPrivateKey() decode and encode a PKCS#1 RSAPrivateKey structure.
    unsigned char PublicKey[2000];
    unsigned char *PKey = PublicKey; // 注意这个指针不是多余，是特意要这样做的，
    int PublicKeyLen = i2d_RSAPublicKey(rsa, &PKey);//PKCS1
    
    
    NSMutableData * tempPublic = [NSMutableData dataWithCapacity:0];
    [tempPublic appendBytes:PublicKey length:PublicKeyLen];
    NSString *publicKeyPKCS1String=[tempPublic base64EncodedString];
    
    //NSLog(@"publicKeyPKCS1: %@",publicKeyPKCS1String);
    return @"";
}

-(NSString*)getPrivateKeyStringPKCS1:(RSA*) rsa
{
    //    d2i_RSAPublicKey() and i2d_RSAPublicKey() decode and encode a PKCS#1 RSAPublicKey structure.
    //
    //    d2i_RSA_PUBKEY() and i2d_RSA_PUBKEY() decode and encode an RSA public key using a SubjectPublicKeyInfo (certificate public key) structure.
    //
    //    d2i_RSAPrivateKey(), i2d_RSAPrivateKey() decode and encode a PKCS#1 RSAPrivateKey structure.
    
    //获取私钥字符串PKCS1
    
    unsigned char PrivateKey[4000];
    unsigned char *PKey2 = PrivateKey; // 注意这个指针不是多余，是特意要这样做的，
    int PrivateKeyLen = i2d_RSAPrivateKey(rsa, &PKey2);//PKCS1
  
      // int PrivateKeyLen = i2d_Netscape_RSA(rsa, &PKey2);//PKCS1
    
//    i2d_PKCS8PrivateKey_bio
//    i2d_PKCS8PrivateKey_fp
//    i2d_PKCS8PrivateKey_nid_bio
//    i2d_PKCS8PrivateKey_nid_fp
//    i2d_PKCS8PrivateKeyInfo_bio
//    i2d_PKCS8PrivateKeyInfo_fp
    
    //打印PublicKey信息
    NSMutableData * tempPrivate = [NSMutableData dataWithCapacity:0];
    [tempPrivate appendBytes:PrivateKey length:PrivateKeyLen];
    NSString *privateKeyPKCS1String=[tempPrivate base64EncodedString];
    NSLog(@"privateKeyPKCS1: %@",privateKeyPKCS1String);
    return privateKeyPKCS1String;
}

-(RSA*) string2PublickeyFormartPKCS1:(NSString*) publicKeyString{
    
//    
//    导出RSA公钥
//   openssl rsa -in rsa_private_key.pem -pubout -out rsa_public_key.pem
//    openssl rsa -in rsa_pem.key -pubout -out rsa_pub.der -outform DER
//    默认生成 x509格式的RSA公钥，或者加入-RSAPublicKey_out 输出PKCS1格式
//    
//    PKCS1转换到X509格式公钥
//    openssl rsa -in rsa_pub_pkcs1.der -inform DER -pubin -RSAPublicKey_in -pubout -out rsa_pub_x509.der -outform DER
   

    NSMutableString * strPublicKey = [[NSMutableString alloc] init];
    
    if(publicKeyString==NULL)
    {
    //添加普通的字符串
        [strPublicKey appendString:@"MIGJAoGBAM1BBNvjAqDbNismCCYpBlratCkbGBX7m7aCZrS4GUtCMlxCIQy/RyLzXALMkgAf2sWcxR0x2yYimhENG61gq05x/XmEtJW96G08J+z23w1ZkDqJjAx1/tzvLd+j0FG/5fgr2utlonVBDom6KsZHmonFo3kFcVSetFjqWBMAHHhTAgMBAAE="];
    }else
    {
        publicKeyString=[publicKeyString stringByReplacingOccurrencesOfString:@"\n" withString:@"" ];
        [strPublicKey appendString:publicKeyString];
    }
    
    
    
NSMutableString * newStrPublicKey = [[NSMutableString alloc] init];
    
    
    int nPublicKeyLen = [strPublicKey length];      //strPublicKey为base64编码的公钥字符串
    
    int yu=nPublicKeyLen%64;
    
    for(int i = 0; i < nPublicKeyLen/64; i++)
    {
        
        //location（索引位置）、length（截取的長度）
        
        NSString *str3 = [strPublicKey substringWithRange:NSMakeRange(i*64, 64)];//包含該索引的位置
        
        
        NSString *temp=[NSString  stringWithFormat:@"%@%@",str3,@"\n"];
        [newStrPublicKey appendString:temp];
        
        
        
    }
    if(yu==0)
    {
    
    
        
    }else
    {
        NSString *str3 = [strPublicKey substringWithRange:NSMakeRange(nPublicKeyLen/64*64, yu)];//包含該索引的位置
        
        
        NSString *temp=[NSString  stringWithFormat:@"%@%@",str3,@""];
        [newStrPublicKey appendString:temp];
    }
    

    
    [newStrPublicKey insertString:@"-----BEGIN RSA PUBLIC KEY-----\n" atIndex:0];
    [newStrPublicKey appendString:@"\n-----END RSA PUBLIC KEY-----\n"];
    
    BIO *bio = NULL;
    RSA *rsa = NULL;
    char *chPublicKey = [newStrPublicKey UTF8String];//const_cast<char *>(strPublicKey.c_str());
    if ((bio = BIO_new_mem_buf(chPublicKey, -1)) == NULL)       //从字符串读取RSA公钥
    {
        NSLog(@"%@",@"string2PublickeyFormartPKCS1 BIO_new_mem_buf failed!");
    }
    //PEM_read_bio_RSAPublicKey  PEM_read_bio_RSA_PUBKEY PEM_read_bio_RSAPrivateKey
    //PEM_read_RSA_PUBKEY() reads the PEM format. PEM_read_RSAPublicKey() reads the PKCS#1 format.
    
    rsa = PEM_read_bio_RSAPublicKey(bio, NULL, NULL, NULL);   //从bio结构中得到rsa结构
    if (!rsa)
    {

        NSLog(@"%@",@"string2PublickeyFormartPKCS1  public key failed");
        BIO_free_all(bio);
        return NULL;
    }
    BIO_free_all(bio);
    return rsa;
}



-(RSA*) string2PublickeyFormartX509:(NSString*) publicKeyString;{
    
    //
    //    导出RSA公钥
    //   openssl rsa -in rsa_private_key.pem -pubout -out rsa_public_key.pem
    //    openssl rsa -in rsa_pem.key -pubout -out rsa_pub.der -outform DER
    //    默认生成 x509格式的RSA公钥，或者加入-RSAPublicKey_out 输出PKCS1格式
    //
    //    PKCS1转换到X509格式公钥
    //    openssl rsa -in rsa_pub_pkcs1.der -inform DER -pubin -RSAPublicKey_in -pubout -out rsa_pub_x509.der -outform DER
    
    
    NSMutableString * strPublicKey = [[NSMutableString alloc] init];
    
    if(publicKeyString==NULL)
    {
        //添加普通的字符串
        [strPublicKey appendString:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCwvtXLfesOQ0FLlGwq2AoMeny3bJlaH4zi0VK4N2NVtl8XOHc/hu/txRwuOy1XMthZryAoHx8NSLQgS5PnN3vh5YMZnEN9PKSYEboafxO3CQP+hbyp2F1JgHpuN5/I9Er2Iw1EVgk/4e0OhzCXfH2Z3GWbZ/HYTzdfh8RM+l6SdwIDAQAB"];
    }else
    {
        publicKeyString=[publicKeyString stringByReplacingOccurrencesOfString:@"\n" withString:@"" ];
        [strPublicKey appendString:publicKeyString];
    }
    
    
    
    NSMutableString * newStrPublicKey = [[NSMutableString alloc] init];
    
    
    int nPublicKeyLen = [strPublicKey length];      //strPublicKey为base64编码的公钥字符串
    
    int yu=nPublicKeyLen%64;
    
    for(int i = 0; i < nPublicKeyLen/64; i++)
    {
        
        //location（索引位置）、length（截取的長度）
        
        NSString *str3 = [strPublicKey substringWithRange:NSMakeRange(i*64, 64)];//包含該索引的位置
        
        
        NSString *temp=[NSString  stringWithFormat:@"%@%@",str3,@"\n"];
        [newStrPublicKey appendString:temp];
        
        
        
    }
    if(yu==0)
    {
        
        
        
    }else
    {
        NSString *str3 = [strPublicKey substringWithRange:NSMakeRange(nPublicKeyLen/64*64, yu)];//包含該索引的位置
        
        
        NSString *temp=[NSString  stringWithFormat:@"%@%@",str3,@""];
        [newStrPublicKey appendString:temp];
    }
    
    
    
    
    
    [newStrPublicKey insertString:@"-----BEGIN PUBLIC KEY-----\n" atIndex:0];
    [newStrPublicKey appendString:@"\n-----END PUBLIC KEY-----\n"];
    
    

    
    
    BIO *bio = NULL;
    RSA *rsa = NULL;
    char *chPublicKey = [newStrPublicKey UTF8String];//const_cast<char *>(strPublicKey.c_str());
    if ((bio = BIO_new_mem_buf(chPublicKey, -1)) == NULL)       //从字符串读取RSA公钥
    {
        NSLog(@"%@",@"string2PublickeyFormartX509 BIO_new_mem_buf failed!");
    }
    //PEM_read_bio_RSAPublicKey  PEM_read_bio_RSA_PUBKEY PEM_read_bio_RSAPrivateKey
    //PEM_read_RSA_PUBKEY() reads the PEM format. PEM_read_RSAPublicKey() reads the PKCS#1 format.
    

    
    rsa = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);   //从bio结构中得到rsa结构
    if (!rsa)
    {
   
        NSLog(@"%@",@"string2PublickeyFormartX509");
        BIO_free_all(bio);
        return NULL;
    }
    BIO_free_all(bio);
 
    
    return rsa;
}




-(RSA*) string2Privatekey:(NSString*) privateKeyString{
    
    //1024位的密钥最多只能加密128个字节的明文。
    
    NSMutableString * strPrivateKey = [[NSMutableString alloc] init];
    
    if(privateKeyString==NULL)
    {
    //添加普通的字符串
        [strPrivateKey appendString:@"MIICXAIBAAKBgQCx5Ixk3UMgGLTOBPQlEYBoiKoMcWJDkzLUzeD6JVJW7vHsJpDyjeXz2cqBIkbm26ZoxPjkJhakQUp9uXCemecx1DsagdEEh205V0+0q+xCnuZH/2trubONa9D/9dfjCFkqV18vfGIl/uHiUtNxvNksQuwPPJgwmsENI8Kdf0jRIwIDAQABAoGBAJzSK+nnHHu5C/rqZwgei6Kbh7z8X3HO2+q5q/EY4aN9dYuG3BTXfrYfcuOwAe0WCXcm3XrTEPawECkRRvSqHCJaaX0Vx6gzK3xSRjRjbctZ7Mg2TKNngHkK1/UwzIIfdYS3tJtDu2UNyYxNFVt/U57YlHokXQE264p0scDlNdzBAkEA4ciJJHDPn9wCNAxMlIphWqydeh24Z3+EGnk4h5Zq1Q9BPL+CZxIWE6gsHYek933Mv0IDHGlP6Ce57nG40XKrswJBAMmzQTFBw+97he6RG1IH8Zd+PZUwhNIp93RqKvLsSGOtbm3cF/6NSX2khsZ8VctBD4qrFwN2+1ZnKMsKYRTIzNECQFRCzLumxjV4m/HkrSe6RP7b8KFEOi+V7S0cFDa1sgT1fnk3V2kz3L1VQ7F5j901O5YdAqA1xTZ0rPUJx9mSm/UCQAetwlqctVflrPijH5Yk5UauMKwAV94kaN5OuGndIvhgfubBzUwMlvKok9T0oNOHG49c6hhgrDri3IO2VnHTHzECQCFYed6CudLLddvCTJjzKmxdlTqaCLXB9gMU0+ONWffzf9KWAj6FShrVy/CEwr7Dc/xi7Nj0jvUp50P8ctO6zKU="];
    }else
    {
          privateKeyString=[privateKeyString stringByReplacingOccurrencesOfString:@"\n" withString:@"" ];
        [strPrivateKey appendString:privateKeyString];
    }
    
    NSMutableString * newStrPrivateKey = [[NSMutableString alloc] init];
    
    int nPrivateKeyLen = [strPrivateKey length];      //strPrivateKey为base64编码的公钥字符串
    
    int yu=nPrivateKeyLen%64;
    
    for(int i = 0; i < nPrivateKeyLen/64; i++)
    {
        
        //location（索引位置）、length（截取的長度）
        
        NSString *str3 = [strPrivateKey substringWithRange:NSMakeRange(i*64, 64)];//包含該索引的位置
        
        
        NSString *temp=[NSString  stringWithFormat:@"%@%@",str3,@"\n"];
        [newStrPrivateKey appendString:temp];
        
        
        
    }
    if(yu==0)
    {
        
        
        
    }else
    {
        NSString *str3 = [strPrivateKey substringWithRange:NSMakeRange(nPrivateKeyLen/64*64, yu)];//包含該索引的位置
        
        
        NSString *temp=[NSString  stringWithFormat:@"%@%@",str3,@""];
        [newStrPrivateKey appendString:temp];
    }
    
    
    
    
    
    [newStrPrivateKey insertString:@"-----BEGIN RSA PRIVATE KEY-----\n" atIndex:0];
    [newStrPrivateKey appendString:@"\n-----END RSA PRIVATE KEY-----\n"];
    
    BIO *bio = NULL;
    RSA *rsa = NULL;
    char *chPrivateKey = [newStrPrivateKey UTF8String];//const_cast<char *>(strPrivateKey.c_str());
    if ((bio = BIO_new_mem_buf(chPrivateKey, -1)) == NULL)       //从字符串读取RSA公钥
    {
        NSLog(@"%@",@"BIO_new_mem_buf failed!");
    }
    //PEM_read_bio_RSAPublicKey  PEM_read_bio_RSA_PUBKEY PEM_read_bio_RSAPrivateKey
    //PEM_read_RSA_PUBKEY() reads the PEM format. PEM_read_RSAPublicKey() reads the PKCS#1 format.
    
    rsa = PEM_read_bio_RSAPrivateKey(bio, NULL, NULL, NULL);   //从bio结构中得到rsa结构
    if (!rsa)
    {
      
        NSLog(@"%@",@"load private key failed[");
        BIO_free_all(bio);
        return NULL;
    }
    BIO_free_all(bio);
    return rsa;
    
    
}




- (NSData*)encryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding data:(NSData*)d{
    if (d && [d length]) {
//        int flen = (int)[d length];
//        unsigned char from[flen];
//        bzero(from, sizeof(from));
//        memcpy(from, [d bytes], [d length]);
        
        unsigned char to[128];
        bzero(to, sizeof(to));
        
       // [self encryptRSAKeyWithType:keyType rsa:rsa from:from flen:flen to:to padding:padding];
        [self encryptRSAKeyWithType:keyType rsa:rsa from:[d bytes] flen:[d length] to:to padding:padding];
        
        return [NSData dataWithBytes:to length:sizeof(to)];
    }
    return nil;
}



//分段加密
- (NSData*)encryptLongString:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding plainText:(NSString*)plainText usingEncoding:(NSStringEncoding)encode{
    
    NSData* plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    
    
    int plainTextDataLength=[plainTextData length];
    

    
    int cipherBufferSize = RSA_size(rsa);// 1024/8
   
    size_t blockSize = cipherBufferSize-11;//RSA_PADDING_TYPE_PKCS1 RSA_PADDING_TYPE_SSLV23
    size_t blockCount = (size_t)ceil(plainTextDataLength / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init] ;
    
    int totalLength=plainTextDataLength;
    int currentLength=0;
    
    while  (currentLength<totalLength) {
        
        
        int trueBlockSize =0;
        if(totalLength-currentLength<blockSize)
        {
            trueBlockSize=totalLength-currentLength;
        }else
        {
            trueBlockSize=blockSize;
        }
        
        
        
        
        NSData *from = [plainTextData subdataWithRange:NSMakeRange(currentLength, trueBlockSize)];
        
        NSString *beforencrystring=[NSString stringWithCString:[from bytes]  encoding:NSUTF8StringEncoding];
       // NSLog(@"\n加密\n%@\n",beforencrystring);
        
        
        if(beforencrystring==nil)
        {
            
            for (int i=trueBlockSize-1; i>0; i--) {
                
                
                from = [plainTextData subdataWithRange:NSMakeRange(currentLength, i)];
                
                beforencrystring=[NSString stringWithCString:[from bytes]  encoding:NSUTF8StringEncoding];
                if(beforencrystring==nil)
                {
                    continue;
                }else{
                    trueBlockSize=i;
                  //  NSLog(@"\n加密\n%@\n",beforencrystring);
                    currentLength=currentLength+i;
                    break;
                }
            }
        }else
        {
            
            currentLength=currentLength+blockSize;
        }


        
        unsigned char to[(128)*sizeof(char)];
        bzero(to, 128*sizeof(char));
    
        
        [self encryptRSAKeyWithType:keyType rsa:rsa from:[from bytes] flen:trueBlockSize to:to  padding:padding];
        
         NSData *encryDataPart=[NSData dataWithBytes:to length:sizeof(char)*128];
        
        [encryptedData appendData: encryDataPart];
      
        
    

       
        
        
    }

    
    return encryptedData;
    
    

}



//分段加密
- (NSData*)encryptLongString2:(KeyType)keyType rsa:(RSA*)rsa rsaprivate:(RSA*)rsaprivate paddingType:(RSA_PADDING_TYPE)padding plainText:(NSString*)plainText usingEncoding:(NSStringEncoding)encode{
    
    
    NSData* plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    
    
    int plainTextDataLength=[plainTextData length];
    
    
    
    int cipherBufferSize = RSA_size(rsa);// 1024/8
    
    size_t blockSize = cipherBufferSize-11;//RSA_PADDING_TYPE_PKCS1 RSA_PADDING_TYPE_SSLV23
    size_t blockCount = (size_t)ceil(plainTextDataLength / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init] ;
    NSMutableString *decryptedData = [[NSMutableString alloc] init] ;
    
    int totalLength=plainTextDataLength;
    int currentLength=0;
    
    while  (currentLength<totalLength) {
        
        
           int trueBlockSize =0;
        if(totalLength-currentLength<blockSize)
        {
            trueBlockSize=totalLength-currentLength;
        }else
        {
            trueBlockSize=blockSize;
        }
        
   
        
        
        NSData *from = [plainTextData subdataWithRange:NSMakeRange(currentLength, trueBlockSize)];
        
        NSString *beforencrystring=[NSString stringWithCString:[from bytes]  encoding:NSUTF8StringEncoding];
       // NSLog(@"\n加密\n%@\n",beforencrystring);
        
        
         if(beforencrystring==nil)
         {
         
             for (int i=trueBlockSize-1; i>0; i--) {
                
                 
                  from = [plainTextData subdataWithRange:NSMakeRange(currentLength, i)];
                 
                  beforencrystring=[NSString stringWithCString:[from bytes]  encoding:NSUTF8StringEncoding];
                 if(beforencrystring==nil)
                 {
                     continue;
                 }else{
                     trueBlockSize=i;
                    // NSLog(@"\n加密\n%@\n",beforencrystring);
                     currentLength=currentLength+i;
                     break;
                 }
             }
         }else
         {
           
             currentLength=currentLength+blockSize;
         }
        
        
        
        unsigned char to[(256)*sizeof(char)];
        bzero(to, (256)*sizeof(char));
        
        
        [self encryptRSAKeyWithType:keyType rsa:rsa from:[from bytes] flen:trueBlockSize to:to  padding:padding];
        
       // [encryptedData appendData: [NSData dataWithBytes:to length:sizeof(to)]];
        
        NSData *encryData=[NSData dataWithBytes:to length:sizeof(char)*(256)];
        
        //解密
        
     
        
        
        unsigned char privateto[(256)*sizeof(char)];
        bzero(privateto, (256)*sizeof(char));
        
        [self decryptRSAKeyWithType:KeyTypePrivate rsa:rsaprivate from:[encryData bytes] flen:128 to:privateto  padding:padding];
        
        
  
        NSString *decrystring=[[NSString alloc] initWithCString:privateto
                                encoding:NSUTF8StringEncoding];
        int count=[decrystring length];
                              // NSLog(@"\n\n解密\n%@ %d",decrystring,count);
        
        
        
        
        if([beforencrystring isEqualToString:decrystring])
                               {
                                 NSLog(@"\n 相等 \n");
                                   
                                   [decryptedData appendString:decrystring];
                               }else{
                               
                                    NSLog(@"\n 失败 \n");
                               }
    }
    
    
    return encryptedData;
    
    
    
}



//分段解密
- (NSString*)decryptLongString:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding encryptText:(NSData*)encryptText usingEncoding:(NSStringEncoding)encode{
  
    NSData* encryptTextData = encryptText;
    
    int encryptTextDataLength=[encryptTextData length] ;
    

    
    //RSA_size(rsa);//  ==1024/8
  
    size_t blockSize = 128;//RSA_PADDING_TYPE_PKCS1 RSA_PADDING_TYPE_SSLV23
    size_t blockCount = (size_t)ceil(encryptTextDataLength / (double)blockSize);
    NSMutableString *decryptedData = [[NSMutableString alloc] init] ;
    

    for (int i=0; i<blockCount; i++) {
        
        //int bufferSize =128;// MIN(blockSize,encryptTextDataLength - i * blockSize);
  
        
        NSData *from = [encryptTextData subdataWithRange:NSMakeRange( i*128, 128)];

        unsigned char privateto[(128)*sizeof(char)];
        bzero(privateto, (128)*sizeof(char));
        
        [self decryptRSAKeyWithType:keyType rsa:rsa from:[from bytes] flen:128 to:privateto  padding:padding];
        
        
        
        NSString *decrystring=[[NSString alloc] initWithCString:privateto    encoding:NSUTF8StringEncoding];
       
        
   
        if(decrystring==nil||[decrystring isEqualToString:@""])
        {
            
        }else{
            
            
     
            //NSLog(@"\n\n解密\n %d %@",i,decrystring);
            
            [decryptedData appendString: decrystring ];
            
        }
  
        
    }
    
    
    return decryptedData;
    
    
    
}



//分段解密
- (NSString*)decryptLongString2:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding encryptText:(NSData*)encryptText usingEncoding:(NSStringEncoding)encode{
    
    NSData* encryptTextData = encryptText;
    
    int encryptTextDataLength=[encryptTextData length] ;
    
    
    
    int cipherBufferSize = 128;//RSA_size(rsa);//  ==1024/8
    
    size_t blockSize = cipherBufferSize;//RSA_PADDING_TYPE_PKCS1 RSA_PADDING_TYPE_SSLV23
    size_t blockCount = (size_t)ceil(encryptTextDataLength / (double)blockSize);
    NSMutableString *decryptedData = [[NSMutableString alloc] init] ;
    
    
    int totalLength=encryptTextDataLength;
    int currentLength=0;
    
    while  (currentLength<totalLength) {
        
        
        int trueBlockSize =0;
        if(totalLength-currentLength<blockSize)
        {
            trueBlockSize=totalLength-currentLength;
        }else
        {
            trueBlockSize=blockSize;
        }
        
        
        NSData *from = [encryptTextData subdataWithRange:NSMakeRange(currentLength, trueBlockSize)];
        
        unsigned char privateto[(256)*sizeof(char)];
        bzero(privateto, (256)*sizeof(char));
        
        [self decryptRSAKeyWithType:keyType rsa:rsa from:[from bytes] flen:128 to:privateto  padding:padding];
        
       
        
        NSString *beforencrystring=[NSString stringWithCString:privateto  encoding:NSUTF8StringEncoding];
        
        //NSLog(@"\n解密\n%@\n",beforencrystring);
        
        
        if(beforencrystring==nil ||[beforencrystring isEqualToString:@""])
        {
            
            for (int i=trueBlockSize-1; i>0; i--) {
                
                
                 from = [encryptTextData subdataWithRange:NSMakeRange(currentLength, i)];
                
                unsigned char privateto[(256)*sizeof(char)];
                bzero(privateto, (256)*sizeof(char));
                
                [self decryptRSAKeyWithType:keyType rsa:rsa from:[from bytes] flen:64 to:privateto  padding:padding];
                
                
                
                beforencrystring=[NSString stringWithCString:privateto  encoding:NSUTF8StringEncoding];
                
        
                
       
                if(beforencrystring==nil ||[beforencrystring isEqualToString:@""])
                {
                    continue;
                }else{
                    trueBlockSize=i;
                    //NSLog(@"\n解密\n%@\n",beforencrystring);
                    currentLength=currentLength+i;
                    
                           [decryptedData appendString: beforencrystring];
                    break;
                }
            }
        }else
        {
               [decryptedData appendString: beforencrystring];
            currentLength=currentLength+blockSize;
        }
        
        

    
    
        
            
    
        
        
    }
    
    
    return decryptedData;
    
    
    
}









- (NSData*)encryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding plainText:(NSString*)text usingEncoding:(NSStringEncoding)encode{
    if (text && [text length]) {
        return [self encryptRSAKeyWithType:keyType rsa:rsa paddingType:padding data:[text dataUsingEncoding:encode]];
    }return nil;
}

- (NSString*)decryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding plainTextData:(NSData*)data usingEncoding:(NSStringEncoding)encode{
    if (data && [data length]) {
        NSData *decryptData = [self decryptRSAKeyWithType:keyType  rsa:rsa paddingType:padding encryptedData:data];
        return [[NSString alloc] initWithData:decryptData encoding:encode];
    }return nil;
}

- (NSData*)decryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding encryptedData:(NSData*)data{
    if (data && [data length]) {
        
        int flen = (int)[data length];
        unsigned char from[flen];
        bzero(from, sizeof(from));
        memcpy(from, [data bytes], [data length]);
        
        unsigned char to[128];
        bzero(to, sizeof(to));
        
        [self decryptRSAKeyWithType:keyType rsa:rsa from:from flen:flen to:to padding:padding];
        
        return [NSData dataWithBytes:to length:sizeof(to)];
    }
    return nil;
}

- (int)getBlockSizeWithRSA_PADDING_TYPE:(RSA_PADDING_TYPE)padding_type{
    
    int len = RSA_size(_rsa);
    
    if (padding_type == RSA_PADDING_TYPE_PKCS1 || padding_type == RSA_PADDING_TYPE_SSLV23) {
        len -= 11;
    }
    
    return len;
}

#pragma mark - Base

- (int)encryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa from:(const unsigned char *)from flen:(int)flen to:(unsigned char *)to padding:(RSA_PADDING_TYPE)padding{
    if (from != NULL && to != NULL) {
        int status = 0;//RSA_check_key(rsa);
//        if (!status) {
//            NSLog(@"status code %i",status);
//            return -1;
//        }
        
        switch (keyType) {
            case KeyTypePrivate:{
                //start encrypt
                status =  RSA_private_encrypt(flen, from,to, rsa,  padding);
            }
                break;
                
            default:{
                //start encrypt
                status =  RSA_public_encrypt(flen,from,to, rsa,  padding);
            }
                break;
        }
        
        return status;
    }return -1;
}

- (int)decryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa from:(const unsigned char *)from flen:(int)flen to:(unsigned char *)to padding:(RSA_PADDING_TYPE)padding{
    if (from != NULL && to != NULL) {
        int status = RSA_check_key(rsa);
        if (!status) {
            NSLog(@"status code %i",status);
            return -1;
        }
        
        switch (keyType) {
            case KeyTypePrivate:{
                //start encrypt
                status =  RSA_private_decrypt(flen, from,to, rsa,  padding);
            }
                break;
                
            default:{
                //start encrypt
                status =  RSA_public_decrypt(flen,from,to, rsa,  padding);
            }
                break;
        }
        
        return status;
    }return -1;
}




///**可加密无限字节*/
//- (NSString*)rsaEncryptString:(NSString*)string
//                          key:(NSString*)publickey
//                        error:(BDError *)error{
//    
//    [self setPublicKey:publickey
//                   tag:[self publicKeyIdentifier]
//                 error:error];
//    
//    SecKeyRef key = [self keyRefWithTag:[self publicKeyIdentifier]
//                                  error:error];
//    
//    if ([BDError error:error
//     containsErrorType:BDCryptoErrorRSACopyKey
//            errorClass:[BDCryptorError class]])
//    {
//        return nil;
//    }
//    
//    
//    size_t cipherBufferSize = SecKeyGetBlockSize(key);
//    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
//    NSData *stringBytes = [string dataUsingEncoding:NSUTF8StringEncoding];
//    size_t blockSize = cipherBufferSize - 11;
//    size_t blockCount = (size_t)ceil([stringBytes length] / (double)blockSize);
//    NSMutableData *encryptedData = [[NSMutableData alloc] init] ;
//    
//    for (int i=0; i<blockCount; i++) {
//        int bufferSize = MIN(blockSize,[stringBytes length] - i * blockSize);
//        NSData *buffer = [stringBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
//        OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes],
//                                        [buffer length], cipherBuffer, &cipherBufferSize);
//        if (status == noErr){
//            NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
//            [encryptedData appendData:encryptedBytes];
//            
//        }else{
//            if (cipherBuffer) free(cipherBuffer);
//            return nil;
//        }
//    }
//    if (cipherBuffer) free(cipherBuffer);
//    
//    
//    
//    NSString *encryresult  =[encryptedData base64EncodedString];
//    
//    return encryresult;
//}
//
//
///**可解密无限字节*/
//- (NSString*)rsaDecryptString:(NSString*)cipherString
//                          key:(NSString *)key
//                        error:(BDError *)error{
//    
//    NSData *cipherData=[cipherString base64DecodedData];
//    
//    [self setPrivateKey:key
//                    tag:[self privateKeyIdentifier]
//                  error:error];
//    
//    // NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:[self privateKeyIdentifier]];
//    //[keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
//    
//    SecKeyRef _privateKey = [self keyRefWithTag:[self privateKeyIdentifier]
//                                          error:error];
//    
//    
//    // 分配内存块，用于存放解密后的数据段
//    size_t plainBufferSize = SecKeyGetBlockSize(_privateKey);
//    
//    uint8_t *plainBuffer = malloc(plainBufferSize * sizeof(uint8_t));
//    // 计算数据段最大长度及数据段的个数
//    double totalLength = [cipherData length];
//    size_t blockSize = plainBufferSize;
//    size_t blockCount = (size_t)ceil(totalLength / blockSize);
//    NSMutableData *decryptedData = [NSMutableData data];
//    // 分段解密
//    for (int i = 0; i < blockCount; i++) {
//        NSUInteger loc = i * blockSize;
//        // 数据段的实际大小。最后一段可能比blockSize小。
//        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
//        // 截取需要解密的数据段
//        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
//        OSStatus status = SecKeyDecrypt(_privateKey, kSecPaddingPKCS1, (const uint8_t *)[dataSegment bytes], dataSegmentRealSize, plainBuffer, &plainBufferSize);
//        if (status == errSecSuccess) {
//            NSData *decryptedDataSegment = [[NSData alloc] initWithBytes:(const void *)plainBuffer length:plainBufferSize];
//            [decryptedData appendData:decryptedDataSegment];
//            
//        } else {
//            if (plainBuffer) {
//                free(plainBuffer);
//            }
//            return nil;
//        }
//    }
//    if (plainBuffer) {
//        free(plainBuffer);
//    }
//    
//    NSString *result  =[[ NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//    
//    return result;
//    
//}
//


@end
