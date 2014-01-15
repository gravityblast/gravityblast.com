---
layout: post
title: Build and restart your Go web app with Fresh
tags:
- go
- golang
- traffic
- martini
- gocraft-web
---

[Fresh](https://github.com/pilu/fresh) is a command line tool that builds and (re)starts your web application everytime you save a Go file.

I usually use tests when I add/change some features in my application, so I don't need to refresh the browser to check if everything works.
But when I change simple things, or maybe some templates, I need to stop the server, build and restart. It's not a big deal since `go build` is really fast,
but I wanted to automate this process with Fresh.

Instead of running the application directly, I run `fresh` inside the app folder. Every time I create/modify/delete a file, Fresh runs `go build` and restarts the application.
If the build command returns an error, it will log the error message in the tmp folder. If the framework you are using supports Fresh, it can show that error in the browser.

[Traffic](https://github.com/pilu/traffic) already supports it. If you run a Traffic app with Fresh, Traffic automatically add a Middleware that
shows the build errors if an error log file exists.

Anyway Fresh is not part of Traffic, and you can use it with any other framework that supports some kind of middleware.

In the [_example](https://github.com/pilu/fresh/tree/master/_examples) folder there is an example app using [Martini](https://github.com/codegangsta/martini)
where I created a simple middleware that uses some functions from `github.com/pilu/fresh/runner/runnerutils`.
I made [the same](https://github.com/pilu/fresh/blob/master/_examples/gocraft-web/main.go) for [gocraft/web](https://github.com/gocraft/web).

In the [pilu-martini](https://github.com/pilu/fresh/tree/master/_examples/pilu-martini) folder there is another example using a [modified version of Martini](https://github.com/pilu/martini)
that already uses the runner lib.

Check the [repository on Github](https://github.com/pilu/fresh) for more informations, and feel free to send me a pull request.
