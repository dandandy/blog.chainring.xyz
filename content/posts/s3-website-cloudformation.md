---
title: "S3 Website Cloudformation"
date: 2021-05-10T13:18:23+10:00
draft: true
---

This article will explain via code snippets how to deploy a static website via a cloudfront distribution using cloudfromation infrastructure as code. 

This article will not explain how to configure the cloudfront distribution to use a custom domain.

# Why use cloudfromation?

Cloudformation is as infrastructure as code language which allows you to defined your AWS Resources using yaml files. This gives the following advantages over using the AWS Console:

- Logically groups resources into stacks
- Track changes to resources
- Tear down all resources at a click of a button
- Create all resources at a click of a button 

# Cloudformation structure

All Cloudformation templates are have the same mandator section: Resources. And they also have the same optional sections: Parameters, Conditions, Mappings, Transformations and Outputs.

For the purpose of this example we are going to use Parameters so we can configure how our parameter behaves.

# Parameters

BucketName



# Resources

For this demonstration we will need only need to define two rescources: S3 Bucket and our Cloudfront Distribution.

```yaml
Resources:
  Bucket:
    Type : AWS::S3::Bucket
  Policy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref BucketName
      PolicyDocument:
        Version: 2012-10-17
        Id: PolicyForPublicBucket
        Statement:
          - Effect: Allow
            Principal:  "*"
            Action: s3:GetObject
            Resource: !Sub "${Bucket.Arn}/*"

  Distribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        CustomErrorResponses:
          - ErrorCode: 403
            ResponseCode: 200
            ResponsePagePath: /index.html
        PriceClass: PriceClass_100 
        Enabled: true
        DefaultRootObject: /index.html
        Origins:
        - DomainName: !GetAtt Bucket.RegionalDomainName
          S3OriginConfig: 
            OriginAccessIdentity: ""
          Id: "myS3Origin"
          
        DefaultCacheBehavior:
          CachePolicyId: 658327ea-f89d-4fab-a63d-7e88639e58f6 # Managed-CachingOptimized
          AllowedMethods: [HEAD, GET, OPTIONS]
          TargetOriginId: myS3Origin
          ViewerProtocolPolicy: "redirect-to-https"
```

