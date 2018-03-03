<template>
  <div class="container">
    <!-- ヘッダー -->
    <navbar v-bind="{setTokenAPI, updateTokenAPI}" ref="header"></navbar>
    <div class="col-sm-12 col-xs-12 col-md-10 col-lg-10 col-md-offset-1 col-lg-offset-1">
      <h2 class="title">TODO LIST</h2>

      <!-- 検索ボックス -->
      <searchbox v-bind="{setTokenAPI, updateChildren, hideEditForm}"  ref="searchbox"></searchbox>
      <div style="padding-bottom: 30px"></div>

      <div v-cloak>
        <!-- todoが1つ以上あるならリスト表示 -->
        <div v-if="todos.length != 0">
          <div id="todo-list">
            <!-- TODOのリスト表示 -->
            <div v-for="(todo, index) in todos" v-bind:id="'row-todo-' + todo.id" class="todo-box row">

              <!-- todo表示 -->
              <div v-bind:id="'todo-content-'+todo.id" class="todo-content">
                <!-- todoのタイトル -->
                <div class="todo-head">
                  <h4 class="todo-title">{{ todo.title }}</h4>
                  <button id="finish-btn" class="finish-btn btn btn-info" v-if="todo.finish" @click="changeFinish(index, todo.id);">finish</button>
                  <button id="finish-btn" class="finish-btn btn btn-danger" v-else @click="changeFinish(index, todo.id);">not finish</button>
                </div>
                <!-- 期限deadline -->
                <p>期限：<span class="todo-deadline"><b>{{ getDisplayDate(todo.deadline) }}</b></span></p>
                <!-- todoの内容 -->
                <div class="todo-textbox">
                  <p class="todo-text" v-html="todo.mde_todo"></p>
                </div>
                <!-- todoの追加・更新日時 -->
                <p class="todo-at-row">追加：<span class="todo-at">{{ getDisplayDate(todo.created_at) }}</span><br>
                更新：<span class="todo-at">{{ getDisplayDate(todo.updated_at) }}</span></p>

                <!-- todoのメニューボタン(削除と編集) -->
                <div class="todo-toolbox">
                  <button @click="deleteTodo(todo.id)" class="todo-toolbutton btn btn-danger" title="削除する"><i class="fa fa-trash fa-lg"></i></button>
                  <button @click="todo.edit=showEditForm(index);" class="todo-toolbutton btn btn-info" title="編集する"><i class="fa fa-pencil-square-o fa-lg"></i></button>
                  <button @click="tweetTodo(index)" class="todo-toolbutton btn btn-primary" title="ツイートする">tweet&nbsp;<i class="fa fa-twitter fa-lg"></i></button>
                </div>
              </div>

              <!-- todo編集 -->
              <div v-bind:id="'todo-editable-content-'+todo.id"  class="todo-editable-content">
                <form>
                  <!-- タイトル -->
                  <div class="form-group">
                    <p class="error-msg" v-bind:id="'title-err-msg-'+todo.id">タイトルを入力してください</p>
                    <p class="label">タイトル</p>
                    <input v-bind:id="'input-title-'+todo.id" class="form-control" v-bind:value="todo.title">
                  </div>
                  <!-- デッドライン -->
                  <div class="form-group">
                    <p class="label">期限</p>
                    <input v-bind:id="'input-deadline-'+todo.id" type="datetime-local" class="form-control" v-bind:value="getApplicableDate(todo.deadline)">
                  </div>
                  <!-- todoの内容 -->
                  <div class="form-group">
                    <p class="error-msg" v-bind:id="'todo-err-msg-'+todo.id">TODOを入力してください</p>
                    <p class="label">TODO</p>
                    <textarea v-bind:id="'input-todo-'+todo.id" class="form-control" :rows="todo.todo.split('\n').length+1">{{todo.todo}}</textarea>
                  </div>
                </form>
                <!-- メニューボタン(保存、変更キャンセル) -->
                <div class="todo-toolbox">
                  <button @click="updateTodo(todo.id, index)" class="todo-toolbutton btn btn-primary" title="保存する"><i class="fa fa-upload"></i></button>
                  <button @click="hideEditForm(index, todo.id);" class="todo-toolbutton btn btn-warning" title="変更をキャンセルする"><i class="fa fa-times"></i></button>
                </div>
              </div>
            </div>
          </div>
          <!-- ページング -->
          <paging v-bind="{setTokenAPI, hideEditForm}" ref="paging"></paging>
        </div>

        <!-- TODOがない場合は新規登録のリンクのみ -->
        <div v-else>
          <router-link :to="{ path: '/new' }">
            <p class="initial-message">
              <span class="initial-message-row">TODOを追加してみましょう！</span>
            </p>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>


