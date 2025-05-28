# 目録

## この Doc について

このドキュメントは技術ブログを書く際に参照するべきドキュメント情報を記載します。

具体的には、

- 参照すべき`.md`ファイルの所在（このファイルが存在するディレクトリからの相対パス）
- どのようなケースで参照するべきか、参照することが推奨されるか

を[List](#List)に次のフォーマットで記載します。

``` md
- refer_for: 自己紹介の時は必須。
- file_path: ./001_author.md
```

`refer_for` を見て、必要と判断された場合は作業前に読み込みます。
また、作業を開始する前に必ず読み込むべきドキュメントを確認し、必要であると判断されるドキュメントは必ず読み込みます。

このファイルが `/path/to/docs/000_index.md` であるとき、`file_path: ./001_author.md` と記載されいる場合は `/path/to/docs/001_author.md` にファイルが存在します。

## List

### 筆者情報

- refer_for: 自己紹介の時に参照する。
- file_path: ./001_author.md

### Zenn Markdown記法

- refer_for: Zenn記事執筆時に必ず参照する。最新の記法情報は公式ガイドを確認する。
- file_path: ./002_zenn_markdown.md

### 基本方針

- refer_for: 作業開始時に必ず参照する。
- file_path: ./010_basic_principles.md

### 記事執筆ワークフロー

- refer_for: 作業開始時に必ず参照する。
- file_path: ./011_writing_workflow.md

### 各ステップでの詳細ルール

- refer_for: 作業開始時に必ず参照する。
- file_path: ./012_step_by_step_rules.md

### 記録ファイル管理

- refer_for: 作業開始時に必ず参照する。
- file_path: ./013_record_management.md

### 承認とcommitプロセス

- refer_for: 各ステップ完了時に参照する。
- file_path: ./014_approval_process.md
