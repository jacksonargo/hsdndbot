class AdvtypesController < ApplicationController
  def index
    @advtypes = Advtype.all
  end

  def show
    @advtype = Advtype.find(params[:id])
  end

  def new
    permission_denied unless current_user.admin
    @advtype = Advtype.new
    @advtype.name = "New Base Class"
    @advtype.save
    render 'edit'
  end

  def edit
    permission_denied unless current_user.admin
    @advtype = Advtype.find(params[:id])
  end

  def create
    permission_denied unless current_user.admin
    @advtype = Advtype.new(advtype_params)
    if @advtype.save
      redirect_to @advtype
    else
      render 'edit'
    end
  end

  def update
    permission_denied unless current_user.admin
    @advtype = Advtype.find(params[:id])

    if @advtype.update(advtype_params)
      redirect_to @advtype
    else
      render 'edit'
    end
  end

  def destroy
    permission_denied unless current_user.admin
    @advtype = Advtype.find(params[:id])
    @advtype.destroy
    redirect_to advtypes_path
  end

  private
    def advtype_params
      params.require(:advtype).permit(:name, :summary, :usualRoles)
    end
end
