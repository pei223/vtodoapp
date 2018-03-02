<template>
  <div class="paging">
    <span>
      <!-- 最初のページにジャンプ -->
      <a href="javascript: void(0)" @click="jumpPage(1)" class="jump_page">&lt;&lt;&nbsp;</a>
    </span>
    <!-- 飛べるページ一覧 -->
    <span v-for="(page_num) in page_list">
      &nbsp;&nbsp;
      <a v-if="page_num == $parent.page" href="javascript: void(0)" @click="jumpPage(page_num)" class="current_page">{{ page_num }}</a>
      <a v-else href="javascript: void(0)" @click="jumpPage(page_num)" class="jump_page">{{ page_num }}</a>
    </span>
    &nbsp;&nbsp;
    <span>
      <!-- 最後のページにジャンプ -->
      <a href="javascript: void(0)" @click="jumpPage(max_page)" class="jump_page">&nbsp;&gt;&gt;</a>
    </span>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: ["setTokenAPI", "hideEditForm"],
  data: function () {
    return {
      page_list: [],  // ページングのリンク生成用の配列
      max_page: 1     // 最大のページ数
    }
  },
  mounted: function () {
    this.renewPaging();
  },
  methods: {
    /**
    * renewPaging
    * ページングのリンク生成用配列(this.page_list)を更新、再描画
    */
    renewPaging: function(){
      this.setTokenAPI();
      // 最大のページ数を取得
      axios.get("/api/todos/max_page", {params: {
          search_word: this.$parent.saved_search_word,
          search_target: this.$parent.saved_search_target,
          todo_condition: this.$parent.saved_todo_condition,
          sorting_way: this.$parent.saved_sorting_way,
          order: this.$parent.saved_order,
          page: 1
        }
        }).then((response) => {
        // ページリストの更新
        var disp_page_num = 5;
        this.page_list = [];
        this.max_page = response.data.max_page;
        for (var i = 1; i <= this.max_page; i++){
          if (Math.abs(i-this.$parent.page) <= Math.floor(disp_page_num/2)) {
            this.page_list.push(i);
          }
        }
      }, (error) => {
        alert("ページング配列更新失敗");
        console.log(error);
      });
    },

    /**
    * jumpPage
    * 現在の検索条件で指定したページにジャンプする
    * @param page_num: ページ番号
    */
    jumpPage: function(page_num){
      this.setTokenAPI();
      axios.get("/api/todos/search", {params: {
          search_word: this.$parent.saved_search_word,
          search_target: this.$parent.saved_search_target,
          todo_condition: this.$parent.saved_todo_condition,
          sorting_way: this.$parent.saved_sorting_way,
          order: this.$parent.saved_order,
          page: page_num}
      }).then((response) => {
        // todos更新前に削除しないと編集フォームが残ってしまうため
        this.hideEditForm();
        // todoを更新
        this.$parent.todos = [];
        for(var i = 0; i < response.data.todos.length; i++) {
          // simpleMDE関連の設定
          response.data.todos[i]["mde"] = null;
          response.data.todos[i]["mde_todo"] = marked(response.data.todos[i]["todo"]);
          this.$parent.todos.push(response.data.todos[i]);
        }
        // ページ関連の更新
        this.$parent.page = page_num;
        this.renewPaging();
      }, (error) => {
        alert("ページ移動失敗");
        console.log(error);
      });
    }
  }
}
</script>
<style scoped>
a.current_page{
  color: blue;
  text-decoration:none;
  font-size: 150%;
}
a.current_page:hover{
  background-color: #dcdcdc;
}

a.jump_page{
  color: black;
  text-decoration:none;
}
a.jump_page:hover{
  color: black;
  background-color: #dcdcdc;
}

.paging{
  padding-top: 10px;
  font-size: 15px;
  text-align: center;
}
</style>
