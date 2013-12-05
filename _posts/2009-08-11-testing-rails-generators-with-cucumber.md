---
layout: post
title: Testing rails generators with Cucumber
tags:
- Cucumber
- Development
- Rails
- Ruby
- Testing
status: publish
type: post
published: true
meta:
  _edit_last: '1'
---
In the last days I switched a lot of old projects to use <a href="http://cukes.info/" title="Cucumber">Cucumber</a>, then I started writing test for <a href="http://github.com/pilu/web-app-theme" title="Web App Theme">Web App Theme</a>. Here I haven't models or controllers to test, because it's just a generator, but I found enjoyable the use of plain text features to describe the <strong>ThemeGenerator</strong> behavior:

    Feature: Layout generation
      In order to create a great application
      I should be able to generate a layout with Web App Theme

      # script/generate theme
      Scenario: Generate a layout    
        Given I have a new rails app
        And I have no layouts
        And I have no stylesheets
        When I generate a theme
        Then I should have a layout named "application.html.erb"
        And I should have a stylesheet named "web_app_theme.css"
        And I should have a stylesheet named "web_app_theme_override.css"
        And I should have a stylesheet named "themes/default/style.css"
      
      # script/generate theme admin
      Scenario: Generate a layout with a name
        Given I have a new rails app
        And I have no layouts
        And I generate a theme with name "admin"
        Then I should have a layout named "admin.html.erb"
      
      # script/generate theme --theme="drastic-dark"
      Scenario: Generate a layout choosing a theme
        Given I have a new rails app
        And I have no stylesheets
        And I generate a theme choosing the "drastic-dark" theme
        Then I should have a stylesheet named "themes/drastic-dark/style.css"
      
      # script/generate theme --theme=bec --no_layout
      Scenario: Generate only stylesheets without layout
        Given I have a new rails app
        And I have no layouts
        And I generate a theme without layout choosing the "bec" theme
        Then I should have a stylesheet named "themes/bec/style.css"
        But I should not have any layouts
      
      # script/generate theme --app_name="My New Application"
      Scenario: Generate layout with application name
        Given I have a new rails app
        And I have no layouts
        And I generate a theme with application name "My New Application"
        Then the layout "application.html.erb" should have "My New Application" as page title
      
      # script/generate theme --type=sign
      Scenario: Generate layout for signin and signup
        Given I have a new rails app
        And I have no layouts
        And I generate a theme for signin and signup
        Then I should have a layout named "sign.html.erb"
        And I should have a layout named "sign.html.erb" with just a box

Here my steps:

    Given /^I have a new rails app$/ do
      generate_rails_app
    end
    
    Given /^I have no layouts$/ do
      remove_layouts  
    end
    
    Given /^I have no stylesheets$/ do
      remove_stylesheets
    end
    
    Given /^I generate a theme$/ do
      generate_layout(:theme)  
    end
    
    Given /^I generate a theme with name "([^\"]*)"$/ do |name|
      generate_layout(:theme, name)
    end
    
    Given /^I generate a theme choosing the "([^\"]*)" theme$/ do |theme_name|
      generate_layout(:theme, :theme => theme_name)
    end
    
    Then /^I should have a layout named "([^\"]*)"$/ do |filename|
      layout_exists?(filename).should be_true  
    end
    
    Then /^I should have a stylesheet named "([^\"]*)"$/ do |filename|
      stylesheet_exists?(filename).should be_true    
    end
    
    Given /^I generate a theme without layout choosing the "([^\"]*)" theme$/ do |theme_name|
      generate_layout(:theme, :theme => theme_name, :no_layout => true )
    end
    
    Then /^I should not have any layouts$/ do
      layouts_count.should == 0
    end
    
    Given /^I generate a theme with application name "([^\"]*)"$/ do |name|
      generate_layout(:theme, :app_name => name )
    end
    
    Then /^the layout "([^\"]*)" should have "([^\"]*)" as page title$/ do |layout, title|
      layout_title(layout).should == title
    end
    
    Given /^I generate a theme for signin and signup$/ do
      generate_layout(:theme, :layout_type => :sign)
    end
    
    Then /^I should have a layout named "([^\"]*)" with just a box$/ do |layout|
      layout_with_box?(layout).should be_true
    end

<p>Basically I create a temp folder that I use as fake rails root, and there I launch the generator.  After each feature I remove that folder.</p>
<p>And here my <strong>env.rb</strong></p>

    $:.unshift(File.dirname(__FILE__) + "/../../rails_generators")
    require "rubygems"
    require "rails_generator"
    require 'rails_generator/scripts/generate'
    require "fileutils"
    require "theme/theme_generator"
    
    web_app_theme_root  = File.join(File.dirname(__FILE__), "/../../")
    tmp_rails_app_name  = "tmp_rails_app"
    tmp_rails_app_root  = File.join(web_app_theme_root, tmp_rails_app_name)
    
    Rails::Generator::Base.append_sources(Rails::Generator::PathSource.new(:plugin, "#{web_app_theme_root}/rails_generators/"))
    
    module GeneratorHelpers
      def generate_rails_app
        FileUtils.mkdir(File.join(@app_root))
      end    
      
      def remove_layouts
        FileUtils.rm_rf(File.join(@app_root, "app", "views", "layouts"))
      end
      
      def remove_stylesheets
        FileUtils.rm_rf(File.join(@app_root, "public", "stylesheets"))
      end
      
      def generate_layout(*args)
        options = !args.empty? && args.last.is_a?(Hash) ? args.pop : {}
        options.merge!({:destination => @app_root, :quiet => true})    
        Rails::Generator::Scripts::Generate.new.run(args, options)
      end
      
      def layouts_count
        Dir[File.join(@app_root, "app", "views", "layouts", "**", "*.erb")].size
      end
      
      def layout_exists?(filename)
        File.exists?(File.join(@app_root, "app", "views", "layouts", filename))
      end
      
      def stylesheet_exists?(relative_path)
        File.exists?(File.join(@app_root, "public", "stylesheets", relative_path)).should be_true
      end
      
      def layout_title(layout)
        File.open(File.join(@app_root, "app", "views", "layouts", layout), "r").read.match(/<title>([^<]*)<\/title>/)[1]
      end
      
      def layout_with_box?(layout)
        File.open(File.join(@app_root, "app", "views", "layouts", layout), "r").read =~ %r|<div id="box">|
      end
    end
    
    Before do
      @app_root = tmp_rails_app_root  
    end
    
    After do
      FileUtils.rm_rf(tmp_rails_app_root)
    end
    
    World(GeneratorHelpers)
