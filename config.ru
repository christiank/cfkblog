$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'app/blog'
use Rack::CommonLogger
run Blog
