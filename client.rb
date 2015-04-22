require 'optparse'
require 'sequel'
require 'tempfile'

class BlogClient
  EDITOR = ENV["EDITOR"] || "/usr/bin/vi"

  def main!
    parse_options

    case @command
    when "create"
      create
    when "edit"
      edit
    when "delete"
      delete
    when "list"
      list
    else
      complain("need a command: 'create', 'edit', 'delete' or 'list'")
    end

    exit 0
  end

  private

  def ask(q)
    print("%s " % [q,])
    return $stdin.gets.chomp
  end

  def complain(msg)
    $stderr.printf("!! %s\n" % [msg,])
    exit 1
  end

  def info(msg)
    $stderr.printf("-- %s\n" % [msg,])
  end

  # => Returns a closed Tempfile object. It is the caller's responsibility
  # to unlink the file when done.
  def mktempfile
    tf = Tempfile.new("cfkblog")
    tf.close
    return tf
  end

  def parse_options
    @options = {
      :db => nil,
      :id => nil,
    }

    @parser = OptionParser.new do |opts|
      opts.on("-d database") { |d| @options[:db] = File.expand_path(d) }
      opts.on("-i ID") { |i| @options[:id] = i.to_i }
    end

    @parser.parse!
    complain("need a db!!") if not @options[:db]
    @command = ARGV.shift

    @db = Sequel.connect("sqlite://%s" % [@options[:db]])
    $LOAD_PATH.unshift File.dirname(__FILE__)
    require 'models/post'
    Post.db = @db
  end

  def create
    info("using database #{@options[:db]}")
    title = ask("title?")

    tf = mktempfile
    system %Q(#{EDITOR} #{tf.path})
    body = File.read(tf.path)
    tf.unlink

    blurb = ask("blurb:")

    post = Post.create({
      :title => title,
      :body => body,
      :timestamp => Time.now,
      :blurb => blurb,
    })

    info("created post #{post.id} -- #{post.title}")

    res = ask("publish now? yes/no")

    if res == "yes"
      post.update(:published => true)
      post.save
      info("post #{post.id} is now available")
    end
  end

  def edit
    complain("need an ID") if not @options[:id]
    post = Post.first(:id => @options[:id])
    complain("post #{@options[:id]} does not exist") if not post

    tf = mktempfile
    File.open(tf.path, "w") { |f| f.print(post.body) }
    system %Q(#{EDITOR} #{tf.path})
    body = File.read(tf.path)
    tf.unlink

    post.body = body
    post.save
    info("Edited post #{post.title.inspect}")
  end

  def delete
    complain("need an ID") if not @options[:id]
    post = Post.first(:id => @options[:id])
    complain("post #{@options[:id]} does not exist") if not post
    id, title = post.id, post.title

    ans = ask("are you sure? -- %d %s -- yes/no:" % [id, title,])

    if ans == "yes"
      post.destroy
      info("deleted post %d - %s" % [post.id, post.title,])
    end
  end

  def list
    Post.select(:id, :timestamp, :title).order_by(Sequel.desc(:timestamp)).each do |post|
      $stdout.print("%d\t%s\t%s\n" % [post.id, post.timestamp, post.title])
    end
  end
end

if $0 == __FILE__
  BlogClient.new.main!
end
