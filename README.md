# light_server

For when you need sinatra-like functionality but don't want to add another gem to your project.

Features:
- copy-paste this file into your project
- provides basic sinatra functionality in < 100 lines
- easy to read/modify code

## Example

```ruby
require_relative "light_server"
@server = LightServer.new

@server.get "/" do
  "hello world!"
end

@server.get "/user/:user_id" do |params|
  "getting user with id #{params["user_id"]}"
end

@server.post "/a_url" do |params|
  "you called this using a post"
end

@server.start
```
