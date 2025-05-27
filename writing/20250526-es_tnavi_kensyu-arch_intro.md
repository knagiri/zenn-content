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

**現在の状況**: 第6章「チーム拡大で見えてきた課題」の執筆段階