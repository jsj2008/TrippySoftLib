﻿package {	import flash.display.*;	import flash.events.*;	import flash.net.*;	import flash.geom.*;	import flash.utils.*;	public class TSLoader {		public static var baseURL:String = "";		public static var loaderCompleteCallbacks:Dictionary = new Dictionary();		public static var errors:Array = new Array();		public static var loadersToUrls:Dictionary = new Dictionary();				public static var loadersToStart:Array = new Array();		public static var activeLoader:URLLoader = null;				public static function load(fileName:String, completeCallback:Function = null, format:String = null):void {			fileName = fileName.split("\r").join().split("\n").join();						var urlLoader:URLLoader = new URLLoader();			urlLoader.dataFormat = format == null ? URLLoaderDataFormat.BINARY : format;						loaderCompleteCallbacks[urlLoader] = completeCallback;			loadersToUrls[urlLoader] = baseURL + fileName;						urlLoader.addEventListener(Event.COMPLETE, doneLoading);			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError);			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);						TS.log("Requested " + baseURL + fileName);						if(activeLoader == null) {				urlLoader.load(new URLRequest(baseURL + fileName));				activeLoader = urlLoader;			}			else {				loadersToStart.push(urlLoader);			}		}				public static function removeEventListeners(urlLoader:URLLoader):void {			urlLoader.removeEventListener(Event.COMPLETE, doneLoading);			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioError);			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);			delete loaderCompleteCallbacks[urlLoader];			delete loadersToUrls[urlLoader];						if(loadersToStart.length > 0) {				var newLoader = loadersToStart.pop();				newLoader.load(new URLRequest(loadersToUrls[newLoader]));				activeLoader = newLoader;			}			else {				activeLoader = null;			}		}				public static function securityError(e:SecurityErrorEvent):void {			TS.log("SecurityError: " + e.text);						errors.push("SecurityError: " + e.text);			removeEventListeners(e.target as URLLoader);		}				public static function ioError(e:IOErrorEvent):void {			TS.log("When loading " + loadersToUrls[e.target] + " got an");			TS.log("IOError: " + e);						errors.push("IOError: " + e.text);			removeEventListeners(e.target as URLLoader);		}				public static function getProgress():Number {			var bytesTotal:uint = 0;			var bytesLoaded:uint = 0;			var numberOfLoaders:uint = 0;						for (var urlLoader in loaderCompleteCallbacks) {				bytesLoaded += urlLoader.bytesLoaded;				bytesTotal += urlLoader.bytesTotal;				numberOfLoaders++;			}						if(numberOfLoaders == 0) return 1.01;			if(bytesTotal == 0) return 0.0;			return bytesLoaded / bytesTotal;		}				public static var fractionComplete:Number = 0.0;				public static function doneLoading(e:Event):void {			TS.log("Loaded " + loadersToUrls[e.target]);						var completeCallback:Function = loaderCompleteCallbacks[e.target];			removeEventListeners(e.target as URLLoader);			completeCallback(e.target.data);		}	}}