---
layout: post
title: Creating PDF with images using flex and AlivePDF
tags:
- AIR
- Development
- Flex
status: publish
type: post
published: true
meta:
  _edit_last: '1'
excerpt: "Creating PDF with images using flex and AlivePDF"
---
<p>
Today I'm working on an AIR application, and I need to create a PDF starting from a list of images. This PDF needs to have one image for each page. I used<a href="http://alivepdf.bytearray.org/" title="AlivePDF"> AlivePDF</a>, a very useful ActionScript3 library for PDF generation, and I created a simple class that takes an array of image paths and creates the PDF I need.
</p>
<p>Here the class I use:</p>
<pre lang="actionscript">
package
{	
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.net.URLRequest;
  import flash.utils.ByteArray;

  import org.alivepdf.pdf.PDF;	
  import org.alivepdf.display.Display;
  import org.alivepdf.images.ResizeMode;
  import org.alivepdf.layout.Layout;
  import org.alivepdf.layout.Orientation;
  import org.alivepdf.layout.Size;
  import org.alivepdf.layout.Unit;
  import org.alivepdf.saving.Method;
	
  public class PdfGenerator extends EventDispatcher
  {		  
    private var pdf:PDF;
    private var images:Array;		
    private var outFilePath:String;
    private var completedPages:int;
		
    public function PdfGenerator(images:Array, outFilePath:String)
    {
      this.outFilePath = outFilePath;
      this.images = images;
    }				
		
    public function generate():void
    {						
      this.completedPages = 0;
      this.pdf = new PDF(Orientation.LANDSCAPE, Unit.MM, Size.A4);
      this.nextPage();		
    }
		
    private function nextPage():void
    {
      this.completedPages < this.images.length ? this.loadImage(this.images[this.completedPages++]) : this.save();
    }
		
    private function loadImage(path:String):void
    {						
      var urlLoader:URLLoader = new URLLoader();			
      urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
      urlLoader.addEventListener(Event.COMPLETE, this.onImageLoadComplete);
      urlLoader.load(new URLRequest(path));						
    }
		
    private function onImageLoadComplete(event:Event):void
    {						
      this.pdf.addPage();
      this.pdf.addImageStream(ByteArray(event.target.data), 0, 0, 0, 0, 1, ResizeMode.FIT_TO_PAGE);
      this.dispatchEvent(new PdfGeneratorEvent(PdfGeneratorEvent.PDF_GENERATOR_PAGE_COMPLETE, false, false, this.images.length, this.completedPages));
      this.nextPage();
    }
				
    private function save():void
    {				
      this.pdf.end();
      this.writeOutFile();												
      this.dispatchEvent(new PdfGeneratorEvent(PdfGeneratorEvent.PDF_GENERATOR_COMPLETE));
    }
		
    private function writeOutFile():void
    {
      var fileStream:FileStream = new FileStream();								
      fileStream.open(new File(this.outFilePath), FileMode.WRITE);			
      fileStream.writeBytes(this.pdf.save(Method.LOCAL));
      fileStream.close();
    }
  }
}
</pre>
<p>Basically for each image it creates a new URLRequest and when the request is completed it adds a new page with the image. As you can see I also dispatch a custom Event called PdfGeneratorEvent. That because I need to create a PDF with a large number of images, and doing like this I can give a feedback to the user with a ProgressBar that display the generation progress.
</p>
<pre lang="actionscript">
package
{
  import flash.events.Event;

  public class PdfGeneratorEvent extends Event
  {			
    public static const PDF_GENERATOR_PAGE_COMPLETE:String = "PDF_GENERATOR_PAGE_COMPLETE";
    public static const PDF_GENERATOR_COMPLETE:String      = "PDF_GENERATOR_COMPLETE";			
	
    public var totalPages:int;
    public var completedPages:int;
				
    public function PdfGeneratorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, totalPages:int=0, completedPages:int=0)
    {			
      super(type, bubbles, cancelable);
      this.totalPages     = totalPages;
      this.completedPages = completedPages;
    }
  }
}
</pre>
<p>And here the main file that uses this class:</p>
<pre lang="actionscript">
public function createPdf(images:Array):void
{
  var generator:PdfGenerator = new PdfGenerator(images, "/path/to/my/test.pdf");
  generator.addEventListener(PdfGeneratorEvent.PDF_GENERATOR_COMPLETE, this.onPdfComplete);
  generator.addEventListener(PdfGeneratorEvent.PDF_GENERATOR_PAGE_COMPLETE, this.onPdfPageComplete);				
  generator.generate();				
}
			
public function onPdfPageComplete(event:PdfGeneratorEvent):void
{					
  progressBar.setProgress(event.completedPages, event.totalPages);
  progressBar.label = event.completedPages + " of " + event.totalPages;															
}
			
public function onPdfComplete(event:PdfGeneratorEvent):void
{											
  trace("completed")
}
</pre>
