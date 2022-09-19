---
title: '[入門] AppSyncとVTL開発'
emoji: '📗'
type: 'tech' # tech: 技術記事 / idea: アイデア
topics: [graphql, test, aws]
published: true
---

こんにちは！エンジニアの giri です．
こちらはAppSync・VTL周りについて，私なりの理解や開発方針をまとめた記事となっております〜．

元々は「Evaluation Mapping Template を使ってみた」というテンションの記事を書く予定でしたが，まとめるのが下手すぎて少し長めの記事となってしまいました．笑

特に最初から読む必要はないと思いますので，Evaluation Mapping Template を見にきてくれた方は右の目次から「EvaluationMappingTemplate が使えるようになってました」に飛んじゃってください．

そんなこんなでAppSync と VTLについて，入門してみましょー．

# AppSync と VTL

AppSyncを使ってたことがある・現在興味を持っているという方も多いのではないでしょうか．

https://aws.amazon.com/jp/appsync/#:~:text=AWS%20AppSync%20%E3%81%AF%E3%80%81%E6%9C%80%E6%96%B0%E3%81%AE,Sub%20API%20%E3%81%AE%E3%82%B5%E3%83%BC%E3%83%93%E3%82%B9%E3%81%A7%E3%81%99%E3%80%82

> AWS AppSync は、最新のウェブおよびモバイルアプリケーションの構築を簡素化するサーバーレス GraphQL および Pub/Sub API のサービスです。

AppSync は一般的な GraphQL としての機能の他に，「Cognito を利用した認可」や，「Subscription クエリによるリアルタイム通信」などを容易に実現することができ，複雑な要件に対応することができる非常に便利な AWS サービスとして知られています．

ただ，個人的にはいまいち使いこなせてない感が拭えませんでした．なぜでしょうか．

その理由の一つが VTL の存在です．


## VTL とは？

ここで VTL とはなんなのか，めちゃくちゃざっくり説明しておきますね．

そもそもAppSyncとは「クライアント」と「データソース」を中継するサービスです．この中継地点で認証やPub/Sub，データの集約などを行うサービスなのでした．
(データソースはAppSyncを利用してアクセスしたいサービスのことです．代表的なデータソースにはDynamoDBやLambdaなどが挙げられます．)

そのため，AppSync は「クライアントからのクエリ = 要求」を「データソースへのリクエスト」に変換する機能が実装されています．

