class PlayersController < ApplicationController
  def index
    @players = Player.all
  end

  def show
    @player = Player.find(params[:id])
  end

  def new
    permission_denied unless current_user.admin
    @player = Player.new
  end

  def edit
    permission_denied unless current_user.admin
    @player = Player.find(params[:id])
  end

  def create
    permission_denied unless current_user.admin
    @player = Player.new(player_params)
    if @player.save
      redirect_to @player
    else
      render 'new'
    end
  end

  def update
    permission_denied unless current_user.admin
    @player = Player.find(params[:id])
    if @player.update(player_params)
      redirect_to @player
    else
      render 'edit'
    end
  end

  def destroy
    permission_denied unless current_user.admin
    @player = Player.find(params[:id])
    @player.destroy
    redirect_to players_path
  end

  def add_level
    permission_denied unless current_user.admin
    @player = Player.find(params[:id])
    render 'add_level'
  end

  private
    def player_params
      params.require(:player).permit(:name, :nick, :race, :baseType, :backstory, :coin, :hp, :sp, :skillPoints, :classPoints, :attrPoints, :featPoints, plyrattrs_attributes: [:name, :base_value, :id], plyrskills_attributes: [:name, :base_value, :id])
    end
end
