---
layout: post
title: How to deploy Go with Traffic on Heroku
tags:
- go
- golang
- traffic
- heroku
---

It's really easy to deploy a Go application based on the [Traffic](https://github.com/pilu/traffic) web framework on [Heroku](https://www.heroku.com/).
Let's start with a simple example.

First of all, we need a simple Traffic app:

{% highlight go %}
mkdir hello
cd hello
{% endhighlight %}

Create the `main.go` file with the following content:

{% highlight go %}
package main

import (
  "github.com/pilu/traffic"
)

func hello(w traffic.ResponseWriter, r *traffic.Request) {
  w.WriteText("Hello World")
}

func main() {
  r := traffic.New()
  r.Get("/", hello)
  r.Run()
}
{% endhighlight %}

Now you should be able to run the example with:

    go run main.go

Check <http://localhost:7000>.

Now we need to create a new Heroku app based on the [Go Heroku Buildpack](https://github.com/kr/heroku-buildpack-go).
You can red more about that on [this tutorial](http://mmcgrana.github.io/2012/09/getting-started-with-go-on-heroku.html),
but it's very easy, we just need a couple of files and commands.

Create the `.godir` file with the app name inside:

    echo 'hello' > .godir

Now we need a file called `Procfile` with some configuration for Traffic:

    web: TRAFFIC_PORT=$PORT TRAFFIC_ENV=production TRAFFIC_HOST=0.0.0.0 hello

We set 3 environment variables before calling our executable.

### TRAFFIC_PORT

By default Traffic runs on port 7000. You can change the port in your code using `traffic.SetPort(3000)` or just using the **TRAFFIC_PORT** variable.

### TRAFFIC_ENV

By default Traffic runs in development mode. This means that it adds some useful middleware for development like the ShowErrorsMiddleware, but you don't want to add them in production.
To run Traffic in production mode, just set `TRAFFIC_ENV=production`.
If you need to serve static files like css or images, you need to use the **StaticMiddleware**, which is automatically loaded in development mode but not in production.

To enable it in production, add the following code:

    if traffic.Env() == "production" {
      r.Use(traffic.NewStaticMiddleware(traffic.PublicPath()))
    }

### TRAFFIC_HOST

By default Traffic starts on 127.0.0.1:7000, and it's visible only from your local machine. To be able to see your application in production you need to bind it to `0.0.0.0`.

Now we just need to initialize our git repository, create the heroku app, and deploy it:

    git init
    git add .
    git commit -am "initial commit"

    heroku create -b https://github.com/kr/heroku-buildpack-go.git

    git push heroku master

Check if it works:

    heroku open