ちょっと例をみてみましょう．
（以下，クエリ例などは[AppSync チュートリアル](https://docs.aws.amazon.com/ja_jp/appsync/latest/devguide/tutorial-dynamodb-resolvers.html#setting-up-the-getpost-resolver-ddb-getitem)からの引用です）

```graphql:クライアントからのクエリ例
query getPost {
  getPost(id:123) {
    id
    author
    title
    content
    url
    ups
    downs
    version
  }
}
```

AppSync はこれからデータソースへのリクエストに関わる部分（この例では`id:123`）を抽出し...

```json:データソースへのリクエスト例
{
    "version" : "2017-02-28",
    "operation" : "GetItem",
    "key" : {
        "id" : "123"
    }
}
```

といった形に変換しているわけです．
このようにして，「クライアントからのクエリ = クライアントからの要求」を「データソースへのリクエスト」に変換し，その結果をコネコネしてクライアントに返答します．

この変換の過程で登場するのが **Mapping Template** です．

**Mapping Template を利用して「どのように AppSync へのクエリをデータソースへのリクエストに変換するか」を定義する**ことができます．
そして Mapping Template を記述するための言語が **VTL** (Apache **V**elocity **T**emplate **L**anguage)です．

中身はこんな感じ．

```json:Mapping Templateの例
{
    "version" : "2017-02-28",
    "operation" : "GetItem",
    "key" : {
        "id" : $util.dynamodb.toDynamoDBJson($ctx.args.id)
    }
}
```

これが VTL です．

「データソースへのリクエスト例」と見比べてみても，思っているほど難しくなさそうな印象ですね．

しかし実際はちょいちょい複雑なやつらが出てくることもあるようです．少しだけ複雑な例をもってくるとこんな感じ．

```json:少しだけ複雑なMapping Templateの例
{
    "version" : "2017-02-28",
    "operation" : "Scan"
    #if( ${context.arguments.count} )
        ,"limit": $util.toJson($context.arguments.count)
    #end
    #if( ${context.arguments.nextToken} )
        ,"nextToken": $util.toJson($context.arguments.nextToken)
    #end
}
```

if 文が確認できますね．コメントみたいに見えますが，ちゃんと if 文として機能します．

...ちょっと難しそうなイメージも湧いてきましたね．

その一方で，やろうと思えばそれなりに複雑なことができそうな雰囲気は感じていただけたのではないでしょうか．
(もっと複雑な例も[AppSync のチュートリアル](https://docs.aws.amazon.com/ja_jp/appsync/latest/devguide/tutorial-dynamodb-resolvers.html#modifying-the-updatepost-resolver-dynamodb-updateitem)を探せばあります．)

### VTL は書かなくていい

ここまで VTL をざっと紹介してきましたが，実は VTL ってほとんど書かなくてもいいんですよね．

**データソースに Lambda 関数を指定することで，VTL の記述は最小限に抑えることが可能**です．
詳細は[この辺](https://docs.aws.amazon.com/ja_jp/appsync/latest/devguide/direct-lambda-reference.html)を読んでいただければと思います．

「VTL で細かい変換の方法を書く」より「VTL を最小限に留めて Lambda 関数を書く」という方針をとることで，VTL をゴリゴリ書く必要がなくなります．

そして私は VTL をほとんど記述せずにここまできてしまいました．

...でも書いてみたいですよね？

# VTL で書く？Lambda 関数にする？

よーしじゃあ VTL 書いてみよー，と思ったのですが一旦冷静に．

Lambda 関数で VTL を代替することには「VTL を書かなくて済む」以外にも多くのメリットがあります．
同時に VTL で書くことにメリットもあるはずです．

まずはこれらのメリットとデメリットを簡単に整理して，「この処理は VTL で書くべきか Lambda 関数で書くべきか」を考える土台にしておきましょう．

まずは VTL の代わりに Lambda 関数を書くメリットから．

#### Lambda 関数を書くメリット

- 各種ツール・Linter などのサポート
- デバッグ・ロギングが容易
- 保守性・可読性が高い
- 再利用性が高い（より DRY に書ける）

どれもこれも重要ですねー．ここに言語特有のメリットなんかも乗ってくるわけです．
正直これらのメリットがあれば，多少のデメリットは目を瞑れてしまいそうですね．

また，少し違う観点からは「技術スタックとして VTL をカウントしなくてもいい」というメリットもあるかもしれません．

次に VTL の代わりに Lambda 関数を書くことによるデメリットの方もみておきましょう．

#### Lambda 関数を書くデメリット

- Lambda 関数実行によるレイテンシの増大
- Lambda 関数実行によるコスト増大

レイテンシの増加と Lambda 関数を利用することによるコストが主なデメリットとなりそうです．
コールドスタートによりレイテンシはさらに増大する可能性があり，これに対策を講じると今度はそちらにコストがかかったりします．

こうして並べてみると，開発者としては Lambda 関数を利用することで得られるメリットがかなり大きいですね．

## 複雑な処理には Lambda 関数を

Lambda 関数を書くメリットとデメリットについて，「処理の複雑さ」という観点からもう少し突っ込んで考えてみましょう．
**記述したい処理が複雑であれば複雑であるほど，Lambda 関数で代替するメリットはそのデメリットに比べて大きくなります**．

これは「処理の複雑さの増大」が保守性・可読性に与える影響と，「処理の複雑さの増大」がコストやパフォーマンスへ与える影響が，同じように増加しないことに起因します．
前者は「処理の複雑さ」がダイレクトに影響しますが，後者にとってはそうでもないです．

「Lambda関数で代替するデメリット」は，「処理の複雑さ」より「リクエスト数」などが影響を与えそうですね．

**処理が複雑であればあるほど，Lambda 関数を採用するべきだと言えそうです**．

## 簡単な処理には VTL を

では簡単な処理についてはどうでしょうか．

こちらは Lambda 関数を採用するメリットが小さく，相対的に VTL を採用するメリットが大きいと予想できます．

先ほど載せた Mapping Template の例を再掲します．

```json:Mapping Templateの例
{
    "version" : "2017-02-28",
    "operation" : "GetItem",
    "key" : {
        "id" : $util.dynamodb.toDynamoDBJson($ctx.args.id)
    }
}
```

...VTL でもやっていけそうな気がしてきますよね．
むしろこれだけを書くのに Lambda 関数を使うほうが面倒まであるかもしれません．

**これくらいシンプルな処理であれば，VTL で書いた方が総合的にはメリットが大きそうな気がしてきませんか**．

そして私は無理なく書ける範囲では VTL を，複雑そうな場合は Lambda 関数を採用していくことに決めたのです．

# VTL のユニットテスト

いくら簡単な処理に限ると言っても，慣れていない VTL 開発はつらいものがあります．せめてユニットテストくらいはどうにかしたいものです．

少し前に AppSync のテスト環境について調べたときは，次のようなテスト方法がありそうでした．

- Amplify CLI を利用する

https://docs.amplify.aws/cli/usage/mock/

「これ便利そうじゃん」って感じですが Amplify CLI で構築されてないとダメみたいです． [こちら](https://aws.amazon.com/jp/builders-flash/202105/amplify-library-existing-appsync/?awsf.filter-name=*all) の「おわりに」には以下の記述があります．

> ### おわりに
>
> ...
> 一方で、**Amplify CLI を使ってバックエンドの構築をしないことで、いくつか Amplify から享受できるメリットが減ってしまうという側面があります。例えば、1) amplify mock コマンドを使ったローカルモックテスト。** 2) amplify env 機能を使ったバックエンド環境の分離。　といった機能は Amplify CLI でのバックエンド構築が前提となります。

AppSync の構築って Amplify CLI 使うのが普通なんでしょうか..？
いずれにしても CDK などでリソースを構築することが多い私にはまだ利用できない機能と考えてよさそうです．

- デプロイして更新のクエリを投げる

テストとしては一番確実な気がしますが，ピンポイントで VTL の変更を確認するには大掛かりすぎる気もしますね．

慣れてないうちは「構文エラーで再デプロイ」なんてことも頻発するでしょう．確実ですがちょっとつらそうです．

もう少し手軽なものはないんでしょうか．

## EvaluationMappingTemplate が使えるようになってました

どうやらつい最近になって VTL のユニットテストが可能になったいたようです．

https://aws.amazon.com/jp/blogs/mobile/introducing-template-evaluation-and-unit-testing-for-aws-appsync-resolvers/

AWS CLI でもできる．AWS SDK でもできる．
Jest との連携まで紹介されていました．

ということでちょっとやってみましょうか．ここからようやく本題です．

# EvaluationMappingTemplate を使ってみる

なにはともあれ Evaluation Mapping Template を使ってみましょう．

ここでは AWS SDK for JavaScript v3 で試してみます．上記のブログでは v2 を利用していますが，v3 でも問題なさそうです．

https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-appsync/classes/evaluatemappingtemplatecommand.html

最新バージョンをの SDK をご用意くださいね．
それと SDK v3 を利用する以外は完全に二番煎じです．結構雑にやらさせてもらいますが悪しからず．

(一応[こちら](https://github.com/gili-Katagiri/appsync-vtl-unit-testing)に repo もありますのでどうぞ）

## Context を定義する

まずは`context.json`ファイルを用意しましょう．これは，「クライアントからのクエリ」を JSON 形式で再現したものって感じでしょうか．

```json:context.json
{
    "arguments": {
        "owner": "janed",
        "title": "Important Task",
        "taskStatus": "in Progress",
        "priority": "high",
        "department": "Engineering",
        "classification": 2
    }
}
```

一応クエリだとこんな感じになっているはずだ，という例を置いておきますので対応を確認してみてください．

```graphql:クエリ例
query getPost {
  getPost(owner:"janed", title:"Important Task", taskStatus:"in Progress", priority:"high", department:"Engineering",classification: 2) {
    ...
  }
}
```

AppSync はこんな感じのクエリを受け取ると，これを `context.json` のような形にしてくれます．

そして `context.json` を基に Mapping Template を評価しているわけですね．

「クエリ-> `context.json`」 の部分はまだユニットテストができないようで，開発者は `context.json` を用意する必要があるようです．

## Mapping Template を定義する

いよいよ Mapping Template を書いていくわけです．こんな感じで `template.vtl` ファイルを作成してみましょう．

```json:template.vtl
{
    "version": "2017-02-28",
    "operation": "PutItem",
    "key": {
        "id": { "S": "$util.autoId()"}
    },
    "attributeValues": {
        "title": { "S": "$context.arguments.title" },
        "classification": { "I": "$context.arguments.classification" },
        "department": { "S": "$context.arguments.department" },
        "priority": { "S": "$context.arguments.priority" },
        "taskStatus": { "S": "$context.arguments.taskStatus" },
        #if($util.isNullOrEmpty($context.arguments.description))
            "description": { "S": "$context.arguments.title for $context.arguments.department department with status $context.arguments.taskStatus" }
        #else
            "description": { "S": "$context.arguments.description" }
        #end
    }
}
```

今回特に興味があるのはここですね．

```json
        #if($util.isNullOrEmpty($context.arguments.description))
            "description": { "S": "$context.arguments.title for $context.arguments.department department with status $context.arguments.taskStatus" }
        #else
            "description": { "S": "$context.arguments.description" }
        #end
```

「`"description"` の項目が存在しない，または `"description"` が空文字列の場合には，他の `arguments` から `"description"` を生成する」というロジックが記載されています．

これがちゃんと機能しているかを確認する際に Evaluation Mapping Template が役に立つはずです．

## AWS CLI でテストする

この段階でひとまずテストの素材は用意できてます．CLI で動かしてみましょうか．

```bash
$ aws appsync evaluate-mapping-template \
    --template file://template.vtl \
    --context file://context.json | \
  jq ".evaluationResult" -r | jq
```

`"description"`の項目が仕様を満たしているか確認してみましょう．とりあえず目視です．

```json:result
{
  "version": "2017-02-28",
  "operation": "PutItem",
  "key": {
    "id": {
      "S": "082a1e93-318c-41ff-937c-1554346793fe"
    }
  },
  "attributeValues": {
    "title": {
      "S": "Important Task"
    },
    "classification": {
      "I": "2"
    },
    "department": {
      "S": "Engineering"
    },
    "priority": {
      "S": "high"
    },
    "taskStatus": {
      "S": "in Progress"
    },
    "description": {
      "S": "Important Task for Engineering department with status in Progress"
    }
  }
}
```

...いい感じっぽいですね．
さりげなく `autoId` も機能していていることも確認できました．


## Jest でテストする

今度は Jest を利用して，このロジックが意図したとおりに機能するかを確認してみましょう．

環境のセットアップです．

```bash
$ mkdir appsync-vtl-unit-testing && cd $_
$ yarn init

# TS, Jest
$  yarn add -D typescript jest ts-jest @types/jest

# AWS SDK JavaScript v3
$ yarn add @aws-sdk/client-appsync

# `package.json` に `scripts: {"test": "jest"}` を追加
$ vim package.json
  ...
  "scripts": {
    "test": "jest"
  },
  ...

# ts-jestの設定
$ vim jest.config.js
module.exports = {
  preset: 'ts-jest',
};
```

そうしたらテストファイルを用意しましょう．

```ts:evaluate.test.ts
import {
  AppSyncClient,
  EvaluateMappingTemplateCommand,
} from '@aws-sdk/client-appsync';

import { readFileSync } from 'fs';

// `template.vtl` と `context.json` を読み込む
const template = readFileSync('./template.vtl', 'utf8');
const context = readFileSync('./context.json', 'utf8');

// `context.json` を object にparse
const contextJson = JSON.parse(context);

const client = new AppSyncClient({});

test('Evaluate the Resolvers', async () => {
  // 実行コマンドを生成
  const command = new EvaluateMappingTemplateCommand({ template, context });

  // コマンドを実行
  const response = await client.send(command);

  // 結果を object にparse
  const result = JSON.parse(response.evaluationResult);

  // `description` が意図されたとおりに設定されているかを確かめる
  expect(result.attributeValues.description.S).toEqual(
    `${contextJson.arguments.title} for ${contextJson.arguments.department} department with status ${contextJson.arguments.taskStatus}`,
  );
});
```

さて，準備完了です．

```bash
$ yarn test
 PASS  ./evaluate.test.ts
  ✓ Evaluate the Resolvers (635 ms)

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Snapshots:   0 total
Time:        1.356 s, estimated 2 s
```

...いいっすね．

Jestを利用したユニットテストがうまくいきました．VTLの開発にも心強い仲間ができましたね．

## ちょっとだけ改善

このままで終わっても寂しいので少しエラーを注入してその時の挙動を確認してみましょう．

`template.vtl` を次のように書き換えてみました．

```json:template.vtl
{
    "version": "2017-02-28",
    "operation": "PutItem",
    "key": {
        "id": { "S": "$util.autoid()"}
    },
    "attributeValues": {
        "title": { "S": "$context.arguments.title" },
        "classification": { "I": "$context.arguments.classification" },
        "department": { "S": "$context.arguments.department" },
        "priority": { "S": "$context.arguments.priority" },
        "taskStatus": { "S": "$context.arguments.taskStatus" },
        #if($util.isNullOrEmpty($context.arguments.description))
            "description": { "S": "$context.arguments.title for $context.arguments.department department with status $context.arguments.taskStatus" }
        #else
            "description": { "S": "$context.arguments.description" }
    }
}
```

どこにミスがあるかわかりますか？ `jest` を実行してみましょう．

```shell
$ yarn test

FAIL  ./evaluate.test.ts
  ✕ Evaluate the Resolvers (820 ms)

  ● Evaluate the Resolvers

    SyntaxError: Unexpected token u in JSON at position 0
        at JSON.parse (<anonymous>)

      23 |
      24 |   // 結果を object にparse
    > 25 |   const result = JSON.parse(response.evaluationResult);
         |                       ^
      26 |
      27 |   // `description` が意図されたとおりに設定されているかを確かめる
      28 |   expect(result.attributeValues.description.S).toEqual(

      at evaluate.test.ts:25:23
      at fulfilled (evaluate.test.ts:5:58)
```

エラーを注入したのでエラーがでます．
しかしちょっとわかりづらい．どんなエラーが出たのかわかりません．

テストコードを変更して，エラーメッセージを表示できるようにしてあげましょうか．

```typescript
  // エラーがあったらメッセージを出力
  response.error != null && console.error(response.error);
  // エラーがないかどうかを確認する
  expect(response.error == null).toBe(true);
```

これでエラーメッセージが表示されるはずです．

```shell
$ yarn test
  console.error
    Encountered "<EOF>" at velocity[line 19, column 2]
    Was expecting one of:
        "(" ...
        <RPAREN> ...
        <ESCAPE_DIRECTIVE> ...
        <SET_DIRECTIVE> ...
        "##" ...
        "\\\\" ...
        "\\" ...
        <TEXT> ...
        "*#" ...
        "*#" ...
        "]]#" ...
        <STRING_LITERAL> ...
        <END> ...
        <IF_DIRECTIVE> ...
        <INTEGER_LITERAL> ...
        <FLOATING_POINT_LITERAL> ...
        <WORD> ...
        <BRACKETED_WORD> ...
        <IDENTIFIER> ...
        <DOT> ...
        "{" ...
        "}" ...
        <EMPTY_INDEX> ...
    ...
```

めちゃくちゃわかりづらいですね．笑
ひとまず `Encountered "<EOF>" at velocity[line 19, column 2]` とのことです．理由がわかるだけマシということにしておきましょう．

一応注入したエラーは `#end` が足りないというものでした．修正しておきます．


## 気付きにくいミスがある

先ほど変更した `template.vtl` には，実はもうひとつの誤りがあります．気がつきましたか？

ここです．

```json
        "id": { "S": "$util.autoid()"}
```

`$util.autoid()` です． `$util.autoId()` が正解です．これ，エラーにならないんですよね．

AWS CLIなどから出力してみた人は気づいたかもしれませんね．

```shell
$ aws appsync evaluate-mapping-template \
    --template file://template.vtl \
    --context file://context.json | \
  jq ".evaluationResult" -r | jq
```
```json
{
  "version": "2017-02-28",
  "operation": "PutItem",
  "key": {
    "id": {
      "S": "$util.autoid()"
    }
  },
  "attributeValues": {
    "title": {
      "S": "Important Task"
    },
    "classification": {
      "I": "2"
    },
    "department": {
      "S": "Engineering"
    },
    "priority": {
      "S": "high"
    },
    "taskStatus": {
      "S": "in Progress"
    },
    "description": {
      "S": "Important Task for Engineering department with status in Progress"
    }
  }
}
```

`autoId` はその名のとおり，自動ID生成を行います．ここにミスが入り込むと検出が若干面倒そうですよね．

正直いい手かどうか微妙ですが，`$util` や `$context` などをブラックリストとして扱ってみることにします．

これらは基本的に，他の文字列で置換されているはずです．
「残っているものはなんであれ異常だ」ということにしてみましょう．

```typescript
// `$util` ，`$context` が含まれるのは異常と判定する
expect(response.evaluationResult).not.toMatch(/\$util|\$ctx|\$context/);
```

...なんというか，これでいいの？って感じがしますね．
それでもテスト結果は多少わかりやすい気がしてます．

```shell
 FAIL  ./evaluate.test.ts
  ✕ Evaluate the Resolvers (864 ms)

  ● Evaluate the Resolvers

    expect(received).not.toMatch(expected)

    Expected pattern: not /\$util|\$ctx|\$context/
    Received string:      "{
        \"version\": \"2017-02-28\",
        \"operation\": \"PutItem\",
        \"key\": {
            \"id\": { \"S\": \"$util.autoid()\"}
        },
        \"attributeValues\": {
            \"title\": { \"S\": \"Important Task\" },
            \"classification\": { \"I\": \"2\" },
            \"department\": { \"S\": \"Engineering\" },
            \"priority\": { \"S\": \"high\" },
            \"taskStatus\": { \"S\": \"in Progress\" },
                        \"description\": { \"S\": \"Important Task for Engineering department with status in Progress\" }
                }
    }
    "

      36 |
      37 |   // `$util` ，`$context` が含まれるのは異常と判定する
    > 38 |   expect(response.evaluationResult).not.toMatch(/\$util|\$ctx|\$context/);
         |                                         ^
      39 | });
      40 |

      at evaluate.test.ts:38:41
      at fulfilled (evaluate.test.ts:5:58)
```

ちゃんとハイライトされて出てきてくれるんですね．ぜひ確認してみてください．

これくらいまでやっておけば，VTLユニットテストの下地としては十分でしょうか．

最後に全文載せておきますね．

```typescript 
import {
  AppSyncClient,
  EvaluateMappingTemplateCommand,
} from '@aws-sdk/client-appsync';

import { readFileSync } from 'fs';

// `template.vtl` と `context.json` を読み込む
const template = readFileSync('./template.vtl', 'utf8');
const context = readFileSync('./context.json', 'utf8');

// `context.json` を object にparse
const contextJson = JSON.parse(context);

const client = new AppSyncClient({});

test('Evaluate the Resolvers', async () => {
  // 実行コマンドを生成
  const command = new EvaluateMappingTemplateCommand({ template, context });

  // コマンドを実行
  const response = await client.send(command);

  // エラーがあったらメッセージを出力
  response.error != null && console.error(response.error.message);
  // エラーがないかどうかを確認する
  expect(response.error == null).toBe(true);

  // 結果を object にparse
  const result = JSON.parse(response.evaluationResult);

  // `description` が意図されたとおりに設定されているかを確かめる
  expect(result.attributeValues.description.S).toEqual(
    `${contextJson.arguments.title} for ${contextJson.arguments.department} department with status ${contextJson.arguments.taskStatus}`,
  );

  // `$util` ，`$context` が含まれるのは異常と判定する
  expect(response.evaluationResult).not.toMatch(/\$util|\$ctx|\$context/);
});
```

# おわりに

「Evaluate Mapping Template を使ってみた」で書いてみようと思ったらまとめるのが下手すぎて長くなってしまいましたね．笑

この記事では，AppSyncにおけるVTLの利用について，自分なりの理解と開発/ユニットテストの方針をまとめてみました．

みなさんの意見もコメントでお聞かせください〜〜
