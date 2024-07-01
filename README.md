# AWS_Practice

## やりたいこと

AWS 内のサービスを使った API 実装の練習

## 使用するサービス

- JWT Authorizer
- API Gateway
- Lambda
- Firebase Authentication

## 使う技術

- Nodejs
- TypeScript

## 作りたい API

GET メソッドリクエストを送り、レスポンスとして `Hello, World!` を返す API
レスポンスを返すかどうかを Firebase Authentication で制御する

## 参考にするサイト

- [Terraform で API Gateway + Lambda の構成テンプレート](https://qiita.com/suzuki-navi/items/6a896a6577deaa858210)

## lambda 関数の実装方法

github のコードから lambda 関数にデプロイするための手順について書く

## デプロイ手順

- S3 バケットへのアップロード
- CodeBuild でのビルド
- Lambda 関数の作成
