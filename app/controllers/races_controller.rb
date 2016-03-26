class RacesController < ApplicationController

  def index
    @races = Race.all
  end

  def show
    @race = Race.find(params[:id])
  end

  def new
    @race = Race.new
    @race.name = "New Race"
    @race.save
    render 'edit'
  end

  def edit
    @race = Race.find(params[:id])
  end

  def create
    @race = Race.new(race_params)
    if @race.save
      redirect_to @race
    else
      render 'new'
    end
  end

  def update
    @race = Race.find(params[:id])

    # Update the race name
    if @race.update(race_params)
      redirect_to @race
    else
      render 'edit'
    end

    # Make any updates to the raceattrs
    ###
  end

  def destroy
    @race = Race.find(params[:id])
    @race.destroy
    redirect_to races_path
  end

  private
    def race_params
      params.require(:race).permit(:name, raceattrs_attributes: [:name, :value, :id])
    end
end
