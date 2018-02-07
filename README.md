# MyBiB

自分の文献などの整理用

## LDBib (Lightweight Data for Bibliography)

### 記述ルール

yaml に似ているがちょっとだけ書きやすくした（つもり）

- field は key : value で構成される
- record は複数のフィールドからなる（区切りは空行）
- 先頭行 # はコメント行 `/^#/`
- 空行はレコード区切り /^\s*$/, コメント行でも OK

{区切りの例}
```
authors: Hiroyuki Okamura
title: XXX

# 空行もしくはコメント行でレコードを区切る

authors: Hiroyuki
title: YYY
```

- キーの先頭は半角アルファベットかアンダーバーで始まる必要あり `/^[A-Za-z_]/`
- キーとバリューの区切りは : で前後のスペースとバリューの最後の改行は含まない
- 先頭がスペースやタブなどの空欄は前の行からの続き `/^\s/`

{継続行の例}
```
authors:
 Hiroyuki Okamura
 Tadashi Dohi
title: XXX

# 逆に言うとキーは必ず頭に空白入れてはダメ
```

- datatype :hash にすると一番最初のフィールドの value がキーとなる hash を作る（<-謎？）
- すべてのレコードに入れるフィールドは先頭に @ マークをつける（<-謎？）
- 各フィールドの value を加工する filters を設定可能（使いやすいかどうかは謎）
    - Filter, ArrayFilter, SymbolFilter は最初からある．例えば DataFilter は ArrayFilter の拡張なので，継承して，
    ```
    class DateFilter < ArrayFilter
      def filter(value)
        value.gsub(/\//, ",")
      end
    end
    ```
    とかき，filters ハッシュに
    ```
    filters[:date] = DateFilter.new
    ```
    として登録する．
- モジュール LDBib 内にデフォルトのフィルタ Filters が定義してある．
- keys については登録済みのものだけ
