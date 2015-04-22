require 'json'
require 'sequel'

class Post < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence :title
    validates_presence :timestamp
    validates_presence :body
  end

  def before_create
    self.slug ||= mkslug
    self.tags ||= JSON.dump([])
    super
  end

  def self.report
    self.select(:id, :timestamp, :title, :published).
    order_by(Sequel.desc(:timestamp)).each { |row|
      pub = row.published ? "PUB" : "UNPUB"
      print("%d\t%s\t%s\t%s\n" % [row.id, pub, row.timestamp, row.title])
    }
  end

  def publish!
    self.update(:published => true)
    self.save
  end

  def self.unpublished
    return self.filter(:published => false)
  end

  def self.published
    return self.filter(:published => true)
  end

  private

  def mkslug
    title = self.title.downcase.gsub(/\s+/, "-")
    date = self.timestamp.strftime("%Y-%m-%d")
    return "#{date}-#{title}"
  end
end
