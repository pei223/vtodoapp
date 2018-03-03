<template>
  <div>
    <!-- 各種ボタン -->
    <div class="row">
      <div class="col-sm-12 col-xs-12 col-md-3 col-lg-3">
        <button type="button" class="btn btn-default" id="show_box" @click="showSearchbox()">検索ボックスを表示する</button>
        <button type="button" class="btn btn-default" id="hide_box" @click="hideSearchbox()">検索ボックスを隠す</button>
      </div>
      <div class="col-sm-12 col-xs-12 col-md-3 col-lg-3">
        <button type="button" class="btn btn-default" id="show_box" @click="clearSearch()">検索条件をクリアする</button>
      </div>
    </div>
    <br>
    <!-- 検索ボックス -->
    <div>
      <div class="searchbox row">
        <form>
          <!-- ワード検索 -->
          <div class="form-group row">
            <label for="search_word">ワード検索</label>
            <div class="col-sm-12 col-xs-12 col-md-9 col-lg-9">
              <input id="search_word" type="text" name="search_word" v-model="search_word" placeholder="検索するキーワード" class="form-control">
            </div>
            <div class="col-sm-10 col-xs-10 col-md-3 col-lg-3">
              <select v-model="search_target" class="form-control">
                <option value="title">タイトルを検索</option>
                <option value="todo">TODOを検索</option>
                <option value="both">両方を検索</option>
              </select>
            </div>
          </div>
          <br/>
          <!-- 表示するTODOの状態 -->
          <div class="form-group row">
            <label for="todo_condition">表示条件</label>
            <div class="col-sm-9 col-xs-9 col-md-6 col-lg-4">
              <select id="todo_condition" v-model="todo_condition" class="form-control">
                <option value="false">未完了のTODO</option>
                <option value="true">完了したTODO</option>
                <option value="both">全てのTODO</option>
              </select>
            </div>
          </div><br>
          <!-- 並べ替え -->
          <div class="form-group row">
            <label for="sorting_way">並び替え条件</label>
            <div class="col-sm-9 col-xs-9 col-md-4 col-lg-4">
              <select id="sorting_way" v-model="sorting_way" class="form-control col-xs-6">
                <option value="deadline">デッドラインが</option>
                <option value="updated_at">更新日時が</option>
                <option value="created_at">追加日時が</option>
              </select>
            </div>
            <div class="col-sm-6 col-xs-6 col-md-3 col-lg-3">
              <select id="order" v-model="order" class="form-control col-xs-3">
                <option value="DESC">近い順</option>
                <option value="ASC">遠い順</option>
              </select>
            </div>
          </div>
          <br>
          <!-- 検索ボタン -->
          <div class="row">
            <div class="form-group row col-sm-12 col-xs-12 col-md-6 col-lg-6 col-md-offset-3 col-lg-offset-3">
              <button type="button" class="btn btn-info form-control" @click="searchTodos()">指定条件で検索</button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
<script>
import axios from 'axios'

export default {
  props: ["setTokenAPI", "hideEditForm", "updateChildren"],
  data: function(){
    return {
      search_word: this.$parent.saved_search_word,
      search_target: this.$parent.saved_search_target,
      todo_condition: this.$parent.saved_todo_condition,
      sorting_way: this.$parent.saved_sorting_way,
      order: this.$parent.saved_order
    }
  },
  methods: {
    /**
    * searchTodos
    * 検索条件を指定してTODO検索
    * 検索に成功したら検索条件を保存する
    */
    searchTodos: function() {
      this.setTokenAPI();
      axios.get("/api/todos/search", {params: {
        search_word: this.search_word,
        search_target: this.search_target,
        todo_condition: this.todo_condition,
        sorting_way: this.sorting_way,
        order: this.order,
        page: 1
      }}).then((response) => {
        // todos更新前に削除しないと編集フォームが残ってしまうため
        this.hideEditForm();
        // 検索条件保存
        this.$parent.saved_search_word = this.search_word;
        this.$parent.saved_search_target = this.search_target;
        this.$parent.saved_todo_condition = this.todo_condition;
        this.$parent.saved_sorting_way = this.sorting_way;
        this.$parent.saved_order =  this.order;
        this.$parent.page = 1;
        // 配列更新
        this.$parent.todos = [];
        for(var i = 0; i < response.data.todos.length; i++) {
          // simpleMDE関連の設定
          response.data.todos[i]["mde"] = null;
          response.data.todos[i]["mde_todo"] = marked(response.data.todos[i]["todo"]);
          this.$parent.todos.push(response.data.todos[i]);
        }
        // 検索に伴って他のコンポーネントも更新する
        this.updateChildren();
      }, (error) => {
        console.log(error);
        alert("TODO検索に失敗しました。");
      }
    );
    },

    /**
    * showSearchbox
    * 検索ボックス表示
    */
    showSearchbox: function(){
      $('.searchbox').show('fast');
      $('#show_box').hide();
      $('#hide_box').show();
    },

    /**
    * hideSearchbox
    * 検索ボックスを隠す
    */
    hideSearchbox: function(){
      $('.searchbox').hide('fast');
      $('#show_box').show();
      $('#hide_box').hide();
    },

    /**
    * clearSearch
    * 検索条件の入力欄を初期化し、再度検索条件なしでTODOを更新する
    */
    clearSearch: function(){
      // 検索条件の初期化
      this.search_word = '';
      this.search_target = 'title';
      this.todo_condition = 'false';
      this.sorting_way = 'deadline';
      this.order = 'DESC';
      this.searchTodos();
    }
  }
}
</script>
<style scoped>
  .searchbox{
    display: none;
  }
  #hide_box{
    display: none;
  }
</style>
