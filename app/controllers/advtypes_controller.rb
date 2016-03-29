class AdvtypesController < ApplicationController
  def index
    @advtypes = Advtype.all
  end

  def show
    @advtype = Advtype.find(params[:id])
  end

  def new
    @advtype = Advtype.new
    @advtype.name = "New Base Class"
    @advtype.save
    render 'edit'
  end

  def edit
    @advtype = Advtype.find(params[:id])
  end

  def create
    @advtype = Advtype.new(advtype_params)
    if @advtype.save
      redirect_to @advtype
    else
      render 'edit'
    end
  end

  def update
    @advtype = Advtype.find(params[:id])

    if @advtype.update(advtype_params)
      redirect_to @advtype
    else
      render 'edit'
    end
  end

  def destroy
    @advtype = Advtype.find(params[:id])
    @advtype.destroy
    redirect_to advtypes_path
  end

  private
    def advtype_params
      params.require(:advtype).permit(:name, :summary, :usualRoles)
    end
end
