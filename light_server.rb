require "webrick"
# A super light wrapper around webrick
class LightServer
  def initialize port = 1234
    @server = WEBrick::HTTPServer.new :Port => port
    trap('INT') { @server.shutdown }
  end

  def start
    @server.start
  end

  def get path, &proc
    path_without_params = remove_params_from_path(path)
    @server.mount_proc path_without_params do |request, response|
      params = parse_query_params(request.query_string)
      params_from_url = parse_params_from_url(path, request.path)
      params_from_url.each { |k, v| params[k] = v }
      resp = proc.call(params, request, response)
      response.body = resp
    end
  end

  def parse_params_from_url path, request_path
    p [path, request_path]
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
