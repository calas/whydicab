class Article
  include DataMapper::Resource
  include Archive

  property :id, Serial
  property :title, String, :length => 255, :nullable => false, :unique => true
  property :body, Text, :nullable => false
  property :published, Boolean
  property :created_at, DateTime
  property :updated_at, DateTime
  property :published_at, DateTime
  property :permalink, String, :length => 255
  property :locale, String, :length => 2
  has 1, :translation, :class_name => Article
  has 1, :author, :class_name => User

  has_tags

  validates_is_accepted :locale, :accept => %w(en es)
  validates_present :author, :when => [:saving]

  before :save, :must_be_valid_for_saving
  before :save, :set_published

  def self.find_recent(locale = 'en')
    self.all(:locale => locale, :published => true,
             :limit => 10, :order => [:published_at.desc])
  end

  def self.new_with_translation(params)
    article = self.new(params[:article])
    if should_have_translation? params
      article.translation = self.new(params[:translation])
      article.translation.locale = article.translation_locale
      article.translation.tag_list = params[:article][:tag_list] # article.tag_list
    end
    article
  end

  # to be saved must be valid for saving context
  def must_be_valid_for_saving
    self.valid?(:saving)
  end

  def save_with_translation(author)
    self.translation.author = self.author = author
    article_saved_ok = self.save
    # are both saved ok?
    article_saved_ok and !self.translation.new_record?
  end

  def have_translation?
    !self.translation.nil?
  end

  def translation_locale
    self.locale == 'en' ? 'es' : 'en'
  end

  def to_html
    RedCloth.new(self.body || "").to_html
  end

  private
  def self.should_have_translation?(params)
    params[:have_translation] == "1"
  end

  def set_published
    if published?
      self.published_at ||= Time.now
      self.permalink ||= create_permalink
    end
  end

  def create_permalink
    date = self.published_at.strftime("%Y-%m-%d")
    date + "-" + self.title.gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-')
  end

end
