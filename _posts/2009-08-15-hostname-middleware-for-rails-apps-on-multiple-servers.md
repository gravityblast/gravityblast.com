---
layout: post
title: Hostname middleware for rails apps on multiple servers
tags:
- Development
- Rails
- Ruby
status: publish
type: post
published: true
meta:
  _edit_last: '1'
excerpt: "Hostname middleware for rails apps on multiple servers"
---
If you run a rails application on multiple servers behind a load balancer, almost every time you make a request you have a response from a different host. If you want to know which host has sent back the response, you can use a middleware that adds the hostname in the page title of each request.

<strong>lib/hostname.rb</strong>:

    class Hostname
      TITLE_REGEXP = /(<title>)([^<]*)(<\/title>)/i

      def initialize(app, hostname="")
        @app          = app
        @title_suffix = " - on #{hostname}"
      end

      def call(env)
        status, headers, response = @app.call(env)
        add_hostname(response, headers) if headers["Content-Type"] =~ %r{text/html}
        [status, headers, response]
      end

      def add_hostname(response, headers)
        response.each{|s| s.sub!(TITLE_REGEXP, "\\1\\2#{@title_suffix}\\3") if s =~ TITLE_REGEXP}
        headers["Content-Length"] = (headers["Content-Length"].to_i + @title_suffix.length).to_s
        nil
      end
    end

To use it, add this line in your <strong>environment.rb</strong>:

    config.middleware.use "Hostname", %x"hostname".chomp

When you don't need it anymore you can simply remove the line above.
