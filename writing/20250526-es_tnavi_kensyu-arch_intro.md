# 記事作成記録：鉄ナビ検収のアーキテクチャ紹介

## 記事概要
- ファイル名: 20250526-es_tnavi_kensyu-arch_intro.md
- 仮タイトル: 鉄ナビ検収のアーキテクチャを紹介します！
- 想定記事種別: tech
- トピック: typescript

## 作成進捗

### 手順1: どのような記事を書くのか決定する
- **状況**: 記事ファイルは既に作成済み
- **現在のタイトル**: （仮）鉄ナビ検収のアーキテクチャを紹介します！

**記事詳細（authorからの回答）**:
- **鉄ナビ検収**: 鉄スクラップ画像の解析を行う、鉄リサイクルの効率化・品質向上を目的としたプロダクト
- **会社**: EVERSTEEL（https://eversteel.co.jp）- 東大発のスタートアップ
- **紹介対象**: バックエンドアーキテクチャ（TypeScript、Nest.js採用）
- **技術的特徴**: 関数型プログラミングのエッセンスを取り入れている
- **現在の課題**: メンバーが増えてきたことで見えてきた課題がある
- **想定読者**: エンジニア全般
- **記事の目的**: EVERSTEELという会社での開発がどのようなものかを知ってもらう

**決定事項**: 記事内容は確定

### 手順2: 章・節の主題を列挙し全体の構成を決定

**構成案（初回提案）**:
1. はじめに
2. 鉄ナビ検収とは
3. 技術スタックの選択理由
4. アーキテクチャの詳細
5. チーム拡大で見えてきた課題
6. まとめ

**authorからのフィードバック**:
- 関数型プログラミングのエッセンスについて紹介する章を追加
- 具体的には以下の技術要素を体験として記載:
  - Branded-Type
  - neverthrow の Result/ResultAsync
  - Workflow という独自の実装

**修正後の構成案**:

1. **はじめに**
   - EVERSTEELと鉄ナビ検収の簡単な紹介
   - この記事で紹介する内容の概要

2. **鉄ナビ検収とは**
   - プロダクトの概要と技術的な背景
   - なぜバックエンドアーキテクチャが重要なのか

3. **技術スタックの選択理由**
   - TypeScript採用の理由
   - Nest.js選択の背景
   - 関数型プログラミングのエッセンスを取り入れた理由

4. **関数型プログラミングの実践**（新規追加）
   - Branded-Typeによる型安全性の向上
   - neverthrowのResult/ResultAsyncを使ったエラーハンドリング
   - 独自のWorkflow実装とその効果
   - 実際のコード例と開発体験

5. **アーキテクチャの詳細**
   - 全体構成の概要
   - モジュール設計とディレクトリ構造
   - 関数型的アプローチとの統合

6. **チーム拡大で見えてきた課題**
   - 具体的な課題の紹介
   - 解決のためのアプローチ
   - 今後の改善予定

7. **まとめ**
   - 学んだこと・得られた知見
   - EVERSTEELでの開発について

**authorからのフィードバック**: 記事として少し大きくなりそうだが、この構成で進める

**決定事項**: 上記構成で執筆開始

### 手順3: 章ごとに記事を書いていく

**第1章「はじめに」執筆完了**
- authorからのフィードバック適用：
  - 抽象と具体の重複を削除（関数型プログラミングの具体例削除）
  - 記事の雰囲気を和らげる（「参考に」→「現状・雰囲気を感じてもらえれば」）

**第2章「鉄ナビ検収とは」執筆完了**
- authorからのフィードバック適用：
  - バックエンドの重要性を「システム連携」の観点で説明
  - AIモデル改良はAIチーム担当のため除外

**第3章「技術スタックの選択理由」執筆完了**
- TypeScript、Nest.js、関数型プログラミング採用理由を明記

**第4章「関数型プログラミングの実践」執筆完了**
- Branded-Type、neverthrow、Workflow実装について紹介
- Workflowについては課題があることに言及し、詳細は後章に譲る構成

**第4章「関数型プログラミングの実践」承認とcommit完了**

**現在の状況**: 第5章「アーキテクチャの詳細」の執筆段階

**第5章執筆のための技術情報（authorから提供）**:

**システム構成**:
- `cloud_sms`: 工場ごとに異なる基幹システムとの連携をサポート。異なるJSON Schemaを用いた変換ロジックで、異なる基幹システムの実装に対応
- `assessment_manager`: 基幹システムからの検収情報を処理
- `capture_session`: 検収情報とユーザからの操作を元に、撮影ループを処理
- `ai_assessment`: 撮影ループで解析対象と判定されたフレームのAI解析を実施
- 注記: Cloud側のNCSやFrameClassificationは現在工場ローカルでの処理に移行中

