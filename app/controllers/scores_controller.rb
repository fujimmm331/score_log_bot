class ScoresController < ApplicationController
  before_action :find_score, only: [:edit, :update]
  def index
    @scores = Score.all.order(id: :desc)
  end

  def edit
    basic_auth
    @score = Score.find(params[:id])
  end

  def update
    if @score.update(score_params)
      redirect_to root_path, notice: '修正完了！'
    else
      flash.now[:alert] = "スコアは半角数字で入力してください。"
      render :edit
    end
  end

  private

  def find_score
    @score = Score.find(params[:id])
  end

  def score_params
    params.require(:score).permit(:franse_score, :germany_score, :pk_franse_score, :pk_germany_score)
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["SCORE_USER"] && password == ENV["SCORE_PASSWORD"]
    end
  end
end
