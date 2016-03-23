class PhysattrsController < ApplicationController
  def index
    @physattrs = Physattr.all
  end

  def show
    @physattr = Physattr.find(params[:id])
  end

  def new
    @physattr = Physattr.new
  end

  def edit
    @physattr = Physattr.find(params[:id])
  end

  def create
    @physattr = Physattr.new(physattr_params)
    if @physattr.save
      redirect_to @physattr
    else
      render 'new'
    end
  end

  def update
    @physattr = Physattr.find(params[:id])
    if @physattr.update(physattr_params)
      redirect_to @physattr
    else
      render 'edit'
    end
  end

  def destroy
    @physattr = Physattr.find(params[:id])
    @physattr.destroy
    redirect_to physattrs_path
  end

  private
    def physattr_params
      params.require(:physattr).permit(:name, :summary, :hidden)
    end
end
