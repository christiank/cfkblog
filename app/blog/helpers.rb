require 'kramdown'

class Blog
  helpers do
    def markdown(str)
      return Kramdown::Document.new(str).to_html
    end

    def h(str)
      return Rack::Utils.escape_html(str)
    end

    def prettytime(time)
      return time.strftime("%B %d, %Y at %I:%M %p")
    end

    # Returns [article, title], but the title is actually derived from the
    # article itself. The author is expected to put a level-2 header at
    # first line of the file.
    def article(name)
      raw = File.read(File.join(settings.pages_dir, "#{name}.md"))
      title = raw.split("\n")[0].sub(/^\#{2}\s*/, "")
      return [markdown(raw), title]
    end
  end
end
