# 投稿機能について
1.データベースに保存するためのモデルを作成後テーブルを作成するための、マイグレーションファイルを作成  
2.データベースに反映させる  
3.posts_controller.rb内にnewアクションを定義  
4.入力フォームを作成  
5.投稿ボタンが押されたら反応するcreateアクションを実装  
6.'/posts'にPOSTリクエストを送信  
7.createアクションが実行され、フォーム内のデータをデータベースに保存  
8.新規投稿がindex.html.erbで表示され、ユーザーの画面に表示される  

## 1.まずは、データの格納先である、データベースに保存するためのモデルを作ります。  
モデルは「データベース」そのものというよりは、データベースに対応した箱を作り、その取扱い方法を記述するというものです。  
記述の仕方  
Model名は大文字から始まる単数形にします。今回は投稿のタイトルをtitileカラム、本文のbodyカラムの2種類を作成します。※一つ一つのデータの格納場所をカラムと言います。  
データ型も指定する必要があり、titleは255文字以内としてString型、bodyはそれ以上入力する可能性があるのでtext型にします。
```Ruby
$ rails g model Post title:string body:text
```
上記のコマンドを実行すると、モデル、マイグレーション、テストファイルが作成されます。
マイグレーションファイルはデータベースを変更するための指示書のようなもので上記のコマンドでは下記の内容のファイルになります。


```Ruby
class CreatePosts < ActiveRecord::Migration[6.1]
def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.timestamps
    end
  end
end
```

## 2.データベースに反映させる
このままではデータベースに反映されていないため、記入したマイグレーションファイルを下記のコードをターミナルで実行して反映させると、データベースにテーブルが作成され、カラムが追加されます。
確認方法
db/schema.rbというファイルをみると、ここに追加されていることでデータベースに反映されたことが確認できます。
```Ruby
$ rails db:migrate
```

```Ruby
db/schema.rb
ActiveRecord::Schema.define(version: 2021_04_19_121504) do
  create_table "posts", force: :cascade do |t|
    t.string "title" #titleがマイグレーションされていることがわかります。
    t.text "body"    #bodyがマイグレーションされていることがわかります。
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end
end
```
新規投稿画面について記述していきます
## 3.まず、app/controllers/posts_controller.rb内にnewアクションを定義します。
```Ruby
app/controllers/posts_controller.rb

class PostsController < ApplicationController
  def new
    @post = Post.new
  end
end
```
「Post.new」と記述すると、空のモデルが生成され、インスタンス変数@postに代入されてViewで利用できるようになります。
次で記述するapp/views/posts/new.html.erbのform_withに空のモデルが代入されたインスタンス変数を渡すと、フォームとPostモデルが関連づけられ投稿できるようになります。

