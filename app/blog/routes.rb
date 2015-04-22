require 'json'

class Blog
  get("/") do
    return erb(:index, :locals => {
      :posts => Post.published.order_by(Sequel.desc(:timestamp)).limit(7),
      :title => nil,
    })
  end

  get("/posts/?") do
    posts = @@db[:posts]
    return erb(:posts, :locals => {
      :posts => Post.published.order_by(Sequel.desc(:timestamp)).
        select(:slug, :title, :timestamp).all,
      :title => "All Posts",
    })
  end

  get("/posts/:slug/?") do
    post = Post.published.filter(:slug => params[:slug]).first
    return erb(:post, :locals => {
      :post => post,
      :title => post.title,
    })
  end

  # XXX really hacky
  get("/pages/:page/?") do
    article, title = article(params[:page])
    return erb(:page, :locals => {
      :article => article,
      :title => title,
    })
  end
end
