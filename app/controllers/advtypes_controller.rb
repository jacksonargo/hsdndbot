class AdvtypesController < ApplicationController
  before_action :set_advtype, only: [:show, :edit, :update, :destroy]

  # GET /advtypes
  # GET /advtypes.json
  def index
    @advtypes = Advtype.all
  end

  # GET /advtypes/1
  # GET /advtypes/1.json
  def show
  end

  # GET /advtypes/new
  def new
    @advtype = Advtype.new
  end

  # GET /advtypes/1/edit
  def edit
  end

  # POST /advtypes
  # POST /advtypes.json
  def create
    @advtype = Advtype.new(advtype_params)

    respond_to do |format|
      if @advtype.save
        format.html { redirect_to @advtype, notice: 'Advtype was successfully created.' }
        format.json { render :show, status: :created, location: @advtype }
      else
        format.html { render :new }
        format.json { render json: @advtype.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /advtypes/1
  # PATCH/PUT /advtypes/1.json
  def update
    respond_to do |format|
      if @advtype.update(advtype_params)
        format.html { redirect_to @advtype, notice: 'Advtype was successfully updated.' }
        format.json { render :show, status: :ok, location: @advtype }
      else
        format.html { render :edit }
        format.json { render json: @advtype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /advtypes/1
  # DELETE /advtypes/1.json
  def destroy
    @advtype.destroy
    respond_to do |format|
      format.html { redirect_to advtypes_url, notice: 'Advtype was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_advtype
      @advtype = Advtype.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def advtype_params
      params.fetch(:advtype, {})
    end
end
