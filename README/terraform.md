# Terraform

## 概要

Terraform における AWS のリソース管理をする

## ファイル構成

```bash
.
├── README.md
├── main.tf
├── variables.tf
├── apigateway.tf
├── terraform.tfvars
├── index.mjs
|
├── test
│  ├── apigateway.tf
│  ├── codebuild.tf
│  ├── lambda.tf
│  └── variables.tf
|
├── path0
│  ├── apigateway.tf
│  ├── codebuild.tf
│  ├── lambda.tf
│  └── variables.tf
|
├── api_gateway
|  ├── test
│  │  ├── main.tf
│  │  ├── data.tf
│  │  ├── variables.tf
│  │  ├── policies.tf
|  |  └── outputs.tf
│  ├── main.tf
│  ├── data.tf
│  ├── variables.tf
│  ├── policies.tf
|  └── outputs.tf
└── lambda
   ├── index.js
   ├── main.tf
   └── outputs.tf
```

### モジュールの分割方法

- API のリクエストのパスの階層ごとにモジュールを分割する
- リソースはなるべくモジュール内で完結させる

### API Gateway

### S3

lambda 関数をデプロイする際の zip ファイルは、モジュールの階層構造に合わせる
zip ファイルの名前は、`source.zip` とする

### Lambda

リクエストごとにどうやって Lmabda 関数を分割するかは未定
少なくとも firebase のトークン認証の Lambda 関数は独立させる

## ネーミングルール

リソースが増えてきても管理しやすいようにモジュールやファイルで分割して管理するようにしている
その際にどのような名前で管理していくのかについても考えていきたい

### ファイル名

1 つのアカウントで共通のリソースを定義する際はリソース名をファイル名にする

### 識別子

動的に作成できないが、モジュール間では共通の識別子を持つことができる
モジュール内で共通のリソースについては基本的に`default`という名前をつける

### リソース名

リソース名は元々のプレフィックスにモジュール名も繋げて表記する
