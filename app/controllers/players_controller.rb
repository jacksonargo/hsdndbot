class PlayersController < ApplicationController
  def index
    @players = Player.all
  end

  def show
    @player = Player.find(params[:id])
  end

  def new
    @player = Player.new
    @player.name = "New Player"
    @player.save
    render 'edit'
  end

  def edit
    @player = Player.find(params[:id])
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to @player
    else
      render 'new'
    end
  end

  def update
    @player = Player.find(params[:id])
    if @player.update(player_params)
      redirect_to @player
    else
      render 'edit'
    end
  end

  def destroy
    @player = Player.find(params[:id])
    @player.destroy
    redirect_to players_path
  end

  private
    def player_params
      params.require(:player).permit(:name, :nick, :coin, :hp, :sp, :skillPoints, :classPoints, :attrPoints, :featPoints, plyrattrs_attributes: [:name, :value, :id], plyrskills_attributes: [:name, :value, :id])
    end
end
