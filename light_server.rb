require "webrick"
# A super light wrapper around webrick
class LightServer

  attr_accessor :token
  def initialize port = 1234
    @server = WEBrick::HTTPServer.new :Port => port
    @token = nil
    trap('INT') { @server.shutdown }
  end

  def start
    @server.start
  end

  def get path, &proc
    serve_with_method "GET", false, path, &proc
  end

  def post path, &proc
    serve_with_method "POST", false, path, &proc
  end

  def get_with_auth path, &proc
    serve_with_method "GET", true, path, &proc
  end

  def post_with_auth path, &proc
    serve_with_method "POST", true, path, &proc
  end

  def serve_with_method method, authenticate, path, &proc
    path_without_params = remove_params_from_path(path)
    @server.mount_proc path_without_params do |request, response|
      if !authenticate || (authenticate && request.header["authorization"] && request.header["authorization"][0] == @token)
        if request.request_method == method
          params = parse_query_params(request.query_string)

          # params passed from urls like /user/:user_id.
          # they are set as strings, not symbols.
          params_from_url = parse_params_from_url(path, request.path)
          params_from_url.each { |k, v| params[k] = v }

          # post params
          request.query.each { |k, v| params[k] = v }
          resp = proc.call(params, request, response)
          response.body = resp
        else
          response.body = "no handler for #{request.request_method}"
        end
      else
        response.body = "invalid authentication"
      end
    end
  end

  def parse_params_from_url path, request_path
    return {} unless path.include?(":")
    path_sections = path.split("/")
    request_path_sections = request_path.split("/")
    params = {}
    path_sections.each_with_index do |section, i|
      if section[0] == ":"
        section = section[1, section.size]
        params[section] = request_path_sections[i]
      end
    end
    params
  end

  def remove_params_from_path path
    path.split("/").reject { |s| s[0] == ":" }.join("/")
  end

  def parse_query_params query_string
    return {} unless query_string
    pairs = query_string.split("&")
    params = {}
    pairs.each do |pair|
      key, value = pair.split("=")
      params[key] = value
    end
    params
  end

  def shutdown
    @server.shutdown
  end
end
