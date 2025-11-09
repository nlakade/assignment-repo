class ArticlesController < ApplicationController
  def index
    @articles = Article.order(created_at: :desc)
  end

  def show
    @article = Article.find_by(slug: params[:slug])
  end

  def new
    @article = Article.new
  end

  def create
    titles = params[:titles].to_s.split("\n").map(&:strip).reject(&:blank?)
    
    if titles.any?
      generated_articles = generate_articles(titles)
      @articles = Article.create(generated_articles)
      
      redirect_to articles_path, notice: "Generated #{@articles.count} articles"
    else
      redirect_to new_article_path, alert: "Please enter at least one title"
    end
  end

  def ai_generate
    prompt = params[:prompt]
    
    titles = extract_titles_from_prompt(prompt)
    
    if titles.any?
      generated_articles = generate_articles(titles)
      Article.create(generated_articles)
      
      render json: { 
        success: true, 
        message: "Generated #{titles.size} articles from your prompt",
        articles: titles 
      }
    else
      render json: { 
        success: false, 
        message: "Could not extract article titles from your prompt. Please try: 'Generate articles about Ruby, Python, JavaScript'" 
      }
    end
  end

  private

  def extract_titles_from_prompt(prompt)
    if prompt.downcase.include?('generate articles about') || prompt.downcase.include?('create articles on')
      topics = prompt.split(/about|on/).last
      topics.split(/[,&]/).map(&:strip)
    else
      [prompt]
    end
  end

  def generate_articles(titles)
    articles = []
    
    titles.each do |title|
      content = generate_article_content(title)
      
      articles << {
        title: title,
        content: content,
        slug: title.parameterize,
        published_at: Time.current
      }
    end
    
    articles
  end

  def generate_article_content(topic)
    
    
    <<~CONTENT
    # #{topic}

    ## Introduction to #{topic}

    #{topic} is a fascinating subject in the world of programming and technology. This article explores the key concepts and practical applications.

    ## Key Features

    - **Feature 1**: Important aspect of #{topic}
    - **Feature 2**: Another crucial element
    - **Feature 3**: Advanced functionality

    ## Getting Started

    Here's a simple example to get you started with #{topic}:

    ```ruby
    def hello_#{topic.downcase.gsub(' ', '_')}
      puts "Welcome to the world of #{topic}!"
    end
    ```

    ## Best Practices

    1. Always follow coding standards
    2. Write comprehensive tests
    3. Document your code
    4. Keep learning and improving

    ## Conclusion

    #{topic} offers powerful capabilities for developers. With practice and dedication, you can master this technology and build amazing applications.

    *This article was generated using AI technology.*
    CONTENT
  end
end