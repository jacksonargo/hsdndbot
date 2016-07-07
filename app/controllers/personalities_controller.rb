class PersonalitiesController < ApplicationController
  def index
    @personalitys = Personality.all
  end

  def show
    @personality = Personality.find(params[:id])
  end

  def new
    permission_denied unless current_user.admin
    @personality = Personality.new
  end

  def edit
    permission_denied unless current_user.admin
    @personality = Personality.find(params[:id])
  end

  def create
    permission_denied unless current_user.admin
    @personality = Personality.new(personality_params)
    if @personality.save
      redirect_to @personality
    else
      render 'new'
    end
  end

  def update
    permission_denied unless current_user.admin
    @personality = Personality.find(params[:id])
    if @personality.update(personality_params)
      redirect_to @personality
    else
      render 'edit'
    end
  end

  def destroy
    permission_denied unless current_user.admin
    @personality = Personality.find(params[:id])
    @personality.destroy
    redirect_to personalities_path
  end

  private
    def personality_params
      params.require(:personality).permit(:name, personalityattrs_attributes: [:name, :value, :id])
    end
end
