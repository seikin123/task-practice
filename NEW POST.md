# 投稿機能について
*目次*  
1.データベースに保存するためのモデルを作成後テーブルを作成するための、マイグレーションファイルを作成  
2.データベースに反映させる  
3.posts_controller.rb内にnewアクションを定義  
4.入力フォームを作成  
5.投稿ボタンが押されたら反応するcreateアクションを実装  
6.'/posts'にPOSTリクエストを送信  
7.createアクションが実行され、フォーム内のデータをデータベースに保存  
8.新規投稿がindex.html.erbで表示され、ユーザーの画面に表示される  

## 1.データベースに保存するためのモデルを作成後テーブルを作成するための、マイグレーションファイルを作成  
まずは、データの格納先である、データベースに保存するためのモデルを作ります。  
モデルは「データベース」そのものというよりは、データベースに対応した箱を作り、その取扱い方法を記述するというものです。  
**記述の仕方**  
Model名は`大文字から始まる単数形`にします。今回は投稿のタイトルをtitileカラム、本文のbodyカラムの2種類を作成します。  
※1つ1つのデータの格納場所を`カラム`と言います。  
データ型も指定する必要があり、`titleは255文字以内としてString型`、`bodyはそれ以上入力する可能性があるのでtext型`にします。
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
このままではデータベースに反映されていないため、記入したマイグレーションファイルを下記のコードをターミナルで実行して反映させます。
すると、データベースにテーブルが作成され、カラムが追加されます。  
**確認方法**  
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

# 新規投稿画面について記述していきます
## 3.posts_controller.rb内にnewアクションを定義  
まず、app/controllers/posts_controller.rb内にnewアクションを定義します。
```Ruby
app/controllers/posts_controller.rb

class PostsController < ApplicationController
  def new
    @post = Post.new
  end
end
```
「Post.new」と記述すると空のモデルが生成され、インスタンス変数@postに代入されてViewで利用できるようになります。  
次で記述するapp/views/posts/new.html.erbのform_withに空のモデルが代入されたインスタンス変数を渡すと、フォームとPostモデルが関連づけられ投稿できるようになります。

**※インスタンス変数とは**

クラスのオブジェクト（インスタンス）がもつ変数の1つです。  
コントローラのインスタンス変数をViewと共有することで、コントローラからViewへのデータの受け渡しを行うことができます。  
インスタンス変数に代入した値は、そのオブジェクトがある限り、オブジェクトとともに存在し続けます。  
また、インスタンス変数の名前には、先頭に必ず@（アットマーク）を付けます。    

## 4.入力フォームの作成  
投稿を新規作成するには、「空のモデル」をform_withの引数に渡す必要があるため、入力フォームを作成していきます。  
入力フォームはform_withを使用することで作成することできます。また、form_withを使用することで簡単にデータベースに保存ができます。
```Ruby
views/posts/new.html.erb

<%= form_with model: @post, local: true do |form| %>
    <p>
      <%= form.label :title %><br>
      <%= form.text_field :title %> #titleの入力フォーム生成
    </p>
    <p>
      <%= form.label :body %><br>
      <%= form.text_area :body %> #bodyの入力フォーム生成
    </p>
    <p>
      <%= form.submit %> #送信ボタンを生成
    </p>
  <% end %>
```

## 5.投稿ボタンが押されたら反応するcreateアクションを実装していきます。
```Ruby
app/controllers/posts_controller.rb

def create
  @post = Post.new(post_params) #データを新規登録するためのインスタンス生成
  @post.save #データをデータベースに保存するためのsaveメソッド実行
  redirect_to action: 'index' #トップ画面へリダイレクト
end

private
  def post_params #ストロングパラメータ
    params.require(:post).permit(:title, :body)
  end
 end
```
## 6.URL /postsにPOSTリクエストがサーバーに送信  
titleフォーム、bodyフォームに内容を記述し投稿ボタンを押すと、`まずPOSTメソッドの'/posts'といわれるところに送信`されます。 

**HTTPメソッドの役割について**  
| GET | リソースの取得 |
| :---- | :---: |
| POST | リソースの作成 |
| PUT(PATCH) | リソースの更新 |
| DELETE | リソースの削除 |  

**- 投稿ボタンが押された時のターミナルの状況**
```
1.Started POST "/posts" for ::1 at 2021-04-19 12:05:00 +0900
2.Parameters: {"authenticity_token"=>"[FILTERED]", "post"=>{"title"=>"タイトル", "body"=>"ボディー"}, "commit"=>"Create Post"
3.TRANSACTION (0.1ms)  begin transaction
   ↳ app/controllers/posts_controller.rb:13:in `create'
```
*1行目について*  
`POSTと言うリクエストが'/posts'`と言うURLに対して行われたと言う意味です。  
投稿すると'/posts'と言うURLに対して指令が出されます。ここのルーティングは`routes.rb`で設定されています。  
ターミナルで**rails routes**と入力、実行してもらうと`posts_path`には`GET`と`POST`の2種類があることがわかります。  
`posts_path`に対してgetをすると`posts#index`アクションが呼び出され、  
`posts_path`に対してpostをすると`posts#create`アクションが呼び出されます。  
今回はform_withで自動的にHTMLのフォームタグが生成され、methodの部分がpostになっているのでPOST通信が行われています。    
*2行目について*  
そして、createアクションが反応すると、@postと言う変数にPost.newが渡されます。さらに@postは（post_params）と言う引数を持っています。  
post_paramsと言うのは、privateで定義されているリクエストとともに送られてくる情報のことをいいます。  
*3行目について*  
データベースに変更をくわえる手続きを「TRANSACTION」、createはposts_controllerでのcreateアクションで行われているという意味で、正常に投稿が行われたと言うことを表しています。  

**※privateについて**  
このprivateでは何が定義されているかというと上記の(:post)と言うパラメーターのキーの中にさらに（:titleと:body）のキーを許可するということが書いてあります。  
**ストロングパラメータについて**  
`requireメソッド`を使用する事で、params内の特定のキーに紐付く値だけを抽出する事ができます。  
そのため、引数には取り出したい値のキーを指定する必要があります。`permitメソッド`を使用する事で、許可された値のみを取得することができます。  
## 7.createアクションが実行され、フォーム内のデータをデータベースに保存  
## 8.新規投稿がindex.html.erbで表示され、ユーザーの画面に表示される  
そして、createアクションで上から順にユーザーからのデータを@postに代入し、**@post.save**でデータベースへ保存をします。  
**redirect_to action: 'index'** でトップ画面へリダイレクトをし、トップ画面で投稿されていることを確認し新規投稿の流れは終了となります。

