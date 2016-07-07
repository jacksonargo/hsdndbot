class BasetypesController < ApplicationController
  def index
    @basetypes = Basetype.all
  end

  def show
    @basetype = Basetype.find(params[:id])
  end

  def new
    permission_denied unless current_user.admin
    @basetype = Basetype.new
    @basetype.name = "New Base Class"
    @basetype.save
    render 'edit'
  end

  def edit
    permission_denied unless current_user.admin
    @basetype = Basetype.find(params[:id])
  end

  def create
    permission_denied unless current_user.admin
    @basetype = Basetype.new(basetype_params)
    if @basetype.save
      redirect_to @basetype
    else
      render 'edit'
    end
  end

  def update
    permission_denied unless current_user.admin
    @basetype = Basetype.find(params[:id])

    if @basetype.update(basetype_params)
      redirect_to @basetype
    else
      render 'edit'
    end
  end

  def destroy
    permission_denied unless current_user.admin
    @basetype = Basetype.find(params[:id])
    @basetype.destroy
    redirect_to basetypes_path
  end

  private
    def basetype_params
      params.require(:basetype).permit(:name, :summary, :usualRoles, typeattrs_attributes: [:name, :value, :id])
    end
end
