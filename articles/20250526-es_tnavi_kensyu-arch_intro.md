---
title: "（仮）鉄ナビ検収のアーキテクチャを紹介します！"
emoji: "🎃"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["typescript"]
published: false
publication_name: "eversteel_tech"
---

## はじめに

こんにちは、EVERSTEEL株式会社でエンジニアをしている片桐です。

弊社では鉄スクラップの画像解析を行う「鉄ナビ検収」というプロダクトを開発しており、鉄リサイクルの効率化・品質向上を目指しています。東大発のスタートアップとして、技術的なチャレンジを重視しながらプロダクト開発を進めています。

この記事では、鉄ナビ検収のバックエンドアーキテクチャについて紹介します。特に以下の内容について詳しく解説予定です：

- TypeScript + Nest.jsを選択した理由と背景
- 関数型プログラミングのエッセンスをどう取り入れているか
- アーキテクチャの全体構成とモジュール設計
- チームが拡大する中で見えてきた課題と対応

スタートアップでのバックエンド開発や、関数型プログラミングの実践的な活用に興味のある方に、EVERSTEELでの開発現場の現状・雰囲気を感じてもらえればと思います。

## 鉄ナビ検収とは

鉄ナビ検収は、鉄スクラップの画像解析を通じて鉄リサイクル業界の効率化・品質向上を目指すプロダクトです。

### プロダクトの背景

鉄リサイクル業界では、持ち込まれた鉄スクラップの品質判定が重要な工程となっています。従来は人の目による判定が中心でしたが、判定者の経験や知識に依存する部分が多く、品質のばらつきや判定時間の課題がありました。

鉄ナビ検収では、AI技術を活用して鉄スクラップの画像から品質を自動で判定することで、これらの課題解決を図っています。

### なぜバックエンドアーキテクチャが重要なのか

鉄ナビ検収のバックエンドは、様々なシステムとの連携が求められる複雑な役割を担っています：

- **カメラシステムとの連携**: 鉄スクラップを撮影するカメラからの画像データを効率的に受信・処理
- **AI解析システムとの連携**: 画像をAIモデルに送信し、解析結果を適切に処理
- **工場基幹システムとの連携**: 各工場で異なる既存の基幹システムとのデータ連携
- **リアルタイム処理**: 判定結果を即座にフロントエンドや外部システムに提供

これらの多様な連携を安定して処理しながら、データの整合性を保ち、システム全体のスケーラビリティを確保することが、バックエンドアーキテクチャ設計の重要な課題となっています。

## 技術スタックの選択理由

鉄ナビ検収のバックエンドでは、**TypeScript** + **Nest.js** をメインの技術スタックとして採用しています。この組み合わせを選択した理由と背景について説明します。

### TypeScript採用の理由

TypeScriptを選択した主な理由は以下の通りです：

**型安全性の確保**
複数のシステム間でやり取りされるデータの型を静的に検証することで、実行時エラーを防止できます。特に画像データやAI解析結果など、複雑なデータ構造を扱う際に威力を発揮します。

**開発効率の向上**
IDEの強力な補完機能により、API仕様やデータ構造を理解しやすく、開発速度が向上します。また、リファクタリング時の安全性も高まります。

**チーム開発での安心感**
型定義が仕様書の役割を果たし、チームメンバー間での認識齟齬を減らせます。

### Nest.js選択の背景

Nest.jsを採用した理由は以下の通りです：

**エンタープライズグレードのアーキテクチャ**
依存性注入、モジュール分割、デコレータベースの設計により、大規模なアプリケーションでも保守しやすい構造を維持できます。

**豊富なエコシステム**
データベースORM、認証、バリデーション、テストなど、必要な機能が標準で提供されており、開発効率が高いです。

**Express.jsとの互換性**
既存のExpress.jsエコシステムを活用しながら、より構造化されたアプローチを取ることができます。

### 関数型プログラミングのエッセンスを取り入れた理由

オブジェクト指向のNest.jsフレームワーク上で、あえて関数型プログラミングの考え方を取り入れている理由は：

**予測可能性の向上**
副作用を最小化し、純粋関数を重視することで、コードの動作を予測しやすくなります。

**テスタビリティの向上**
関数の入力と出力が明確になることで、単体テストが書きやすくなります。

**並行処理への対応**
不変性を重視することで、並行処理時の状態管理が安全になります。

