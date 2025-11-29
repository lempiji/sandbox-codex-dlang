# unit-threaded samples

unit-threaded を使ったシンプルなテストコード集です。`source/unit_threaded_samples/app.d` にはテスト対象（簡単な計算と文字列操作）があり、unit-threaded の以下の機能を実演します。

- `@Name` と `assertEqual` によるテスト命名と可読性の高いアサーション
- `@Values` + `@AutoTags` を使った data-driven テスト
- `@ShouldFailWith` で例外を期待するテスト
- `@Flaky` でリトライ回数を指定し、テスト本体で待機時間を含めた再試行を表現（`Thread.sleep` で間隔を作っています）

## 実行方法

```sh
cd topics/unit_threaded_samples
# テストランナーは preBuildCommands で自動生成されます
dub test

# 実行バイナリでサンプルの出力を確認
# （README ルートには追記せずこのディレクトリのみ）
dub run
```