**ディレクトリ構成**:
現状:
```
src/
  ai_assessment/
    application/
    domain/
    infrastructure/
    presentation/
  assessment_manager/
    application/
    domain/
    infrastructure/
    presentation/
  ...
```

目指している形:
```
src/
  presentation/
    auth
    control
    admin
    cloud_sms
  domain(?名称未定)
    ai_assessment/
      application/
      domain/
      infrastructure/
    assessment_manager/
```

**具体的なコード例（authorから提供）**:

**Branded-TypeとResult型の応用**:
AssessmentId（検収ID）の実装:
```typescript
export type AssessmentId = Branded<string, 'AssessmentId'>;
const AssessmentId = (value: string): AssessmentId => value as AssessmentId;

export const parseAssessmentId = (
    value: string,
): Result<AssessmentId, DomainError> =>
    typeof value === 'string' && value.length > 0
        ? ok(AssessmentId(value))
        : err(genUnknownError('AssessmentId is string and not empty'));
```

Entity作成時の実装:
```typescript
export type AssessmentEntity = {
    id: AssessmentId;
    ...
};

export type AssessmentEntityParserProps = RecursiveUnbrand<AssessmentEntity>;

export const parseAssessmentEntity = (
    props: AssessmentEntityParserProps,
): Result<AssessmentEntity, DomainError> =>
    Result.combine([
        parseAssessmentId(props.id),
        ...,
    ]).map(
        ([
            id,
            ...,
        ]) => ({
            id,
            ...,
        }),
    );
```

**Workflowの利用例**:
実際にはWorkflowの特定ケースである「Usecase」を定義し、application/usecase/で利用:
```typescript
export const startAiAssessmentUsecase = (repositories: Repositories) =>
    usecaseEntry(validate)(resolve(repositories))(usecase(repositories));

const usecase = (repositories: Repositories) =>
    usecaseInit<Usecase.Entities>()
        .chain((args, ctx) =>
            registerInitialAiAssessmentWorkflow(repositories.aiAssessmentRepository)(
                args,
                ctx,
            ),
        )
        .chain((args, ctx) =>
            configureAnalyzingConfigWorkflow(repositories.analyzingConfigRepository)(
                args,
                ctx,
            ),
        )
        .chain((args, ctx) =>
            notifyFrontendOfAiAssessmentStartedWorkflow(repositories.cacheClient)(
                args,
                ctx,
            ),
        );
```

**技術的な実装詳細（authorから提供）**:

**依存性注入の使い方**:
```typescript
@Injectable()
export class StartAiAssessmentUsecase {
    private readonly logger = new Logger(StartAiAssessmentUsecase.name);
    constructor(
        @Inject(AI_ASSESSMENT_AI_ASSESSMENT_REPOSITORY)
        private readonly aiAssessmentRepository: AiAssessment_AiAssessmentRepository,
        @Inject(AI_ASSESSMENT_ANALYZING_CONFIG_REPOSITORY)
        private readonly analyzingConfigRepository: AiAssessment_AnalyzingConfigRepository,
        @Inject(AI_ASSESSMENT_CAPTURE_SESSION_REPOSITORY)
        private readonly captureSessionRepository: AiAssessment_CaptureSessionRepository,
        @Inject(AI_ASSESSMENT_STEEL_MILL_REPOSITORY)
        private readonly steelMillRepository: AiAssessment_SteelMillRepository,
        @Inject('CacheClient') // TODO: 古いmoduleへの依存を撤廃する
        private readonly cacheClient: CacheClient,
    ) {}

    exec(args: Usecase.Args) {
        return startAiAssessmentUsecase({
            aiAssessmentRepository: this.aiAssessmentRepository,
            analyzingConfigRepository: this.analyzingConfigRepository,
            captureSessionRepository: this.captureSessionRepository,
            steelMillRepository: this.steelMillRepository,
            cacheClient: this.cacheClient,
        })(args, { usecaseName: 'StartAiAssessment', logger: this.logger });
    }
}
```

