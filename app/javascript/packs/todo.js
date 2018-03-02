import Vue from 'vue/dist/vue.esm.js'
import Router from './components/router/router.js'
import axios from 'axios'

var app = new Vue({
  router: Router,
  el: '#app',
  mounted: function(){
    // momentjsの設定
    moment.locale('ja');
    moment.lang('ja', {weekdays: ["日","月","火","水","木","金","土"]});
  },
  methods: {
    /**
    * setTokenAPI
    * 認証用のトークンを設定
    */
    setTokenAPI: function() {
      let token = document.getElementsByName('csrf-token')[0].getAttribute('content');
      axios.defaults.headers.common['X-CSRF-Token'] = token;
      axios.defaults.headers.common['Accept'] = 'application/json';
    },
    /**
    * updateTokenAPI
    * 認証用のトークンを更新
    * @param token: 更新するトークンの値
    */
    updateTokenAPI: function(token){
      axios.defaults.headers.common['X-CSRF-Token'] = token;
      document.getElementsByName('csrf-token')[0].setAttribute('content', token);
    },
    /**
    * signInCheck
    * ログインチェックし、結果によってリダイレクト先を変える
    * @param signed_in_redirect2: ログイン時のリダイレクト先、空文字列ならリダイレクトなし
    * @param other_redirect2: 未ログイン時のリダイレクト先、空文字列ならリダイレクトなし
    */
    signInCheck: function(signed_in_redirect2, other_redirect2) {
      this.setTokenAPI();
      // ログインしてるか確認
      axios.get("/users/is_signed_in", {}).then((response) => {
        // ログイン時
        if (signed_in_redirect2 != "") {
          this.$router.push(signed_in_redirect2);
        }
      }, (error) => {
        // 未ログイン時
        if (other_redirect2 != "") {
          this.$router.push(other_redirect2);
        }
      });
    }
  }
},
);