これらの技術選択により、複雑なシステム連携を伴う鉄ナビ検収のバックエンドを、安定性と保守性を両立しながら開発できています。

## 関数型プログラミングの実践

前章で述べた通り、鉄ナビ検収では関数型プログラミングのエッセンスを取り入れています。ここでは、具体的にどのような技術要素を使って実践しているかを紹介します。

### Branded-Typeによる型安全性の向上

Branded-Typeは、TypeScriptで同じプリミティブ型でも異なる意味を持つ値を区別するための手法です。

鉄ナビ検収では、IDや識別子など、文字列や数値でありながら明確に区別したい値に活用しています：

```typescript
// ユーザーIDと工場IDを明確に区別
type UserId = string & { readonly brand: unique symbol };
type FactoryId = string & { readonly brand: unique symbol };

// 実際の使用例
function getUser(userId: UserId): User {
  // userIdは必ずUserId型として渡される
}

// コンパイル時にエラーになる
const factoryId: FactoryId = "factory-123" as FactoryId;
getUser(factoryId); // ← 型エラー！
```

これにより、異なる意味を持つIDを誤って混同することを防げます。画像データのIDや解析結果のIDなど、多くの識別子を扱う鉄ナビ検収では特に効果的です。

### neverthrowによるエラーハンドリング

neverthrowライブラリの`Result`型と`ResultAsync`型を使用して、関数型的なエラーハンドリングを実現しています。

**従来のtry-catch vs Result型**

```typescript
// 従来のアプローチ
async function processImage(imageId: string): Promise<AnalysisResult> {
  try {
    const image = await fetchImage(imageId);
    const result = await analyzeImage(image);
    return result;
  } catch (error) {
    // エラーハンドリングが分散しがち
    throw error;
  }
}

// Result型を使ったアプローチ
async function processImage(imageId: ImageId): Promise<Result<AnalysisResult, ProcessingError>> {
  return fetchImage(imageId)
    .andThen(analyzeImage)
    .mapErr(error => new ProcessingError(error.message));
}
```

**メリット**
- エラーが型として表現されるため、呼び出し側でエラーハンドリングが強制される
- エラーの種類が明確になり、適切な処理を行いやすい
- 非同期処理のチェインが読みやすくなる

### 独自のWorkflow実装

neverthrowの`ResultAsync`チェインは可読性の課題があったため、これを解決する独自の「Workflow」DSLを実装しました。

**解決したい課題**
```typescript
// 深いネスト構造の問題
return parseInput(input)
  .andThen(validated => 
    fetchUser(validated)
      .andThen(user =>
        processUser(user)
          .andThen(result =>
            validateResult(result)
              .andThen(finalResult => ...)
          )
      )
  );
```

**Workflowによる改善**
```typescript
// フラットで読みやすい記述
const userProcessingWorkflow = Workflow
  .init<Input>()
  .chain(parseInput)
  .chain(fetchUser)
  .chain(processUser)
  .chain(validateResult);

const result = await userProcessingWorkflow.run(input, context);
```

**現在の活用場面**
- APIエンドポイントの処理フロー
- データ変換パイプライン
- 複数段階のバリデーション処理

ただし、この実装には現在いくつかの課題があることも分かってきており、チーム内でその解決に向けて検討を進めています。具体的な課題については後の章で詳しく触れる予定です。

### 開発体験の向上

これらの関数型的アプローチにより、以下のような開発体験の向上を実感しています：

**デバッグのしやすさ**
- 各関数の入力と出力が明確で、問題の特定が容易
- Result型により、エラーの発生箇所と原因が追跡しやすい

**テストの書きやすさ**
- 純粋関数が中心のため、単体テストが簡潔に書ける
- モックを作成する箇所が明確

**チーム開発での安心感**
- 型により契約が明確になり、インターフェースが安定
- エラーハンドリングの漏れが型レベルで検出される

関数型プログラミングは学習コストがありますが、複雑なドメインロジックを扱う鉄ナビ検収において、コードの品質と開発効率の向上に大きく貢献しています。

## アーキテクチャの詳細

前章で紹介した技術要素を、実際のシステムアーキテクチャの中でどのように活用しているかを説明します。

### システム構成の概要

鉄ナビ検収のバックエンドは、以下の4つの主要コンポーネントで構成されています：

![アーキテクチャ概要図](../images/es-sw-arch.png)

