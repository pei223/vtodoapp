class User < ApplicationRecord
  # Userが削除されたら依存しているtodoを全て削除する
  has_many :todos, :dependent => :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
