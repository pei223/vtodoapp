# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # GET /resource/data
  # ログイン中のユーザーデータを取得
  def data
    if user_signed_in?
      render :json => {
        'email' => current_user.email
      }, status: 200
      return
    else
      render :json => {
        'message' => 'not signed_in'
      }, status: 400
      return
    end
  end

  # POST /resource
  def create
    super do
      error_types = []
      err_flag = false
       # Emailエラー
      if @user.errors[:email].present?
        err_flag = true
        # すでに使用されているメールアドレス
        if @user.errors[:email].include?("has already been taken")
          error_types.push('used_email')
        else
          error_types.push('email')
        end
      end
      # passwordエラー
      if @user.errors[:password].present?
        err_flag = true
        error_types.push('password')
      end
      # password再確認エラー
      if @user.errors[:password_confirmation].present?
        err_flag = true
        error_types.push('password_confirmation')
      end
      # 登録失敗時
      if err_flag
        render :json => {
          'error_types' => error_types
        }, status: 400
        return
      # 登録成功時
      else
        render :json => {
          'csrf_token' => form_authenticity_token,
          'user' => {
            'id' => @user.id,
            'email' => @user.email
          }
        }, status: 200
        return
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    super do
      error_types = []
      err_flag = false
      # 現在のpasswordエラー
      if @user.errors[:current_password].present?
        err_flag = true
        error_types.push('current_password')
      end
      # Emailエラー
      if @user.errors[:email].present?
        err_flag = true
        # すでに使用されているメールアドレス
        if @user.errors[:email].include?("has already been taken")
          error_types.push('used_email')
        else
          error_types.push('email')
        end
      end
      # password変更エラー
      if @user.errors[:password].present?
        err_flag = true
        error_types.push('password')
      end
      # password再確認エラー
      if @user.errors[:password_confirmation].present?
        err_flag = true
        error_types.push('password_confirmation')
      end

      if err_flag
        render :json => {
          'error_types' => error_types
        }, status: 400
      else
        render :json => {
          'csrf_token' => form_authenticity_token
        }, status: 200
      end
      return
    end
  end

  # DELETE /resource
  def destroy
    super do
      render :json => {
        'csrf_token' => form_authenticity_token
      }, status: 200
      return
    end
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
