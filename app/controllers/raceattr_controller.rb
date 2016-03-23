class RaceattrController < ApplicationController
  def update
    @race = Race.find(params[:race_id])
    @raceattr = Race.find(params[:id])
    @raceattr.update raceattr_params
    redirect_to race_path(@race)
  end
 
  private
    def raceattr_params
      params.require(:raceattr).permit(:value)
    end
end
