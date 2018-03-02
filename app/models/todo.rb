class Todo < ApplicationRecord
  # user_idはUserの外部キーとする
  belongs_to :user, :class_name=>'User', :foreign_key => 'user_id'

  # 検索条件を使ってデータを取得する
  # @param params
  # @param page_disp_num 取得するデータ数(-1なら全て)
  # @return エラーが起きたらnilを返す
  def self.search_todo(params, user_id, page_disp_num)
    # ページング処理
    if params[:page].present?
      offset = (params[:page].to_i - 1) * page_disp_num
    else
      offset = 0
    end
    err_flag = 0
    order_sql = ""
    sql_array = []
    where_hash = {}
    # 文字列検索
    if params[:search_word].present? && params[:search_target].present?
      if params[:search_target] == "both"
        sql_array.push("title LIKE :search_word OR todo LIKE :search_word")
      elsif params[:search_target] == "title"
        sql_array.push("title LIKE :search_word")
      elsif params[:search_target] == "todo"
        sql_array.push("todo LIKE :search_word")
      end
      where_hash[:search_word] = params[:search_word]
    end
    # todoが完了したか検索
    if params[:todo_condition].present?
      if params[:todo_condition] != "both"
        sql_array.push("finish = :is_finished")
        if params[:todo_condition] == "true"
          where_hash[:is_finished] = true
        elsif params[:todo_condition] == "false"
          where_hash[:is_finished] = false
        else
          err_flag = 1
        end
      end
    # 指定がないならエラー
    else
      err_flag = 1
    end
    # 並び替えの指定
    # 並び替え対象の列、順序が指定されていなければエラー
    if !params[:order].present? || !params[:sorting_way].present?
      err_flag = 1
    else
      if params[:sorting_way] == "deadline" || params[:sorting_way] == "created_at" || params[:sorting_way] == "updated_at"
        order_sql += params[:sorting_way] + " "
      else
        err_flag = 1
      end
      if params[:order] == "ASC" || params[:order] == "DESC"
        order_sql += params[:order]
      else
        err_flag = 1
      end
    end

    if err_flag == 1
      return nil
    elsif where_hash.empty?
      # ページングあり
      if page_disp_num == -1
        return Todo.where(user_id: user_id).offset(offset).order(order_sql)
      # 全データ取得
      else
        return Todo.where(user_id: user_id).offset(offset).limit(page_disp_num).order(order_sql)
      end
    else
      # ページングあり
      if page_disp_num == -1
        return Todo.where(user_id: user_id).where([sql_array.join(" AND "), where_hash]).offset(offset).order(order_sql)
      # 全データ取得
      else
        return Todo.where(user_id: user_id).where([sql_array.join(" AND "), where_hash]).offset(offset).limit(page_disp_num).order(order_sql)
      end
    end

  end
end
