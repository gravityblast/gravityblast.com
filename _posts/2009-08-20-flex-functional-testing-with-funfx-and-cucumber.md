---
layout: post
title: Flex functional testing with FunFx and Cucumber
tags:
- Cucumber
- Development
- Flex
- RIA
- Ruby
- Testing
status: publish
type: post
published: true
meta:
  _edit_last: '1'
---
[Cucumber](http://cukes.info/ "Cucumber") is a great tool I usually use for [BDD](http://en.wikipedia.org/wiki/Behavior_driven_development "Behavior Driven Development") in my ruby projects, but yesterday I tried it with Flex, and it was very enjoyable. Here a little example on how to test Flex applications with Cucumber.

First of all you need ruby, then you need to install the following gems:

    sudo gem install rspec cucumber watir safariwatir funfx

(I used the following codes on <strong>mac os x</strong>, with <strong>ruby 1.8.6</strong>, <strong>safari 4.0.3</strong> and <strong>funx 0.2.2</strong>)

After that open Flex Builder and create a new project called CucumberExample and use the following code for your main mxml file:
    <?xml version="1.0" encoding="utf-8"?>
    <mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute">
      <mx:Number id="index">0</mx:Number>
      <mx:VBox width="300" height="200" backgroundColor="white">
        <mx:HBox width="100%" height="30">			
          <mx:Button id="buttonDecrement" label="-" width="100%" />
          <mx:Button id="buttonIncrement" label="+" width="100%" />
        </mx:HBox>
        <mx:HBox width="100%" height="100%" verticalAlign="middle" horizontalAlign="center">
          <mx:Label id="myLabel" text="{index}"/>			
        </mx:HBox>
      </mx:VBox>
    </mx:Application>

As you can see, we have a number, 2 buttons and a label. Now create a directory called features inside your flex project folder and create the first Cucumber feature file, called counter:
<strong>CucumberExample/features/counter.feature</strong>:
    Feature: Counter
      In order to count something
      As a flex rock star
      I want to use my great flex app
    
      Scenario: Increment index
        Given I open my flex app
        And I click the increment button
        Then the label text should be "1"
        When I click the decrement button
        Then the label text should be "0"
        When I click the decrement button
        Then the label text should be "-1"

<p>It's a test written in pure plain text.</p>
<p>In the <strong>features</strong> folder create another folder called <strong>step_definitions</strong> with a blank file called <strong>counter_steps.rb</strong>, we'll use it later.</p>
<p>Now open the console, go the to flex project root and run your test:</p>
<pre lang="bash">
cd /path/to/CucumberExample
cucumber features
</pre>
<p>You should see something like this:</p>
<pre lang="bash">
...
1 scenario (1 undefined)
7 steps (7 undefined)
0m0.002s
</pre>
You can implement step definitions for undefined steps with these snippets:

    Given /^I open my flex app$/ do
      pending
    end
    
    Given /^I click the increment button$/ do
      pending
    end
    
    Then /^the label text should be "([^\"]*)"$/ do |arg1|
      pending
    end
    
    When /^I click the decrement button$/ do
      pending
    end

<p>Before implementing the steps above, we need to add the funfx component to our library.</p>
<p>Download the latest <strong>swc</strong> file from <a href="http://rubyforge.org/frs/?group_id=3898&release_id=16452">rubyforge</a> and place it in your <strong>CucumberExample/libs</strong> folder (I used the version 0.2.2).</p>
<p>Duplicate the bin-debug folder and rename it to <strong>test</strong> (you have a bin-debug folder after the first time you run the CucumberExample from FlexBuilder).</p>
<p>Inside the test directory create a file called <strong>test_server.rb</strong> with the following content:</p>

    require 'webrick'
    
    server = WEBrick::HTTPServer.new :Port => 9852, :DocumentRoot => File.dirname(__FILE__)
    trap("INT"){ server.shutdown }
    server.start

<p>Now you need a compiled version of your project that includes funfx.We'll use it just for testing:</p>
<strong>build_test.sh</strong>

    #!/bin/sh
    FLEX_SDK_HOME="/Applications/Adobe Flex Builder 3/sdks/3.2.0"
    "$FLEX_SDK_HOME/bin/mxmlc" -verbose-stacktraces -include-libraries ./libs/funfx-0.2.2.swc "$FLEX_SDK_HOME/frameworks/libs/automation.swc" "$FLEX_SDK_HOME/frameworks/libs/automation_dmv.swc"  "$FLEX_SDK_HOME/frameworks/libs/automation_agent.swc" -output ./test/CucumberExample.swf -- ./src/CucumberExample.mxml

<p>Run test <strong>compile_test.sh</strong></p>

    chmod 755 ./build_test.sh
    ./build_test.sh

<p>Now open another terminal window and start the test server:</p>

    cd /path/to/CucumberExample/test
    ruby test_server.rb

<p>Open http://localhost:9852/CucumberExample.html with your browser and you should see your flex app.</p>
<p>Now you can come back to your features and implement the step we leave before. Here my implementation:</p>
<p><strong>CucumberExample/features/step_definitions/counter_steps.rb</strong></p>

    Given /^I open my flex app$/ do
      open_flex_app
    end
    
    Given /^I click the (increment|decrement) button$/ do |button|  
      click_button("button#{button.capitalize}")  
    end
    
    Then /^the label text should be "([^\"]*)"$/ do |text|
      label_text.should == text  
    end

<p><strong>open_flex_app</strong>, <strong>click_button</strong> and <strong>label_text</strong> are methods  defined in my <strong>env.rb</strong> file.</p>
<p><strong>CucumberExample/features/support/env.rb</strong></p>

    require "rubygems"
    require 'funfx/browser/safariwatir'
    
    module FlexWorld
      def open_flex_app
        @browser.goto("http://localhost:9852/CucumberExample.html")
      end
      
      def click_button(button_id)
        @flex_app.button(:id => button_id).click
      end
      
      def label_text
        @flex_app.label(:id => "myLabel").text
      end
    end
    
    Before do
      @browser  = Watir::Safari.new
      @flex_app = @browser.flex_app("CucumberExample", "CucumberExample")  
    end
    
    After do
      @browser.close
    end
    
    World(FlexWorld)

<p>Now you are ready to run your tests.  Start the test_server and then the features. You should have  an error:</p>

    Then the label text should be "1"  # features/step_definitions/counter_steps.rb:9
          expected: "1",
               got: "0" (using ==)

<p>This because we didn't implement the functionality yet in our flex app. So, change the mxml file with the following:</p>

    <?xml version="1.0" encoding="utf-8"?>
    <mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute">
      <mx:Number id="index">0</mx:Number>
      <mx:VBox width="300" height="200" backgroundColor="white">
        <mx:HBox width="100%" height="30">			
          <mx:Button id="buttonDecrement" label="-" width="100%" click="index--" />
          <mx:Button id="buttonIncrement" label="+" width="100%" click="index++" />
        </mx:HBox>
        <mx:HBox width="100%" height="100%" verticalAlign="middle" horizontalAlign="center">
          <mx:Label id="myLabel" text="{index}"/>			
        </mx:HBox>
      </mx:VBox>
    </mx:Application>

<p>It's the same code but I added the click action to the increment and decrement buttons. Now compile the new code and run the features again:</p>

    ./build_test.sh
    cucumber features

<p>You shoiuld have the following output, with all the seven steps passed:</p>

    Feature: Counter
      In order to count something
      As a flex rock star
      I want to use my great flex app
    
      Scenario: Increment index            # features/counter.feature:6
        Given I open my flex app           # features/step_definitions/counter_steps.rb:1
        And I click the increment button   # features/step_definitions/counter_steps.rb:5
        Then the label text should be "1"  # features/step_definitions/counter_steps.rb:9
        When I click the decrement button  # features/step_definitions/counter_steps.rb:5
        Then the label text should be "0"  # features/step_definitions/counter_steps.rb:9
        When I click the decrement button  # features/step_definitions/counter_steps.rb:5
        Then the label text should be "-1" # features/step_definitions/counter_steps.rb:9
    
    1 scenario (1 passed)
    7 steps (7 passed)
    0m9.781s

<p>If you have any problems you may want to clear the cache from safari.</p> 
<p>I used the funfx gem from  <a href="http://funfx.rubyforge.org/">rubyforge</a> but it's not up to date. If you want you can get the new code from <a href="http://github.com/peternic/funfx/tree/master">github</a>, it should have new features.</p>
