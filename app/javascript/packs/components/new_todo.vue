<template>
  <div class="container">
    <navbar v-bind="{setTokenAPI, updateTokenAPI}"></navbar>
    <h2 class="title">TODO新規登録</h2>
    <form class="form-horizontal todo-form">
      <!-- タイトル -->
      <div class="form-group">
        <p class="error-msg" id="title-err-msg">タイトルを入力してください</p>
        <label for="input-title" class="form-label">Title:</label>
        <input id="input-title" class="form-control" v-model="title" placeholder="タイトル">
      </div>
      <!-- TODO本文 -->
      <div class="form-group">
        <p class="error-msg" id="todo-err-msg">TODOを入力してください</p>
        <label for="input-todo" class="form-label">TODO:</label>
        <textarea id="input-todo" class="form-control" rows="3" v-model="todo"></textarea>
      </div>
      <!-- TODOのデッドライン -->
      <div class="row">
        <div class="form-group col-sm-12 col-xs-12 col-md-4 col-lg-4">
          <label for="input-deadline" class="form-label">期限:</label>
          <input id="input-deadline" type="datetime-local" class="form-control" v-model="deadline">
        </div>
      </div>
      <br><br>
      <!-- 登録ボタン -->
      <div class="row form-group">
        <button type="button" class="btn btn-primary col-sm-12 col-xs-12 col-md-6 col-lg-6 col-md-offset-3 col-lg-offset-3" @click="addTodo">add TODO</button>
      </div>
    </form>
  </div>
</template>

<script>
import axios from 'axios';
import Header from './templates/sign_in_header.vue'

export default {
  components:{
    'navbar': Header
  },
  data: function(){
    return {
      title: '',
      todo: '',
      deadline: ''
    }
  },
  mounted: function () {
    // ログインされていないならログイン画面に飛ばす
    this.$parent.signInCheck("", "/sign_in");
    // テキストエリアの装飾
    this.todo = new SimpleMDE({ element: document.getElementById("input-todo"), forceSync: true });
    // デッドラインを現在時刻に設定
    this.deadline = this.getApplicableDate(new Date());
  },
  methods: {
    /**
    * addTodo
    * TODOを追加する
    * 成功したらTODO一覧にリダイレクト
    */
    addTodo: function() {
      console.log(this.todo.value());
      // 入力チェック
      var err_flag = false;
      if (this.title == "") {
        $("#title-err-msg").show();
        err_flag = true;
      } else {
        $("#title-err-msg").hide();
      }
      if (this.todo.value() == "") {
        $("#todo-err-msg").show();
        err_flag = true;
      } else {
        $("#todo-err-msg").hide();
      }
      // データ追加・view変更
      if (!err_flag) {
        this.setTokenAPI();
        axios.post("/api/todos", {todo: {title: this.title, todo: this.todo.value(), deadline: this.deadline, finish: false}}).then((response) => {
            this.$router.push('/');
          }, (error) => {
            // 失敗処理
            console.log(error);
            alert("TODO保存に失敗しました");
        });
      }
    },

    /**
    * getApplicableDate
    * 日付データをinput(datetime-local)タグに適用できる形に変換
    * @param date: 変換前の日付データ(レスポンスで受け取った日付データ)
    */
    getApplicableDate: function(date) {
      return moment(date).format("YYYY-MM-DDTHH:mm");
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
  }
}
</script>
<style src="./css/common.css"></style>
