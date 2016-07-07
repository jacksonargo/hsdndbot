class SkillsController < ApplicationController
  def index
    @skills = Skill.all
  end

  def show
    @skill = Skill.find(params[:id])
  end

  def new
    permission_denied unless current_user.admin
    @skill = Skill.new
  end

  def edit
    permission_denied unless current_user.admin
    @skill = Skill.find(params[:id])
  end

  def create
    permission_denied unless current_user.admin
    @skill = Skill.new(skill_params)
    if @skill.save
      redirect_to @skill
    else
      render 'new'
    end
  end

  def update
    permission_denied unless current_user.admin
    @skill = Skill.find(params[:id])
    if @skill.update(skill_params)
      redirect_to @skill
    else
      render 'edit'
    end
  end

  def destroy
    permission_denied unless current_user.admin
    @skill = Skill.find(params[:id])
    @skill.destroy
    redirect_to skills_path
  end

  private
    def skill_params
      params.require(:skill).permit(:name, :summary, :attribute)
    end
end
