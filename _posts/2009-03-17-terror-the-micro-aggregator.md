---
layout: post
title: Terror the micro aggregator
tags:
- Development
- Ruby
- Sinatra
status: publish
type: post
published: true
meta:
  _edit_last: '1'
---
<p><a href="http://github.com/pilu/terror/tree/master" title="Terror the micro feed aggregator">Terror</a> is a micro feed aggregator made with <a href="http://www.sinatrarb.com/" title="Sinatra">sinatra</a> and bundled as a gem. It's very simple to use, just install the gem:
</p>
<pre><code>gem sources -a http://gems.github.com
sudo gem install pilu-terror
</code></pre>

<p>Create a new project</p>
<pre><code>terror new_aggregator_name
cd new_aggregator_name </code></pre>
<p>Start the server</p>
<pre><code>thin start -C config/thin.yml</code></pre>
<p>Run the feeds fetcher</p>
<pre><code>rake feeds:fetch # run it as a cron job</code></pre>

<p>You can browse the source and fork it on <a href="http://github.com/pilu/terror/tree/master" title="Terror the micro feed aggregator">github</a>.
</p>
<p>
<img src="http://gravityblast.com/wp-content/uploads/2009/03/terror.jpg" alt="" title="terror" width="500" height="591" class="alignnone size-full wp-image-123" />
</p>
