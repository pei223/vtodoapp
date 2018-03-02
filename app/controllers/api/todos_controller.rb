class Api::TodosController < ApplicationController
  before_action :set_todo, only: [:show, :edit, :update, :destroy, :change_finish]
  # 処理実行するには認証を必須にする
  before_action :authenticate_user!

  # GET /todos
  # GET /todos.json
  def index
    @todos = Todo.where(user_id: current_user.id). where(finish: false).offset(0).limit(PAGE_DISP_NUM).order("deadline DESC")
  end

  # GET /todos/search
  def search
    @todos = Todo.search_todo(params, current_user.id, PAGE_DISP_NUM)
  end

  # POST /todos
  # POST /todos.json
  def create
    # バリデーション
    if is_valid_todo(todo_params)
      @todo = Todo.new(todo_params)
      @todo.user_id = current_user.id

      respond_to do |format|
        if @todo.save
          #format.html { redirect_to @todo, notice: 'Todo was successfully created.' }
          #format.json { render :show, status: :created, location: @todo }
          format.json { render json: @todo, status: :created}
        else
          #format.html { render :new }
          format.json { render json: @todo.errors, status: :unprocessable_entity }
        end
      end
    else
      format.json {render json: "validation_error", status: :error}
    end
  end

  # PATCH/PUT /todos/1
  # PATCH/PUT /todos/1.json
  def update
    todo_params[:user_id] = current_user.id
    todo_params[:updated_at] = Time.now
    if is_valid_todo(todo_params)
      respond_to do |format|
        if @todo.update(todo_params)
          #format.html { redirect_to @todo, notice: 'Todo was successfully updated.' }
          format.json { render json: @todo, status: :ok }
        else
          #format.html { render :edit }
          format.json { render json: @todo.errors, status: :unprocessable_entity }
        end
      end
    else
      format.json {render json: "validation_error", status: :error}
    end
  end

  # DELETE /todos/1
  # DELETE /todos/1.json
  def destroy
    @todo.destroy
    respond_to do |format|
      #format.html { redirect_to todos_url, notice: 'Todo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST  /todos/change_finish/id
  # 指定したtodoのfinishを変える
  def change_finish
    if @todo.finish
      @todo.finish = false
    else
      @todo.finish = true
    end
    if @todo.save
      render :json => @todo
    else
      render :json => {}, status: :error
    end
  end

  # GET /todos/max_page
  # 検索条件を指定した時の最大ページ数を取得
  def max_page
    todos =  Todo.search_todo(params, current_user.id, -1)
    if todos.nil?
      render json: {}, status: :bad_request
    else
      max_page_num = todos.count.quo(PAGE_DISP_NUM).ceil
      render json: {"max_page"=>max_page_num}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def todo_params
      params.require(:todo).permit(:title, :todo, :deadline, :finish, :updated_at)
    end

    # 入力エラーがあればfalse
    def is_valid_todo(params)
      # バリデーション
      is_valid = true
      if params[:title] == ""
        is_valid = false
      elsif params[:todo] == ""
        is_valid = false
      elsif params[:user_id] == ""
        is_valid = false
      end
      return is_valid
    end
end