**エラーハンドリングの実際の流れ**:
```typescript
@Injectable()
export class ApplicationErrorService {
    private readonly logger = new Logger(ApplicationErrorService.name);
    private readonly pushToSentry = pushBeError(this.sentry);

    constructor(private readonly sentry: SentryService) {}

    // エラーの mapping を受け取り、エラーを HttpException に変換する変換器を返す
    buildExceptionConverter = (mappings: ErrorMappings = {}) => {
        const converter = presentationErrorConverter(mappings);

        return (
            e: DomainError | UsecaseError | PresentationError,
        ): HttpException => {
            const pErr = isPresentationError(e) ? e : converter(e);

            // 5xx のエラーを Sentry に送信する
            if (pErr.statusCode >= 500) {
                // NOTE: pErr.message (発生した生のエラーメッセージ) が Sentry で報告される
                this.pushToSentry(pErr);
            }

            return convertPresentationErrorToException(pErr);
        };
    };

    warn = pushWarning(this.sentry);
    warnSlowProcess = () => warnSlowProcess(this.logger, this.sentry);
}
```

**第5章「アーキテクチャの詳細」執筆完了**
- クリーンアーキテクチャの4層構造を中心に説明
- システム構成の4つのコンポーネント紹介
- Branded-TypeとResult型のドメインモデル活用例
- Nest.jsとビジネスロジックの分離について
- 将来のディレクトリ構造改善への展望
- authorから承認済み

**第6章「チーム拡大で見えてきた課題と取り組み」執筆完了**
- 既出の技術的課題に加え、現在進行中の取り組みを中心に構成
- オブザーバビリティ強化の段階的アプローチ（優先度付きで詳細化）
- 事業拡大に伴う課題（工場オンボーディング、データ整合性、コスト最適化）
- 開発プロセスの進化（AI活用開発、Project as Code、テスト戦略、ドキュメント整備）
- 詳細は今後の技術ブログで紹介予定と明記し、概要レベルでの紹介に留める

### 手順7: まとめ

**第7章「まとめ」執筆完了**
- 技術選択の背景、実践的なアプローチ、継続的な改善、技術と事業の両立の4つの観点でまとめ
- 独自Workflow実装の言及を削除し、関数型プログラミング全体の取り組みとして簡潔に表現
- EVERSTEELでの開発環境の特徴（試行錯誤、挑戦的で実践的な環境）を強調

**最終調整完了**
- タイトルから「（仮）」を削除：「鉄ナビ検収のアーキテクチャを紹介します！」
- topicsを["typescript"]から["typescript", "nestjs", "architecture", "backend"]に拡充
- 記事全体の構成と一貫性を最終確認
- 「学びの多い環境」→「挑戦的で実践的な環境」に修正

**authorによる承認取得**
- 2025年1月28日: author承認完了

**現在の状況**: 記事執筆完了、承認済み、commit準備完了

## 記事見直しと修正作業

### 2025年1月27日 - 記事全体の見直し実施

**見直しの背景**:
- 記事の続きを執筆する前に、現在の内容を全体的に見直し
- Claudeによる問題点の指摘とauthorからの追加指摘を受けて修正計画を策定

**指摘された主要な問題点**:

1. **文体・表現の問題**
   - 「あえて関数型プログラミング」の「あえて」表現が不適切
   - 断言トーンが多すぎる（特に実験的・独自実装部分）
   - まだ一般的でない技術に対してより謙虚な表現が必要

2. **Workflow実装の説明不足**
   - 現在の記事では課題について曖昧に言及するのみ
   - authorから詳細なWorkflowドキュメントを提供
   - 具体的な課題（型システムの複雑性、デバッグの困難さ等）を明記すべき

3. **構成・一貫性の問題**
   - 「はじめに」の「詳しく解説予定」と実際の章構成にずれ
   - コードサンプルの統一感不足
   - 実践的価値（判断理由・他選択肢との比較）の説明不足

**Workflowに関する詳細情報（authorから提供）**:

**背景と経緯**:
- neverthrowのResultAsyncチェーンの深いネスト問題を解決
- 一般的な関数にResultAsyncを返す制約を追加し、フラットなDSL構築
- 過度に複雑にせず実用性重視の方針

**現在の実装**:
```typescript
export type WorkflowTask<I extends TaskInput, O extends TaskOutput> = (
    args: I,
    context: Context,
) => ResultAsync<O, Error>;

export class Workflow<I extends TaskInput, O extends TaskOutput> {
    public static init<I extends TaskInput>() {
        return new Workflow<I, I>(okAsync);
    }
    public chain = <WO extends TaskOutput>(
        wf: WorkflowTask<O, WO>,
    ): Workflow<I, O & WO> => { /* 実装詳細... */ };
}
```

