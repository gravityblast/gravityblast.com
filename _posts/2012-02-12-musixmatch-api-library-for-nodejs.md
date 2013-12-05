---
layout: post
title: musiXmatch API library for NodeJS
tags:
- javascript
- nodejs
---
I've just published my first <a title="NPM" href="http://npmjs.org/">NPM</a> package, and it's called <a title="musiXmatch for NodeJS" href="http://search.npmjs.org/#/musixmatch">musixmatch</a>. With this library you can easily use the <a title="musiXmatch" href="http://musixmatch.com/">musiXmatch</a> API with a few lines of javascript.
Install it with NPM:

    npm install -g musixmatch

And here an example:

    var util  = require("util");
    var mXm   = require("musixmatch");

    mXm.Config.API_KEY = "YOUR_API_KEY";

    var successCallback = function(modelOrCollection) {
      console.log("Success:");
      console.log("  " + util.inspect(modelOrCollection));
    };

    var errorCallback = function(response) {
      console.log("Error callback:");
      console.log("  " + util.inspect(response));
    };

    mXm.API.getTrack(TRACK_ID, successCallback, errorCallback);
    mXm.API.getLyrics(LYRICS_ID, successCallback, errorCallback);
    mXm.API.getArtist(ARTIST_ID, successCallback, errorCallback);
    mXm.API.getAlbum(ALBUM_ID, successCallback, errorCallback);
    mXm.API.getSubtitle(TRACK_ID, successCallback, errorCallback);
    mXm.API.searchTrack({q: QUERY}, successCallback);

If you want you can set your musiXmatch API KEY as an environment variable, and you won't need to set it in your code:

    export MUSIX_MATCH_API_KEY="YOUR_API_KEY"

You can find the source code on <a href="https://github.com/pilu/musixmatch-node" title="musiXmatch node">github</a>.
