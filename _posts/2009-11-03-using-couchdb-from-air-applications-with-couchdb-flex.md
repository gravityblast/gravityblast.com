---
layout: post
title: Using CouchDB from Air applications with CouchDB Flex
tags:
- AIR
- Couchdb
- Development
- Flex
status: publish
type: post
published: true
meta:
  _edit_last: '1'
---
In the last weeks I played a lot with <a href="http://couchdb.apache.org/" title="CouchDB">CouchDB</a> and I love it. I always used it from ruby but yesterday I tried to use it with flex. I started a new Actionscript project called <a href="http://github.com/pilu/couchdb-flex" title="CouchDB Flex">CouchDB Flex</a>, you can browse the source from <a href="http://github.com/pilu/couchdb-flex" title="CouchDB Flex on Github">github</a>. The implementation is inspired by <a href="http://github.com/jchris/couchrest">couchrest</a>, but it's asynchronous because I use <a href="http://livedocs.adobe.com/flex/3/langref/flash/net/URLLoader.html" title="URLLoaer">URLLoader</a> internally. Since the flash player  doesn't support the PUT and DELETE HTTP methods, you must create an AIR project if you want to try the library.  You can find a compiled swc <a href="http://github.com/pilu/couchdb-flex/downloads">here</a>, put it in your libs folder and you are ready to go. Here a small example, but it's still in development, and a lot of functionality are not implemented yet.

<p><strong>CouchdbFlexExample.mxml:</strong> the main mxml file, it's just a window with a textarea that will display the data loaded from CouchDB.</p>
<pre lang="actionscript3">
<?xml version="1.0" encoding="utf-8"?>
<c:App xmlns:fx="http://ns.adobe.com/mxml/2009" xmlns:s="library://ns.adobe.com/flex/spark" xmlns:c="com.gravityblast.couchdbflexexample.*">
  <s:TextArea id="textarea" width="100%" height="100%" text="{log}"/>			
</c:App>
</pre>

<p><strong>com/gravityblast/couchdbflexexample/Contact.as:</strong> the model I'll save on CouchDB. By default the model has a name and an email, but I can add more properties since it's a dynamic class.</p>
<pre lang="actionscript3">
package com.gravityblast.couchdbflexexample
{
  import com.gravityblast.couchdb.Document;

  public dynamic class Contact extends Document
  {		
    public var name:String;
    public var email:String;
		
    public function Contact()
    {
      super();
    }
  }
}
</pre>

<p><strong>com/gravityblast/couchdbflexexample/App.as:</strong> the main application, where I create a new Contact Document, and I load all the contacts using a view created with the Design and View classes.</p>
<pre lang="actionscript3">
package com.gravityblast.couchdbflexexample
{
  import com.gravityblast.couchdb.CouchDb;
  import com.gravityblast.couchdb.Database;
  import com.gravityblast.couchdb.Design;
  import com.gravityblast.couchdb.View;
  import com.gravityblast.couchdb.events.CouchRestEvent;
  import com.gravityblast.couchdb.events.DocumentEvent;
  import com.gravityblast.couchdb.events.ViewEvent;
	
  import mx.events.FlexEvent;
	
  import spark.components.TextArea;
  import spark.components.WindowedApplication;
	
  public class App extends WindowedApplication
  {		
    private var couchdb:CouchDb;
    private var database:Database;
		
    [Bindable]
    public 	var log:String;
    public 	var textarea:TextArea;
		
    public function App()
    {			
      this.couchdb = new CouchDb();
      this.database = this.couchdb.database("couchdb-flex-example");
      this.log = "";
      this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationCompleteHandler);
      super();
    }
		
    private function creationCompleteHandler(event:FlexEvent):void
    {			
      this.database.create(this.databaseCreateHandler);	
    }
		
    private function databaseCreateHandler(event:CouchRestEvent):void
    {
      trace(event.data);
      if (event.json.ok || event.json.error.toString() == "file_exists")
      {
        var map:String = "function(doc) {if (doc['couchdb-flex-type'] == 'com.gravityblast.couchdbflexexample::Contact') emit(null, doc);}";
        var view:View = new View("all", map);
        var design:Design = new Design("contacts");
        design.addView(view);
        design.save(this.designSaveHandler);	
      }
    }
		
    private function designSaveHandler(event:DocumentEvent):void
    {
      trace(event.data);									
      if (event.json.ok || event.json.error == "conflict")			
        this.createContacts();
      else
        trace("Error saving design document: " + event.data)			
    }
		
    private function createContacts():void
    {
      var contact:Contact = new Contact();
      contact.name    = "jack";
      contact.email   = "jack@example.com";
      contact.address = "Jack Street";
      contact.save(this.contactSaveHandler);			
    }
		
    private function contactSaveHandler(event:DocumentEvent):void
    {			
      trace(event.data);
      var contact:Contact = event.document as Contact;
      contact.address = "Jack Street updated at " + (new Date()).toString();
      contact.save(this.contactUpdateHandler);			
    }
		
    private function contactUpdateHandler(event:DocumentEvent):void
    {			
      trace(event.data);
      View.load("contacts", "all", {}, this.contactsLoadHandler);
    }
		
    private function contactsLoadHandler(event:ViewEvent):void
    {					
      for each (var contact:Contact in event.documents)
      {
        for (var property:String in contact.attributes)
        {
          this.log += property + ": " + contact[property] + "\n";	
        }
        this.log += "-------------\n";
      }
    }
  }
}
</pre>

<p>I'll write more about the library as soon as it's more stable.</p>
