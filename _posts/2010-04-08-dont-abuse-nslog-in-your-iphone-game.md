---
layout: post
title: Don't abuse NSLog in your iPhone game
tags:
- Cocos2d
- Development
- iPhone
status: publish
type: post
published: true
meta:
  _edit_last: '1'
excerpt: "Don't abuse NSLog in your iPhone game"
---
I'm working on a simple game for iPhone based on <a href="http://www.cocos2d-iphone.org/" title="Cocos2d">cocos2d</a>. Yesterday I installed it on my old iPhone3G and it was veeeeeeeery slow. After a lot of refactoring I found a NSLog call inside my game loop. It basically logged all the collision detection of the player with all the tiles in the map. After removing that it's even faster then before. So, if you want to log something, do it, but remember to remove all these logging calls later.
