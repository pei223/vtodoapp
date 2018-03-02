<template>
  <div class="container">
    <navbar v-bind="{setTokenAPI, updateTokenAPI}"></navbar>
    <h2 class="title">ユーザー情報編集</h2>
    <form>
      <!-- メールアドレス -->
      <h5 class="subtitle">メールアドレス変更</h5>
      <div class="form-group">
        <p class="error-msg" id="email-error-msg"></p>
        <label for="email">メールアドレス</label>
        <input type="text" v-model="email" id="email" class="form-control"/>
      </div>
      <br />
      <!-- パスワード変更 -->
      <h5 class="subtitle">パスワード変更</h5>
      <div class="form-group">
        <p class="error-msg" id="password-error-msg"></p>
        <label for="password">パスワード</label>
        <input type="password" v-model="password" id="password" class="form-control"/>
      </div>
      <!-- パスワード変更の再入力 -->
      <div class="form-group">
        <p class="error-msg" id="password_confirmation-error-msg"></p>
        <label for="password_confirmation">パスワード再入力</label>
        <input type="password" v-model="password_confirmation" id="password_confirmation" class="form-control"/>
      </div>
      <p style="padding-bottom: 50px"></p>
      <!-- 現在のパスワード -->
      <h5 class="subtitle">変更には現在のパスワードが必要です</h5>
      <div class="form-group">
        <p class="error-msg" id="current_password-error-msg"></p>
        <label for="current_password">パスワード再入力</label>
        <input type="password" v-model="current_password" id="current_password" class="form-control"/>
      </div>
      <!-- 更新と削除ボタン -->
      <div class="form-group">
        <button type="button" class="btn btn-primary col-sm-12 col-xs-12 col-md-6 col-lg-6 col-md-offset-3 col-lg-offset-3" @click="updateUser()">更新する</button>
        <p style="padding-bottom: 80px;"></p>
        <button type="button" class="btn btn-danger col-sm-12 col-xs-12 col-md-6 col-lg-6 col-md-offset-3 col-lg-offset-3" @click="deleteUser()">アカウントを削除する</button>
      </div>
    </form>
  </div>
</template>
<script>
import axios from 'axios';
import Header from './templates/sign_in_header.vue'

export default {
  data: function () {
    return {
      email: '',
      password: '',
      password_confirmation: '',
      current_password: ''
    }
  },
  components: {
    "navbar": Header
  },
  mounted: function () {
    this.getUserData();
  },
  methods: {
    /**
    * updateUser
    * ユーザー情報の更新
    * 入力に不備があればエラーメッセージ表示
    * 成功したらログイン画面にリダイレクト
    */
    updateUser: function () {
      // 入力欄チェック
      if (this.isValidInput()){
        this.$parent.setTokenAPI();
        axios.put("/users", {user:
          {email: this.email,
            password: this.password,
            password_confirmation: this.password_confirmation,
            current_password: this.current_password
          }
        }).then((response) => {
          this.$parent.updateTokenAPI(response.data.csrf_token);
          alert("ユーザー情報の更新に成功しました。再度ログインしてください。");
          this.$router.push('/sign_in');
        },
        // 失敗時はエラーメッセージを入力欄の上に表示
        (error) => {
          this.setErrorMessage(error.response.data.error_types);
          console.log(error.response);
        });
      }
    },

    /**
    * getUserData
    * 現在のユーザーデータを取得し、this.dataに適用する
    * 現在はメールアドレスのみ
    */
    getUserData: function () {
      this.$parent.setTokenAPI();
      axios.get("/users/data", {}).then((response) => {
        this.email = response.data.email;
      }, (errors) => {
        console.log(errors.response);
      });
    },

    /**
    * deleteUser
    * ユーザー削除
    * 成功したらログイン画面にリダイレクト
    */
    deleteUser: function () {
      // 確認ダイアログ表示してOKなら削除
      if(window.confirm('全てのTODOとアカウントを削除します。よろしいですか？')){
        this.$parent.setTokenAPI();
        axios.delete("/users", {}).then((response) => {
          alert("アカウントを削除しました。TODO一覧に移動します。");
          this.$parent.updateTokenAPI(response.csrf_token);
          this.$router.push('/');
        }, (errors) => {
          alert("アカウント削除に失敗しました。");
          console.log(errors.response);
        });
      } else {
        alert("削除を取り消しました。");
      }
    },

    /**
    * isValidInput
    * 入力欄が空白かどうかチェックする
    * 空白ならその欄にエラーメッセージを表示
    *
    * @return 不備があればfalse、なければtrueを返す
    */
    isValidInput: function () {
      var valid_flag = true;
      // 現在のパスワードの入力チェック
      if (this.current_password == "") {
        $("#current_password-error-msg").text("現在のパスワードを入力してください。");
        $("#current_password-error-msg").show();
        valid_flag = false;
      } else {
        $("#current_password-error-msg").hide();
      }
      // メール、パスワードどちらかに入力があるかチェック
      if (this.email == "" && this.password == "") {
        $("#email-error-msg").text("変更したいメールアドレスかパスワードを入力してください。");
        $("#email-error-msg").show();
        valid_flag = false;
      } else {
        $("#email-error-msg").hide();
      }
      // パスワード変更チェック
      if (this.password != "") {
        // パスワード再入力がない
        if (this.password_confirmation == "") {
          $("#password_confirmation-error-msg").text("パスワードを再入力してください。");
          $("#password_confirmation-error-msg").show();
          valid_flag = false;
        }
        // パスワードと再入力が一致しない
        else if (this.password != this.password_confirmation) {
          $("#password_confirmation-error-msg").text("パスワードが一致しません。");
          $("#password_confirmation-error-msg").show();
          valid_flag = false;
          console.log("hogehogehoge");
        } else {
          $("#password_confirmation-error-msg").hide();
        }
      }
      return valid_flag;
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
        $("#email-error-msg").text("メールアドレスが不適切です。");
        $("#email-error-msg").show();
      }
      // すでに使われているメールアドレス
      else if (error_types.indexOf("used_email") >= 0) {
        $("#email-error-msg").text("すでに使用されているメールアドレスです。");
        $("#email-error-msg").show();
      }else {
        $("#email-error-msg").hide();
      }
      // パスワードが不適切
      if (error_types.indexOf("password") >= 0) {
        $("#password-error-msg").text("パスワードは6〜30文字にしてください。");
        $("#password-error-msg").show();
        this.password = "";
        this.password_confirmation = "";
      } else {
        $("#password-error-msg").hide();
      }
      // パスワード再入力が不適切
      if (error_types.indexOf("password_confirmation") >= 0) {
        $("#password_confirmation-error-msg").text("パスワードが一致しません。");
        $("#password_confirmation-error-msg").show();
        this.password = "";
        this.password_confirmation = "";
      } else {
        $("#password_confirmation-error-msg").hide();
      }
      // 現在のパスワードが不適切
      if (error_types.indexOf("current_password") >= 0) {
        $("#current_password-error-msg").text("パスワードが一致しません。");
        $("#current_password-error-msg").show();
        this.current_password = "";
      } else {
        $("#current_password-error-msg").hide();
      }
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
  }
}
</script>
<style src="./css/common.css"></style>
