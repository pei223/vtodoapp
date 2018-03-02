<template>
<div class="navbar-fixed-top">
  <!-- 先頭に戻るボタン -->
  <button id="top_button" onclick="$(window).scrollTop(0);">
      <i class="fa fa-chevron-up" aria-hidden="true"></i>
    </button>
  <nav class="navbar navbar-default">
    <div class="navbar-header">
      <a class="navbar-brand text-muted" href="javascript: void(0)">MENU</a>
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#gnavi">
          <span class="sr-only">メニュー</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
    </div>

    <div id="gnavi" class="collapse navbar-collapse">
      <ul class="nav navbar-nav">
        <li>
          <router-link :to="{ path: '/' }">TODOリスト</router-link>
        </li>
        <li>
          <router-link :to="{ path: '/new' }">新規TODO</router-link>
        </li>
        <li>
          <router-link :to="{ path: '/user_edit' }">ユーザー情報</router-link>
        </li>
        <li><a href="javascript: void(0)" @click="signOut()">ログアウト</a></li>
      </ul>
    </div>
  </nav>
</div>
</template>
<script src="../js/common.js"></script>
<style src = "../css/common.css" ></style>
<script >
import axios from 'axios'

export default {
  props: ["setTokenAPI", "updateTokenAPI"],
  methods: {
    /**
    * signOut
    * ログアウトする。
    */
    signOut: function() {
      this.setTokenAPI();
      axios.delete('/users/sign_out').then((response) => {
        // トークン更新
        this.updateTokenAPI(response.data.csrf_token);
        this.$router.push('/sign_in');
      }, (error) => {
        console.log(error);
      });
    },
  }
}
</script>
