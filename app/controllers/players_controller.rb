class PlayersController < ApplicationController
  def index
    @players = Player.all
  end

  def show
    @player = Player.find(params[:id])
  end

  def new
    @player = Player.new_player "nonick"
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

  def add_level
    @player = Player.find(params[:id])
    render 'add_level'
  end

  private
    def player_params
      params.require(:player).permit(:name, :nick, :race, :baseType, :backstory, :coin, :hp, :sp, :skillPoints, :classPoints, :attrPoints, :featPoints, plyrattrs_attributes: [:name, :base_value, :id], plyrskills_attributes: [:name, :base_value, :id])
    end
end
