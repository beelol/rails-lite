require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "already_built_response" if @already_built_response

    @res["Location"] = url
    @res.status = 302

    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "already_built_response" if @already_built_response
    @res["Content-Type"] = content_type
    @res.body = [content]
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    current_path = File.dirname(__FILE__) + '/..'

    path = current_path + '/' + get_template_path(template_name)

    content = File.read(path)

    erb = ERB.new(content).result(binding)

    render_content(erb, 'text/html')
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end

  private
  def get_template_path(template_name)
    "views/#{self.class.name.underscore}/#{template_name}.html.erb"
  end
end
