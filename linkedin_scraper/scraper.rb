require 'selenium-webdriver'
require 'nokogiri'
require 'csv'
require 'faker'

class LinkedInScraper
  def initialize
    setup_driver
    @proxy_list = [
      '103.156.17.67:8080',
      '45.77.56.113:3128',
      '138.197.144.24:3128'
    ]
    @user_agents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    ]
  end

  def setup_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', false)
    
    @driver = Selenium::WebDriver.for :chrome, options: options
    @driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
  end

  def random_delay(min=2, max=5)
    sleep rand(min..max)
  end

  def login_to_linkedin(email, password)
    puts "Logging in to LinkedIn..."
    @driver.get 'https://www.linkedin.com/login'
    random_delay
    
    email_field = @driver.find_element(id: 'username')
    password_field = @driver.find_element(id: 'password')
    
    email_field.send_keys(email)
    random_delay(1, 2)
    password_field.send_keys(password)
    random_delay(1, 2)
    
    login_button = @driver.find_element(xpath: '//button[@type="submit"]')
    login_button.click
    random_delay(3, 5)
    
    if @driver.current_url.include?('feed')
      puts "Login successful!"
      return true
    else
      puts "Login failed!"
      return false
    end
  end

  def scrape_profile(profile_url)
    puts "Scraping: #{profile_url}"
    
    begin
      @driver.get "https://www.google.com"
      random_delay
      
      search_box = @driver.find_element(name: 'q')
      search_box.send_keys("site:linkedin.com/in #{profile_url.split('/').last}")
      search_box.submit
      random_delay
      
      first_result = @driver.find_element(css: 'div.g a')
      first_result.click
      random_delay(3, 5)
      
      profile_data = {}
      
      begin
        profile_data[:name] = @driver.find_element(css: 'h1.text-heading-xlarge').text
      rescue => e
        profile_data[:name] = 'N/A'
      end
      
      begin
        profile_data[:headline] = @driver.find_element(css: 'div.text-body-medium').text
      rescue => e
        profile_data[:headline] = 'N/A'
      end
      
      begin
        profile_data[:location] = @driver.find_element(css: 'span.text-body-small.inline.t-black--light.break-words').text
      rescue => e
        profile_data[:location] = 'N/A'
      end
      
      begin
        profile_data[:about] = @driver.find_element(css: 'section.pv-about-section div.display-flex ph5 pv3').text
      rescue => e
        profile_data[:about] = 'N/A'
      end
      
      begin
        experience_elements = @driver.find_elements(css: 'section.pv-experience-section li')
        profile_data[:experience] = experience_elements.map { |exp| exp.text.gsub(/\n/, ' ') }.join(' | ')
      rescue => e
        profile_data[:experience] = 'N/A'
      end
      
      begin
        education_elements = @driver.find_elements(css: 'section.pv-education-section li')
        profile_data[:education] = education_elements.map { |edu| edu.text.gsub(/\n/, ' ') }.join(' | ')
      rescue => e
        profile_data[:education] = 'N/A'
      end
      
      profile_data[:profile_url] = profile_url
      profile_data[:scraped_at] = Time.now.to_s
      
      return profile_data
      
    rescue => e
      puts "Error scraping #{profile_url}: #{e.message}"
      return nil
    end
  end

  def save_to_csv(profiles_data, filename = 'linkedin_profiles.csv')
    CSV.open(filename, 'w') do |csv|
      csv << ['Name', 'Headline', 'Location', 'About', 'Experience', 'Education', 'Profile URL', 'Scraped At']
      
      profiles_data.each do |profile|
        csv << [
          profile[:name],
          profile[:headline],
          profile[:location],
          profile[:about],
          profile[:experience],
          profile[:education],
          profile[:profile_url],
          profile[:scraped_at]
        ]
      end
    end
    puts "Data saved to #{filename}"
  end

  def run
    # Replace with your test LinkedIn credentials
    email = "your_test_email@example.com"
    password = "your_test_password"
    
    # Sample LinkedIn profile URLs (you should replace these with real ones)
    profile_urls = [
      'https://www.linkedin.com/in/sundarpichai',
      'https://www.linkedin.com/in/satyanadella',
      # Add 18 more real profile URLs here
    ]
    
    if login_to_linkedin(email, password)
      profiles_data = []
      
      profile_urls.each do |url|
        profile_data = scrape_profile(url)
        profiles_data << profile_data if profile_data
        random_delay(5, 10)
        
        break if profiles_data.size >= 5
      end
      
      save_to_csv(profiles_data)
    else
      puts "Cannot proceed without login"
    end
    
  ensure
    @driver.quit if @driver
  end
end

if __FILE__ == $0
  scraper = LinkedInScraper.new
  scraper.run
end