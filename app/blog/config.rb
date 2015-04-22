require 'sinatra/base'
require 'tilt/erb'
require 'sequel'

$LOAD_PATH.unshift File.dirname(__FILE__), "..", ".."

class Blog < Sinatra::Base
  @@db = nil # SCOPE

  configure do
    set :app_file, __FILE__
    set :root, File.join(File.dirname(__FILE__), "..", "..")
    set :public_folder, File.join(settings.root, "public")
    set :views, File.join(settings.root, "views")
    set :db_dir, File.join(settings.root, "db")
    set :pages_dir, File.join(settings.root, "pages")

    @@db = Sequel.connect("sqlite://%s/%s.sqlite3" % [settings.db_dir,
      "cfkblog"])
    require 'models/post'
    Post.db = @@db
  end

  before do
    response["Content-Type"] = "text/html;charset=utf-8"
  end
end