**現在抱えている課題**:
1. **型システムの複雑性**: 交差型の累積、大規模ワークフローでの型推論困難
2. **状態管理の課題**: 各ステップの出力が累積し続ける、不要データの保持
3. **デバッグの困難さ**: エラー発生箇所の特定困難、実行時中間状態が見えない
4. **機能的制約**: 並列実行困難、複雑な条件分岐・ループ処理の表現困難
5. **実装の未完成部分**: handleError関数の実装必要、エラーハンドリング初期化方法不明確

**技術的トレードオフ**:
- 型安全性 vs 簡潔性: 型の複雑さを許容して安全性優先
- 機能性 vs 保守性: 機能を絞って保守しやすさ重視
- パフォーマンス vs 可読性: 実行効率より開発効率優先

**決定した修正計画**:

**【優先度：高】**
1. 文体・表現の修正（「あえて」削除、断言トーン調整）
2. Workflow章の大幅改善（150-188行を詳細ドキュメント基準で書き換え）

**【優先度：中】**
3. はじめに章の整合性確保
4. コードサンプルの改善
5. 実践的価値の向上（判断理由と比較の追加）

**作業手順**:
1. 記録ファイルに修正計画を記載 ← 完了
2. 文体修正から開始 ← 完了
3. Workflow章の詳細書き換え ← 完了
4. その他の修正を順次実施 ← 継続中

### 2025年1月27日 - 高優先度修正の実施

**実施した修正内容**:

**1. 文体・表現の修正（完了）**
- 「あえて関数型プログラミング」の「あえて」を削除
- 断言トーンを謙虚な表現に調整
  - 「〜できています」→「〜を図っています」「〜を目指しています」
  - 「〜に威力を発揮します」→「〜に効果的と考えています」
  - 「実感しています」→「体験を得ています」
- 関数型プログラミングの有効性説明を簡略化し、具体的実践に重点を移した

**2. Workflow章の大幅改善（完了）**
- 記事の理解を助けるための実装の簡略化について冒頭で明記
- 実用性について正直な評価を追加
  - 「実験的な段階」「本格的な実用には課題が多い」と明記
  - 具体的課題を詳細化（型システムの複雑性、状態管理、デバッグの困難さ、実装の未完成部分）
- 現実的な活用範囲を明記（「限定的」「試験的」「小規模」）
- `ts-pattern`による条件分岐の実現方法を追加
- authorの指摘により「並列実行困難」「ループ処理困難」の記載を削除
- 技術的トレードオフの説明を追加
- Effect-TSなど既存ライブラリとの比較検討についても言及

**修正結果**:
- 読者に誤解を与えることなく、開発現場の実際の試行錯誤を表現
- 断言的な表現を抑制し、より現実的で謙虚なトーンに変更
- 実験的な技術について正直で透明性のある説明に改善

**残作業（中優先度）**:
- はじめに章と実際の章構成の整合性確保
- コードサンプルの統一感と説明改善
- 実践的な価値と判断理由の追加

### 2025年1月27日 - 中優先度修正の実施

**実施した修正内容**:

**3. はじめに章の整合性確保（完了）**
- 「詳しく解説予定」と実際の章構成の不一致を修正
- 「チームが拡大する中で見えてきた課題と対応」の章が未執筆であることを反映
- 実際の章構成に合わせた内容紹介に変更

**4. コードサンプルの統一感と説明改善（完了）**
- Branded-Type説明の重複を解消（UserId/FactoryIdの例を簡潔化し、AssessmentIdの実装例への参照を追加）
- Branded型の基本定義を追加（`declare const __brand: unique symbol`等）
- エラー型をDomainErrorから標準のErrorに統一
- より実用的で理解しやすいコード例に改善

**5. 実践的な価値と判断理由の追加（完了）**
- TypeScript選択理由に実際の背景を追加
  - 「様々な経験レベルのメンバーが参加する中」という表現で経験の浅さをオブラートに包んで表現
  - エコシステム活用やチーム間知見共有の実践的価値を明記
- Nest.js選択理由に具体的な課題解決の観点を追加
  - Express.jsからの移行という不正確な記述を削除
  - 複雑なシステム連携への対応、標準機能の迅速な実装など実用的な理由を強調
- 関数型プログラミング採用に実際の課題背景を追加
  - 「エラーハンドリングの見落とし」という具体的な課題を明記
  - Result型導入による改善への取り組みを説明

**修正結果**:
- 読者にとってより実践的で参考になる判断背景を提供
- 技術選択の実際の理由と課題を正直に、しかし適切に表現
- コードサンプルの重複解消と実用性向上
- 記事全体の構成と内容の一貫性を確保

**全体的な修正作業の完了**:
高優先度・中優先度の修正作業が完了し、記事の品質と読者への価値提供が大幅に向上しました。