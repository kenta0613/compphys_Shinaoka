# 計算物理学のためのJulia入門（品岡先生）
[text](https://shinaoka.github.io/julia_spring_school_2026/)

## 講義の目標
- Project.tomlとManifest.tomlの違いの理解
- AIが吐き出したコードを読解し危険な部分を見つけられるようになる
- 'BenchmarkTools'を使ってコードの高速化を検証できる

## 良いAI開発・悪いAI開発
### 悪いAI開発
- 曖昧なspellのままAIに一方向にプロンプトを渡し、結果の十分な検証を行わないやり方
  - その場しのぎ
  - 前提がAIに伝わらない
  - 人間のレビューが追いつかない

### 良いAI開発
- AIを開発エージェントとして扱う

