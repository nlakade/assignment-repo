# LinkedIn Scraper

This Ruby script scrapes LinkedIn profile data using Selenium WebDriver.

## Setup

1. Install Chrome browser
2. Install ChromeDriver: `brew install chromedriver` (on Mac) or download from official site
3. Install gems: `bundle install`

## Configuration

- Update `email` and `password` in `scraper.rb` with test LinkedIn credentials
- Add real LinkedIn profile URLs to the `profile_urls` array
- The script includes proxy rotation and user agent rotation to avoid detection

## Usage

```bash
ruby scraper.rb