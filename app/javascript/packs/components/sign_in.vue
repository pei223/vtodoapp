<template>
  <div class="container">
    <navbar v-bind="{}"></navbar>
    <h2 class="title">ログイン</h2>
    <form>
      <!-- メールアドレス -->
      <div class="form-group">
        <p class="error-msg" id="email-err-msg">メールアドレスを入力してください</p>
        <label for="email">E mail</label>
        <input type="text" class="form-control" name="email" id="email" v-model="email">
      </div>
      <!-- パスワード -->
      <div class="form-group">
        <p class="error-msg" id="password-err-msg">パスワードを入力してください</p>
        <label for="password">パスワード</label>
        <input type="password" class="form-control" name="password" id="password" v-model="password">
      </div>
      <button type="button" @click="signIn()" class="btn btn-primary">ログイン</button>
    </form>
  </div>
</template>
<script>
import axios from 'axios';
import Header from './templates/header.vue';

export default {
  components: {
    "navbar": Header
  },
  data: function(){
    return {
      email: '',
      password: ''
    }
  },
  mounted: function () {
    this.$parent.signInCheck("/", "");
  },
  methods: {
    /**
    * signIn
    * ログイン処理
    * 成功すればTODOリストへリダイレクト
    * 失敗ならalert
    */
    signIn: function () {
      // 有効な入力ならログイン
      if (this.isValidInput()){
        this.$parent.setTokenAPI();
        axios.post('/users/sign_in', {user:
          {email: this.email,
          password: this.password}}
        ).then((response) => {
          this.$parent.updateTokenAPI(response.data.csrf_token);
          this.$router.push('/');
        }, (error) => {
          alert("IDまたはパスワードが違います。");
        });
      }
    },

    /**
    * isValidInput
    * メールアドレス、パスワード入力欄のチェック
    * 空であればエラーメッセージを表示
    *
    * @return エラーがあればfalse, なければtrue
    */
    isValidInput: function () {
      var valid_flag = true;
      // メールチェック
      if (this.email == "") {
        $('#email-err-msg').show();
        valid_flag = false;
      } else {
        $('#email-err-msg').hide();
      }
      // パスワードチェック
      if (this.password == "") {
        $('#password-err-msg').show();
        valid_flag = false;
      } else {
        $('#password-err-msg').hide();
      }
      return valid_flag;
    }
  }
}
</script>
<style src="./css/common.css"></style>
