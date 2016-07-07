class PhysattrsController < ApplicationController
  def index
    @physattrs = Physattr.all
  end

  def show
    @physattr = Physattr.find(params[:id])
  end

  def new
    permission_denied unless current_user.admin
    @physattr = Physattr.new
  end

  def edit
    permission_denied unless current_user.admin
    @physattr = Physattr.find(params[:id])
  end

  def create
    permission_denied unless current_user.admin
    @physattr = Physattr.new(physattr_params)
    if @physattr.save
      redirect_to @physattr
    else
      render 'new'
    end
  end

  def update
    permission_denied unless current_user.admin
    @physattr = Physattr.find(params[:id])
    if @physattr.update(physattr_params)
      redirect_to @physattr
    else
      render 'edit'
    end
  end

  def destroy
    permission_denied unless current_user.admin
    @physattr = Physattr.find(params[:id])
    @physattr.destroy
    redirect_to physattrs_path
  end

  private
    def physattr_params
      params.require(:physattr).permit(:name, :summary, :hidden)
    end
end
