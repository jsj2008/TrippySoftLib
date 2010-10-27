﻿package  {	import flash.display.*;	import flash.net.*;	import flash.events.*;	import flash.geom.*;	import flash.utils.*;	import flash.filesystem.*;	import flash.system.*;	import flash.desktop.*;	import flash.text.engine.RenderingMode;	import flash.text.TextField;		public class ExportMain extends Sprite {		public var settings:XML;				public function ExportMain() {			TSLoader.load("export.xml", loadedExportSettings, URLLoaderDataFormat.TEXT);		}				public function loadedExportSettings(data:String):void {			settings = new XML(data);			TS.initDebuggers(this);						TSLoader.load(settings.target, partiallyLoaded, URLLoaderDataFormat.BINARY);		}				public function partiallyLoaded(data:ByteArray):void {			var loader = new Loader();			var loaderContext:LoaderContext = new LoaderContext();			loaderContext.allowCodeImport = true;						// Kick off Loader.load (instant since bytes are already in memory)			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedSwf);			loader.loadBytes(data, loaderContext);			addChild(loader);		}				public function loadedSwf(e:Event):void {			e.currentTarget.removeEventListener(Event.COMPLETE, loadedSwf);			 			mainSwf = e.target.content;			mainSwf.setReadyForScreenshotsCallback(mainSwfIsReadyForScreenshots);		}				public var mainSwf;				public var screenshotBitmap:Bitmap = new Bitmap(null, PixelSnapping.ALWAYS, false);		public var statusTextField:TextField = new TextField();		public var totalRect:Rectangle;		public var currentRect:Rectangle;		public function mainSwfIsReadyForScreenshots():void {			TS.detachAllChildren(this);						addChild(screenshotBitmap);			addChild(statusTextField);			statusTextField.backgroundColor = 0xFF000000;			statusTextField.textColor = 0xFFFFFFFF;			statusTextField.scaleX = 2.0;			statusTextField.scaleY = 2.0;			statusTextField.width = stage.stageWidth;			statusTextField.height = stage.stageHeight;			statusTextField.multiline = true;						totalRect = new Rectangle(0, 0, mainSwf.getExportTotalWidth(), mainSwf.getExportTotalHeight());			currentRect = new Rectangle(0, 0, mainSwf.getExportStageWidth(), mainSwf.getExportStageHeight());						// do not add ENTER_FRAME event listener to stage, loaded app may already have done so			addEventListener(Event.ENTER_FRAME, saveNextScreenshot);		}				public var byteCountToPreviousFileMapping:Dictionary = new Dictionary();		public var atlasFilenames:Array = new Array();				public function saveNextScreenshot(e:Event):void {			var bitmapData = mainSwf.getScreenshot(currentRect);			screenshotBitmap.bitmapData = bitmapData;						var pngBytes:ByteArray = PNGEnc.encode(bitmapData);						var previousFilename:String = byteCountToPreviousFileMapping[pngBytes.length];			if(previousFilename) {				statusTextField.text = "Processed " + (currentRect.left / currentRect.width) + "-" + 												   (currentRect.top / currentRect.height) + "\nReusing " + previousFilename;								atlasFilenames.push(previousFilename);			} else {				var pngFilename = "" + settings.screenshotPrefix + 												   (currentRect.left / currentRect.width) + "-" + 												   (currentRect.top / currentRect.height) + ".png";				statusTextField.text = "Processed " + (currentRect.left / currentRect.width) + "-" + 												   (currentRect.top / currentRect.height) + "\nCreating " + pngFilename;				var screenshotFile:File = new File("" + settings.screenshotDirectory + pngFilename);				var fs:FileStream = new FileStream();				fs.open(screenshotFile, FileMode.WRITE);				fs.writeBytes(pngBytes);				fs.close();								atlasFilenames.push(pngFilename);				byteCountToPreviousFileMapping[pngBytes.length] = pngFilename;			}						if(currentRect.right < totalRect.right) {				currentRect.offset(currentRect.width, 0.0);			} else {				currentRect.x = 0.0;				currentRect.y = currentRect.top + currentRect.height;			}						if(currentRect.top > totalRect.bottom) {				removeEventListener(Event.ENTER_FRAME, saveNextScreenshot);								statusTextField.text = "Completed screenshot export";								writeTilemap();								removeChild(screenshotBitmap);			}		}				public function writeTilemap():void {			var xml:String = "<tilemap width=\"" + totalRect.width + 							"\" height=\"" + totalRect.height + 							"\" tileWidth=\"" + currentRect.width + 							"\" tileHeight=\"" + currentRect.height + "\">\n";												// write rows:			//<row>(0,-490),(1,26)</row>			var numAcross:int = Math.ceil(totalRect.width / currentRect.width);			var numDown:int = Math.ceil(totalRect.height / currentRect.height);			var atlasIndices:Object = new Object();			var atlases:Array = new Array();						for(var tileY:int = 0; tileY < numDown; ++tileY) {				var row:String = "    <row>";								for(var tileX:int = 0; tileX < numAcross; ++tileX) {					// grab current index					var currentIndex:int = tileX + tileY * numAcross;										// get atlas filename for current index					var atlasFilename = atlasFilenames[currentIndex];										// find out tile index number for atlas filename					var tileIndex = atlasIndices[atlasFilename];										if(!tileIndex) {						// if tile index is null, we should add atlas filename to unique atlas list						// and update the tileIndex for that atlas						atlasIndices[atlasFilename] = atlases.length;						tileIndex = atlases.length;						atlases.push(atlasFilename);					}										row = row + "(" + tileIndex + ",1)";					if(tileX < (numAcross - 1)) row = row + ",";				}								row = row + "</row>\n";				xml = xml + row;			}						// write atlas rows:			//<atlas width="3552" height="3552">level1-foreground-tiles1.png</atlas>			for(var i:int = 0; i < atlases.length; ++i) {				var atlasRow:String = "    <atlas width=\"" + currentRect.width + "\" height=\"" + currentRect.height + "\">";				atlasRow = atlasRow + atlases[i];				atlasRow = atlasRow + "</atlas>\n";				xml = xml + atlasRow;			}						xml = xml + "</tilemap>";						var tilemapFilename:String = "" + settings.screenshotDirectory + settings.screenshotPrefix + "tilemap.xml";			var tilemapFile:File = new File(tilemapFilename);			var fs:FileStream = new FileStream();			fs.open(tilemapFile, FileMode.WRITE);			fs.writeUTFBytes(xml);			fs.close();		}	}}