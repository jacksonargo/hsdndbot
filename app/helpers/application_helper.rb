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

  def show_strong(model, method, name=nil)
    unless name
      name = method.to_s
      name = name.gsub(/([A-Z])/, " \\1")
      name = name.gsub(/_/, " ")
      name = name.capitalize
    end
    "<strong>#{name}:</strong> #{model.send(method)}".html_safe
  end

  def show_strong_list(model, methods=[])
    s = ""
    methods.each do |m|
      if m.class == Symbol or m.class == String
        s << "#{show_strong(model, m)}<br>\n"
      else
        method = m[:method]
        name = m[:name]
        s << "#{show_strong(model, method, name)}<br>\n"
      end
    end
    s.html_safe
  end

  def show_title(model, opts={})
    opts[:name]          ||= :name
    opts[:prepend_title] ||= ""
    opts[:show_edit]     = true if opts[:show_edit] == nil
    opts[:show_delete]   = true if opts[:show_delete] == nil

    title = "#{opts[:prepend_title]}#{model.send(opts[:name])}"
    ledi = link_to 'edit', controller: controller_name, action: :edit, id: model
    ldel = link_to 'delete', model, method: :delete, data: { confirm: 'Are you sure?' }

    links = ""
    links += "(#{ledi}) " if opts[:show_edit]
    links += "(#{ldel}) " if opts[:show_delete]
    "<h1>#{title} <small>#{links}</small></h1>".html_safe
  end

  def show_summary(model, summary = :summary)
    "<div class=\"summary\">#{model.send(summary)}</div>".html_safe
  end

  def show_perk(model)
    "<div class=\"summary\">#{model.perk}</div>".html_safe
  end

  def show_physattr_list(model, physattrs_method, opts={})
    opts[:value]       ||= :value
    opts[:show_zero]   ||= false 
    opts[:show_hidden] = true if opts[:show_hidden] == nil

    @model = model
    @physattrs_method = physattrs_method
    @value = opts[:value]
    @show_hidden = opts[:show_hidden]
    @show_zero = opts[:show_zero]

    render 'show_physattr_list'
  end

  def show_collection_list(model, collection, opts={})
    opts[:value]       ||= :value
    opts[:show_zero]   ||= false 
    opts[:title]       ||= collection.to_s.capitalize
    opts[:show_hidden] = true if opts[:show_hidden] == nil

    @model = model
    @method = collection
    @opts = opts

    render 'show_collection_list'
  end

  def show_edit_errors(model)
    @model = model
    render 'show_errors'
  end

  def edit_name (f)
    "<p>#{f.label :name}<br>#{f.text_field :name}</p>".html_safe
  end

  def edit_summary (f, summary = :summary)
    "<p>#{f.label summary}<br>#{f.text_area summary, style: "width: 100%; height: 150px;"}</p>".html_safe
  end

  def edit_perk (f)
    "<p>#{f.label :perk}<br>#{f.text_area :perk, style: "width: 100%; height: 150px;"}</p>".html_safe
  end

  def edit_string (f, method, name=nil)
    unless name
      name = method.to_s
      name = name.gsub(/([A-Z])/, " \\1")
      name = name.gsub(/_/, " ")
    end
    label = f.label name
    field = f.text_field method
    "<p>#{label}<br>#{field}</p>".html_safe
  end

  def edit_string_list (f, methods=[])
    s = ""
    methods.each do |m|
      if m.class == Symbol or m.class == String
        s << "#{edit_string(f, m)}\n"
      else
        method = m[:method]
        name = m[:name]
        s << "#{edit_string(f, method, name)}\n"
      end
    end
    s.html_safe
  end

  def edit_physattrs (f, model, physattr_method, opts={})
    opts[:title] ||= "Attributes"
    opts[:value] ||= :value

    @f = f
    @model = model
    @physattr_method = physattr_method
    @opts = opts
    render 'edit_physattrs'
  end

  def edit_collection (f, model, method, collection, get_instance, opts={})
    opts[:title] ||= method.to_s.capitalize
    opts[:value] ||= :value

    @f = f
    @model = model
    @method = method
    @collection = collection
    @get_instance = get_instance
    @opts = opts
    render 'edit_collection'
  end
end
