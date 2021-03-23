class ScoresController < ApplicationController

  def index
    @scores = Score.all.order(id: :desc)
  end

end