<script>
  import axios from 'axios';
  import Header from './templates/sign_in_header.vue'
  import Searchbox from './templates/searchbox.vue'
  import Paging from './templates/paging.vue'

  export default {
    components: {
      "searchbox": Searchbox,
      "paging": Paging,
      "navbar": Header
    },
    data: function () {
      return {
        todos: [],
        page: 1,  // 表示しているtodoのページ数
        editting_index: -1, // 編集中のtodoのtodos上のインデックス
        // 保存した検索条件
        saved_search_word: '',
        saved_search_target: 'title',
        saved_todo_condition: 'false',
        saved_sorting_way: 'deadline',
        saved_order: 'DESC'
      }
    },
    mounted: function () {
      // 最初のアクセスで1ページ分のデータ取得
      this.fetchTodos();
    },
    methods: {
      /**
      * fetchTodos
      * 自分のTODOを1ページ分取得
      */
      fetchTodos: function () {
        this.setTokenAPI();
        axios.get('/api/todos', {page: 1}).then((response) => {
          for(var i = 0; i < response.data.todos.length; i++) {
            // simpleMDE関連の設定
            response.data.todos[i]["mde_todo"] = marked(response.data.todos[i]["todo"]);
            this.todos.push(response.data.todos[i]);
          }
        }, (error) => {
          // 失敗時はログイン画面にリダイレクト
          this.$router.push('/sign_in');
        });
      },

      /**
      * deleteTodo
      * 選択したTODOを削除
      * 削除後に保存した条件で検索したTODOを読み直して再描画
      * @param todo_id: 削除するTODOのID
      */
      deleteTodo: function(todo_id) {
        this.setTokenAPI();
        axios.delete("/api/todos/"+todo_id, {}).then((response) => {
          // 保存した検索条件・ページ数で検索し再描画
          this.$refs.paging.jumpPage(this.page);
        }, (error) => {
          console.log(error);
          alert("TODO削除に失敗しました。");
        });
      },

      /**
      * changeFinish
      * finishを変更する。
      * 変更をPOSTし、this.todosのデータを変更することで再描画する
      * @param todo_id: 変更するTODOのID
      * @param index: 変更するTODOのthis.todos内でのインデックス
      */
      changeFinish: function(index, todo_id) {
        this.setTokenAPI();
        axios.post("/api/todos/change_finish", {id: todo_id}).then((response) => {
          // 変更結果を上書きして再描画
          var todo_temp = this.todos[index];
          todo_temp.finish = response.data.finish;
          this.$set(this.todos, index, todo_temp);
        }, (error) => {
          console.log(error);
          alert("TODO完了処理に失敗しました。");
        });
      },

      /**
      * updateTodo
      * TODOを変更する。
      * 変更をPUTし、this.todosを更新することで変更分を再描画する
      * @param todo_id: 変更するTODOのID
      * @param index: 変更するTODOのthis.todos内でのインデックス
      */
      updateTodo: function(todo_id, index) {
        // 入力チェック
        var err_flag = false;
        if ($("#input-title-"+todo_id).val() == "") {
          $("#title-err-msg-"+todo_id).show();
          err_flag = true;
        } else {
          $("#title-err-msg-"+todo_id).hide();
        }
        if ($("#input-todo-"+todo_id).val() == "") {
          $("#todo-err-msg-"+todo_id).show();
          err_flag = true;
        } else {
          $("#todo-err-msg-"+todo_id).hide();
        }
        // エラーがないならPUT
        if (!err_flag) {
          this.setTokenAPI();
          axios.put("/api/todos/"+todo_id, {todo:
            {title: $("#input-title-"+todo_id).val(),
            todo: $("#input-todo-"+todo_id).val().replace(/\r?\n/g, "\n"), deadline: $("#input-deadline-"+todo_id).val()
          }}).then((response) => {
            // 編集フォームを閉じる
            this.hideEditForm();
            // vue側のTODOを更新する
            var todo_temp = response.data;
            // simpleMDE関連の設定
            todo_temp.mde_todo = marked(todo_temp.todo);
            todo_temp.mde = null;
            this.$set(this.todos, index, todo_temp);
          }, (error) => {
            console.log(error);
            alert("updateに失敗しました。");
          });
        }
      },

      /**
      * updateChildren
      * 子コンポーネントを必要な分更新する
      * 今の所ページングのみ
      */
      updateChildren: function(){
        this.$refs.paging.renewPaging();
      },

      /**
      * showEditForm
      * 編集フォームを出現させる
      * 他の編集フォームがあれば削除する
      * @param index: 編集フォームを表示したいtodos上のインデックス
      */
      showEditForm: function (index) {
        // すでに開いていたら編集フォームを閉じる
        if (this.editting_index != -1) {
          this.hideEditForm();
        }
        var todo_temp = this.todos[index];
        this.editting_index = index;
        // 編集フォーム出現
        $("#todo-content-"+todo_temp.id).hide();
        $("#todo-editable-content-"+todo_temp.id).show();
        // simpleMDEの設定
        todo_temp.mde = new SimpleMDE({ element: document.getElementById("input-todo-"+todo_temp.id), forceSync: true });
        todo_temp.mde.value(todo_temp.todo);
      },

      /**
      * hideEditForm
      * 生成した編集フォームを削除する。
      * SimpleMDEで生成したフォームの削除方法は頭が悪いがこの方法しか思いつかなかった。
      * 他にいい方法あったら教えてください
      */
      hideEditForm: function () {
        // すでに開いていたら編集フォームを閉じる
        if (this.editting_index != -1) {
          $("#todo-editable-content-"+this.todos[this.editting_index].id).hide();
          $("#todo-content-"+this.todos[this.editting_index].id).show();
          this.editting_index = -1;
        }
        // SimpleMDEで生成したフォームの削除
        $(".editor-toolbar").remove();
        $(".CodeMirror").remove();
        $(".editor-statusbar").remove();
      },

      /**
      * setTokenAPI
      * 認証用のトークンを設定
      * 子コンポーネントでも$parent~で使用できるようにするため定義している。todo.jsを参照
      */
      setTokenAPI: function() {
        this.$parent.setTokenAPI();
      },

      /**
      * updateTokenAPI
      * 認証用のトークンを更新
      * 子コンポーネントでも$parent~で使用できるようにするため定義している。todo.jsを参照
      * @param token: 更新するtoken
      */
      updateTokenAPI: function(token){
        this.$parent.updateTokenAPI(token);
      },

      /**
      * signInCheck
      * ログインしているかチェック
      * ログインしているかどうかによってリダイレクト先を変える
      * 子コンポーネントでも$parent~で使用できるようにするため定義している。todo.jsを参照
      * @param signed_in_redirect2: ログインしている場合のリダイレクト先のリンク
      * @param other_redirect2: ログインしていない場合のリダイレクト先のリンク
      */
      signInCheck: function(signed_in_redirect2, other_redirect2){
        this.$parent.signInCheck(signed_in_redirect2, other_redirect2);
      },
      /*
      -------------------------------------------------------------------------
      ここからサブ関数
      -------------------------------------------------------------------------
      */
      /**
      * getApplicableDate
      * 日付データをinput(datetime-local)タグに適用できる形に変換
      * @param date: 変換前の日付データ(レスポンスで受け取った日付データ)
      */
      getApplicableDate: function(date) {
        return moment(date).format("YYYY-MM-DDTHH:mm");
      },

      /**
      * getDisplayDate
      * 日付データを表示用のフォーマットに変換
      * @param date: 変換前の日付データ(レスポンスで受け取った日付データ)
      */
      getDisplayDate: function(date) {
        return moment(date).format("YYYY MM/DD(dddd) HH:mm");
      },

      /**
      * tweetTodo
      * TODOの内容をツイートする
      * @param index: todoのthis.todos上のインデックス
      */
      tweetTodo: function (index) {
        var todo = this.todos[index];
        var textToTweet = "";
        /* 完了したかしてないかで内容を変える */
        if (todo.finish) {
          textToTweet += "TODOを完了しました！\r\n";
        } else {
          textToTweet += "TODOが追加されました！\r\n";
        }
        /* TODOのタイトルの最初の100文字くらいをツイート */
        textToTweet += todo.title.substr(0, 100);
        if (todo.title.length >= 100) {
          textToTweet += "...";
        }
        textToTweet += "\r\nhttp://vtodoapp.herokuapp.com/\r\n#vtodoapp";
        var twtLink = 'http://twitter.com/home?status=' +encodeURIComponent(textToTweet);
        window.open(twtLink,'_blank');
      }
    }
  }
