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

なおこのファイルが `/path/to/docs/000_index.md` であるとき、`file_path: ./001_author.md` と記載されいる場合は `/path/to/docs/001_author.md` にファイルが存在します。

## List

### 筆者情報

- refer_for: 自己紹介の時に参照する。
- file_path: ./001_author.md

### ルール

- refer_for: 常に参照する。
- file_path: ./002_rules.md

### Writing

- refer_for: 常に参照する。
- file_path: ./003_writing.md
