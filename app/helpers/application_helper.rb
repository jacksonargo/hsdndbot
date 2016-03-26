module ApplicationHelper

  def navbar_dropdown(model, title=nil)
  @model = Kernel.const_get(model.capitalize)
  @controller_name = model.to_s.pluralize
  title ||= model.to_s.capitalize.pluralize
  @title = title
  render 'navbar_dropdown'
  end

  def index_title(title)
    link = link_to 'new', controller: controller_name, action: :new
    "<h1>#{title} <small>(#{link})</small></h1>".html_safe
  end

  def index_table(items)
    @items=items
    render 'index_table'
  end

  def show_title(model)
    link = link_to 'edit', controller: controller_name, action: :edit, id: model
    "<h1>#{model.name} <small>(#{link})</small></h1>".html_safe
  end

  def show_summary(model)
    "<div class=\"summary\">#{model.summary}</div>".html_safe
  end

  def show_physattr_list(model, physattrs_method)
    @model = model
    @physattrs_method = physattrs_method
    render 'show_physattr_list'
  end

  def show_edit_errors(model)
    @model = model
    render 'show_errors'
  end

  def edit_name (f)
    "<p>#{f.label :name}<br>#{f.text_field :name}</p>".html_safe
  end

  def edit_summary (f)
    "<p>#{f.label :summay}<br>#{f.text_area :summary, style: "width: 100%; height: 150px;"}</p>".html_safe
  end

  def edit_physattrs (f, model, physattr_method)
    @f = f
    @model = model
    @physattr_method = physattr_method
    render 'edit_physattrs'
  end
end
