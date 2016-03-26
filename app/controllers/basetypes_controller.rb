class BasetypesController < ApplicationController
  def index
    @basetypes = Basetype.all
  end

  def show
    @basetype = Basetype.find(params[:id])
  end

  def new
    @basetype = Basetype.new
    @basetype.name = "New Base Class"
    render 'edit'
  end

  def edit
    @basetype = Basetype.find(params[:id])
  end

  def create
    @basetype = Basetype.new(basetype_params)
    if @basetype.save
      redirect_to @basetype
    else
      render 'edit'
    end
  end

  def update
    @basetype = Basetype.find(params[:id])

    if @basetype.update(basetype_params)
      redirect_to @basetype
    else
      render 'edit'
    end
  end

  def destroy
    @basetype = Basetype.find(params[:id])
    @basetype.destroy
    redirect_to basetypes_path
  end

  private
    def basetype_params
      params.require(:basetype).permit(:name, typeattrs_attributes: [:name, :value, :id])
    end
end
