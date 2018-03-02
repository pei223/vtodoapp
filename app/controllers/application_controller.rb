class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  PAGE_DISP_NUM = 3  # 1ページにいくつTODOを表示するか
end