**cloud_sms**
工場ごとに異なる基幹システムとの連携をサポートします。異なるJSON Schemaを用いた変換ロジックを担い、様々な基幹システムの実装に対応できる柔軟性を提供しています。

**assessment_manager**
基幹システムからの検収情報を処理します。検収データの受信、バリデーション、正規化を行い、後続の処理に必要な形式に整えます。

**capture_session**
検収情報とユーザからの操作を元に、撮影ループを処理します。カメラとの連携やフレームの管理、撮影タイミングの制御を担当します。

**ai_assessment**
撮影ループで解析対象と判定されたフレームのAI解析を実施します。AI解析システムとの連携から結果の処理まで、一連のAI処理フローを管理します。

なお、以前はCloud側に存在していたNCSやFrameClassificationといった機能は、現在工場ローカルでの処理に移行しており、レスポンス性能の向上を図っています。

### クリーンアーキテクチャの採用

鉄ナビ検収では、伝統的なクリーンアーキテクチャを参考にした4層構造を採用しています。

**現在のディレクトリ構造**
```
src/
  ai_assessment/
    application/      # UseCase層
    domain/          # Entity・ビジネスルール層
    infrastructure/  # 外部システム連携層
    presentation/    # API・Controller層
  assessment_manager/
    application/
    domain/
    infrastructure/
    presentation/
  ...
```

各層の責任は以下のように分離されています：

- **Domain層**: ビジネスルールとドメインエンティティ
- **Application層**: ユースケースの実行とドメインサービスの協調
- **Infrastructure層**: データベースや外部APIとの連携
- **Presentation層**: HTTPリクエスト/レスポンスの処理

この構造により、ビジネスロジックを外部の技術的関心事から分離し、テストしやすく保守性の高い設計を実現しています。

### ドメインモデルの型安全性

**Branded-Typeによる意味のある型定義**

ドメイン層では、Branded-Typeを活用して意味を持った型を定義しています：

```typescript
export type AssessmentId = Branded<string, 'AssessmentId'>;

export const parseAssessmentId = (
    value: string,
): Result<AssessmentId, DomainError> =>
    typeof value === 'string' && value.length > 0
        ? ok(AssessmentId(value))
        : err(genUnknownError('AssessmentId is string and not empty'));
```

**安全なエンティティ作成**

エンティティの作成時には、複数のバリデーションを組み合わせて安全にオブジェクトを構築しています：

```typescript
export const parseAssessmentEntity = (
    props: AssessmentEntityParserProps,
): Result<AssessmentEntity, DomainError> =>
    Result.combine([
        parseAssessmentId(props.id),
        // 他のプロパティのパーサー
    ]).map(([id, ...]) => ({ id, ... }));
```

このアプローチにより、ドメインオブジェクトの整合性を型レベルで保証し、実行時エラーを大幅に削減できています。

### フレームワークとビジネスロジックの分離

Nest.jsのフレームワーク機能（依存性注入、デコレータなど）を活用しながらも、コアなビジネスロジックはフレームワークに依存しない形で実装しています。

```typescript
@Injectable()
export class StartAiAssessmentUsecase {
    constructor(
        @Inject(AI_ASSESSMENT_REPOSITORY)
        private readonly repository: AiAssessmentRepository,
        // 他の依存関係
    ) {}

    exec(args: Args) {
        // フレームワークから独立したビジネスロジックを呼び出し
        return businessLogic(this.repository)(args);
    }
}
```

この設計により、フレームワークの恩恵を受けながらも、ビジネスロジックのテスタビリティと再利用性を確保しています。

### 将来への展望

現在、チーム内でディレクトリ構造の改善について議論を重ねています：

```
src/
  presentation/     # 統合されたAPI層
    auth
    control
    admin
    cloud_sms
  domain/          # ドメイン別の分離
    ai_assessment/
      application/
      domain/
      infrastructure/
    assessment_manager/
```

この構造により、プレゼンテーション層を統合し、各ドメインのビジネスロジックをより明確に分離することを目指しています。

複雑なドメインを扱う鉄ナビ検収において、クリーンアーキテクチャの原則と関数型プログラミングの要素を組み合わせることで、保守性と拡張性を両立したシステムを構築できています。特に、型安全性を重視したアプローチにより、チーム開発での品質向上に大きく貢献しています。
