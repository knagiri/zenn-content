# Zenn Markdown記法ガイド

Zenn で記事を執筆する際に利用できるMarkdown記法の参考情報です。
記事執筆時には最新の公式ガイドを参照してください。

## 公式ガイド

- **Zenn公式Markdown記法ガイド**: https://zenn.dev/zenn/articles/markdown-guide

## 主要な記法（概要）

### 基本記法
- 見出し: `#`, `##`, `###`, `####`
- リスト: `-` または `*`、番号付きは `1.`
- リンク: `[テキスト](URL)`
- 画像: `![Alt text](URL)` または `![](URL =250x)` (幅指定)

### コードブロック
```
# 基本
```言語名
コード
```

# ファイル名表示
```js:ファイル名.js
コード
```

# Diffハイライト
```diff js
+ 追加行
- 削除行
```
```

### Zenn独自記法
```
# メッセージ
:::message
内容
:::

:::message alert
警告内容
:::

# アコーディオン
:::details タイトル
内容
:::
```

### 埋め込み
- リンクカード: URLを直接記載
- YouTube: `@[youtube](URL)`
- Twitter: `@[twitter](URL)`
- GitHub: `@[github](URL)`

### 数式
- ブロック: `$$ 数式 $$`
- インライン: `$数式$`

### ダイアグラム
- Mermaid: `mermaid` コードブロック

## 注意事項

記事執筆時は必ず上記の公式ガイドURLにアクセスして最新の記法を確認してください。