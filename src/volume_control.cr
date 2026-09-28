require "kemal"

get "/" do
  render "public/index.html"
end

post "/command" do |env|
  command = env.params.json["command"].as(String)

  if exec_command(command)
    File.tempfile("control-volume-web-app") do |file|
      file.puts "ok, command: #{command}"
    end
  else
    env.response.status_code = 400
    File.tempfile("control-volume-web-app") do |file|
      file.puts "fail, command: #{command}"
    end

  end
end

def exec_command(command : String) : Bool
  args = case command
         when "volume-up"   then ["set-sink-volume", "@DEFAULT_SINK@", "+5%"]
         when "volume-down" then ["set-sink-volume", "@DEFAULT_SINK@", "-5%"]
         when "mute"        then ["set-sink-mute", "@DEFAULT_SINK@", "toggle"]
         end

  return false unless args

  Process.run("pactl", args: args, output: STDOUT, error: STDERR).success?
end

Kemal.config.port = 9999
Kemal.run
