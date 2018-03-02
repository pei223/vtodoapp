<template>
  <div class="navbar-fixed-top">
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
          <li><router-link :to="{ path: '/sign_in' }">ログイン</router-link></li>
          <li><router-link :to="{ path: '/sign_up' }">ユーザー登録</router-link></li>
        </ul>
      </div>
    </nav>
  </div>
</template>
<script src="../js/common.js"></script>
<style src="../css/common.css"></style>
