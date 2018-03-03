<template>
  <div class="container">
    <navbar></navbar>
    <div class="col-sm-12 col-xs-12 col-md-10 col-lg-10 col-md-offset-1 col-lg-offset-1">
      <h2 class="title">ユーザー登録</h2>
      <form>
        <!-- メールアドレス -->
        <div class="form-group">
          <p class="error-msg" id="email-err-msg"></p>
          <label for="email">E-mail</label>
          <input type="text" id="email" class="form-control" name="email" v-model="email" />
        </div>
        <!-- パスワード -->
        <div class="form-group">
          <p class="error-msg" id="password-err-msg"></p>
          <label for="password">パスワード</label>
          <input type="password" id="password" class="form-control" name="password" v-model="password"/>
        </div>
        <!-- パスワード再入力 -->
        <div class="form-group">
          <p class="error-msg" id="password_confirmation-err-msg"></p>
          <label for="password_confirmation">パスワード再入力</label>
          <input type="password" id="password_confirmation" class="form-control"  name="password_confirmation" v-model="password_confirmation" />
        </div>
        <button type="button" class="btn btn-primary" @click="signUp">登録する</button>
      </form>
    </div>
  </div>
</template>
<script>
import axios from 'axios';
import Header from './templates/header.vue'

export default {
  components: {
    "navbar": Header
  },
  data: function(){
    return {
      email: '',
      password: '',
      password_confirmation: ''
    }
  },
  mounted: function () {
    this.$parent.signInCheck("/", "");
  },
  methods: {
    /**
    * signUp
    * ユーザー登録処理
    * 登録できればTODOリストへリダイレクト
    * 失敗ならエラーメッセージ表示
    */
    signUp: function () {
      // 入力チェック
      if (this.isValidInput()) {
        this.$parent.setTokenAPI();
        axios.post('/users', {user: {
          email: this.email,
          password: this.password,
          password_confirmation: this.password_confirmation
        }}).then((response) => {
          this.$parent.updateTokenAPI(response.data.csrf_token);
          alert("登録に成功しました。ログイン画面に移動します。");
          this.$router.push('/');
        }, (error) => {
          this.setErrorMessage(error.response.data.error_types);
          console.log(error.response);
        });
      }
    },

    /**
    * setErrorMessage
    * 引数からエラーメッセージを表示する
    *
    * @param error_types: エラーの種類を保持している文字列配列
    */
    setErrorMessage: function (error_types) {
      // メールアドレス不適切
      if (error_types.indexOf("email") >= 0) {
        $("#email-err-msg").text("メールアドレスが不適切です。");
        $("#email-err-msg").show();
      }
      // すでに使われているメールアドレス
      else if (error_types.indexOf("used_email") >= 0) {
        $("#email-err-msg").text("すでに使用されているメールアドレスです。");
        $("#email-err-msg").show();
      }else {
        $("#email-err-msg").hide();
      }
      // パスワードが不適切
      if (error_types.indexOf("password") >= 0) {
        $("#password-err-msg").text("パスワードは6〜30文字にしてください。");
        $("#password-err-msg").show();
        this.password = "";
        this.password_confirmation = "";
      } else {
        $("#password-err-msg").hide();
      }
      // パスワード再入力が不適切
      if (error_types.indexOf("password_confirmation") >= 0) {
        $("#password_confirmation-err-msg").text("パスワードが一致しません。");
        $("#password_confirmation-err-msg").show();
        this.password = "";
        this.password_confirmation = "";
      } else {
        $("#password_confirmation-err-msg").hide();
      }
    },

    /**
    * isValidInput
    * メールアドレス、パスワード、パスワード再度入力欄のチェック
    * 空であればエラーメッセージを表示
    *
    * @return エラーがあればfalse, なければtrue
    */
    isValidInput: function () {
      var valid_flag = true;
      // メールチェック
      if (this.email == "") {
        $("#email-err-msg").text("メールアドレスを入力してください。");
        $("#email-err-msg").show();
        valid_flag = false;
      } else {
        $("#email-err-msg").hide();
      }
      // パスワードチェック
      if (this.password == "") {
        $("#password-err-msg").text("パスワードを入力してください。");
        $("#password-err-msg").show();
        valid_flag = false;
      } else {
        $("#password-err-msg").hide();
      }
      // パスワード再度入力チェック
      if (this.password_confirmation == "") {
        $("#password_confirmation-err-msg").text("パスワードを再度入力してください。");
        $("#password_confirmation-err-msg").show();
        valid_flag = false;
      } else {
        $("#password_confirmation-err-msg").hide();
      }
      return valid_flag;
    }
  }
}
</script>
<style src="./css/common.css"></style>