</script>

<style scoped>
  [v-cloak] {
    display: none;
  }
  .main {
    background-color: white;
  }
  .label {
    color: black;
  }
  /* TODOがない時のメッセージ */
  .initial-message{
    text-align: center;
  }
  /* TODOがないときのメッセージ */
  .initial-message-row{
    color: rgb(57, 140, 255);
    font-size: 180%;
    font-family: serif;
    border-bottom: solid 1px rgb(57, 140, 255);
  }
  .initial-message-row:hover{
    border-bottom: 0px;
  }

  /* 1つのTODO全体 */
  .todo-box{
    padding: 30px 0px 30px 0px;
    border-bottom: 1px solid rgba(38, 38, 38, 0.5);
  }
  .todo-box:hover{
    background-color: rgb(221, 221, 221);
  }
  /* TODOのヘッダー(タイトルとfinishボタン) */
  .todo-head{
    padding-bottom: 50px;
  }
  .todo-title{
    vertical-align: middle;
    text-align: center;
    float: left;
  }
  .finish-btn{
    vertical-align: middle;
    text-align: center;
    float: right;
  }
  /* 編集フォームは初めは非表示 */
  .todo-editable-content {
    display: none;
  }
  /* TODO本文の枠 */
  .todo-textbox{
    border: 1px solid rgb(143, 201, 223);
    border-radius: 10px;
  }
  /* TODO本文 */
  .todo-text{
    white-space: pre-wrap;
    margin: 15px;
    word-wrap: break-word;
  }
  .todo-deadline{
    font-family: serif;
    font-size: 120%;
    color: rgb(0, 26, 139);
  }
  /* TODOの日付ブロック */
  .todo-at-row {
    font-size: 90%;
  }
  /* TODOの日付インライン */
  .todo-at {
    font-family: serif;
  }
  /* いくつかのボタンをもつツールボックス */
  .todo-toolbutton{
    margin-right: 10px;
    float: left;
  }
</style>
<style src="./css/common.css"></style>
