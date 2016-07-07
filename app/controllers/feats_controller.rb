class FeatsController < ApplicationController


  def index
    @feats = Feat.all
  end

  def show
    @feat = Feat.find(params[:id])
  end

  def new
    permission_denied unless current_user.admin
    @feat = Feat.new
    @feat.name = "New Feat"
    @feat.save
    render 'edit'
  end

  def edit
    permission_denied unless current_user.admin
    @feat = Feat.find(params[:id])
  end

  def create
    permission_denied unless current_user.admin
    @feat = Feat.new(feat_params)
    if @feat.save
      redirect_to @feat
    else
      render 'new'
    end
  end

  def update
    permission_denied unless current_user.admin
    @feat = Feat.find(params[:id])

    # Update the feat name
    if @feat.update(feat_params)
      redirect_to @feat
    else
      render 'edit'
    end

    # Make any updates to the featattrs
    ###
  end

  def destroy
    permission_denied unless current_user.admin
    @feat = Feat.find(params[:id])
    @feat.destroy
    redirect_to feats_path
  end

  private
    def feat_params
      params.require(:feat).permit(:name, :type, :uses, :perk, featattrs_attributes: [:name, :value, :id])
    end
end
