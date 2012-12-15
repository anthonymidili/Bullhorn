require 'spec_helper'

describe "Static pages" do

  describe "Home page" do
    it "should have the h1 'Bookkeeping'" do
      visit root_path
      page.should have_selector('h1', text: 'Bookkeeping')
    end
    it "should have the title 'Home'" do
      visit root_path
      page.should have_selector('title',
                  text: "Bookkeeping | Home")
    end
  end

  describe "Help page" do
    it "should have the h1 'Help'" do
      visit help_path
      page.should have_selector('h1', text: 'Help')
    end

    it "should have the title 'Help'" do
      visit help_path
      page.should have_selector('title',
                                text: "Bookkeeping | Help")
    end
  end

  describe "About page" do
    it "should have the h1 'About'" do
      visit about_path
      page.should have_selector('h1', text: 'About Us')
    end
    it "should have the title 'Home'" do
      visit about_path
      page.should have_selector('title',
                                text: "Bookkeeping | About Us")
    end
  end

  describe "Contact page" do
    it "should have the h1 'Contact'" do
      visit contact_path
      page.should have_selector('h1', text: 'Contact')
    end
    it "should have the title 'Home'" do
      visit contact_path
      page.should have_selector('title',
                                text: "Bookkeeping | Contact")
    end
  end

end
