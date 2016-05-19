package org.lala.utils
{
	import com.adobe.serialization.json.JSON;
	import com.longtailvideo.jwplayer.player.Player;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	
	import org.lala.components.Videoinfo;
	import org.lala.event.EventBus;
	import org.lala.net.CommentServer;
	import org.lala.plugins.CommentView;
	import org.lala.utils.CommentConfig;
	import org.libspark.betweenas3.core.tweens.actions.FunctionAction;

	/** 
	 * 播放器常用方法集
	 * 播放sina视频可以直接调用Player的load方法,因为有SinaMediaProvider
	 * 但是播放youku视频要借用SinaMediaProvider,
	 * 此外还要对视频信息作解析,这些任务顺序可能较为复杂,因此放在该类中,保证主文件的清洁
	 * @author aristotle9
	 **/	
	public class PlayerTool extends EventDispatcher
	{
		/** 所辅助控制的播放器的引用 **/
		private var _player:Player;
		/** 所辅助控制的弹幕插件的引用,主要用来加载弹幕文件 **/
		private var _commentView:CommentView;
		[Bindable]
		private var config:CommentConfig = CommentConfig.getInstance();
		
		public function PlayerTool(p:Player,target:IEventDispatcher=null)
		{
			_player = p;
			_commentView = CommentView.getInstance();
			super(target);
		}
		/**
		 * 播放单个文件,借用SinaMediaProvider,因为控制逻辑与原有的MediaProvider有不同
		 * @param url 视频文件的地址
		 **/
		public function loadSingleFile(url:String):void
		{
			_player.load(
				{   type:'sina',
					file:'videoInfo',
					videoInfo:{length:0,
						items:[
							{'url':url,length:0}
						]
					}
				});
		}
		private function errorHandler(event:Event):void
		{
			log(String(event));
		}		
		
		//load
		public function loadVideo(type:String,vid:String):void
		{
			var infoLoader:URLLoader = new URLLoader();
			infoLoader.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			infoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			var nowload:String=type+"LoaderComplete";
			try
			{
				infoLoader.addEventListener(Event.COMPLETE,this[nowload] as Function );
			}
			catch(error:Error)
			{
				Alert.show('不支持的视频:'+error);
			}
			var infoUrl:String = 'http://www.wahu.tc/Play/loadvideo/' + vid;
			infoLoader.load(new URLRequest(infoUrl));
		}	
		//youku
		private function youkuLoaderComplete(event:Event):void
		{			
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,youkuLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;
			try
			{
				var info:Object = parseYoukuInfo(loader.data as String);
				_player.load(
					{   type:'sina',
						file:'videoInfo',
						videoInfo:info
					});	
			}
			catch(error:Error)
			{
				Alert.show('Youku视频信息解析失败:'+error);
			}
		}
		private function parseYoukuInfo(src:String):Object
		{
			var tudouXML:XML = (XML)(src);
			var totle:Number=0;
			var ifs:Array = [];
			if(tudouXML){
				for(var i:int=tudouXML.video.length();i--;i>0){
					if(tudouXML.video[i].quality=="高清"){
						var v_info:Object=xmlarray(tudouXML.video[i]);	
						break;
					}else if(tudouXML.video[i].quality=="FLV高清"){
						var v_info:Object=xmlarray(tudouXML.video[i]);	
						break;
					}else if(tudouXML.video[i].quality=="mp4"){
						var v_info:Object=xmlarray(tudouXML.video[i]);	
						break;				
					}
				}
				return v_info;
			}else{
				Alert.show("视频加载出错");
				return null;
			}
			
		}		
		//tudou
		private function tudouLoaderComplete(event:Event):void
		{			
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,tudouLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;
			try
			{
				var info:Object = parseTudouInfo(loader.data as String);
				_player.load(
					{   type:'sina',
						file:'videoInfo',
						videoInfo:info
					});	
			}
			catch(error:Error)
			{
				Alert.show('视频信息解析失败:'+error);
			}
		}
		private function parseTudouInfo(src:String):Object
		{
			var tudouXML:XML = (XML)(src);
			var totle:Number=0;
			var ifs:Array = [];
			if(tudouXML.video){
				for(var a:int=tudouXML.video.length();a--;a>0){
				   if(tudouXML.video[a].quality=="超清MP4"){	
					   var v_info:Object=xmlarray(tudouXML.video[a]);	
						break;
					}else if(tudouXML.video[a].quality=="FLV高清"){
						var v_info:Object=xmlarray(tudouXML.video[a]);	
						break;	
					}else if(tudouXML.video[a].quality=="高清"){				
						var v_info:Object=xmlarray(tudouXML.video[a]);	
						break;
					}else if(tudouXML.video[a].quality=="标清"){				
						var v_info:Object=xmlarray(tudouXML.video[a]);	
						break;
					}
				}
				return v_info;
			}else{
				Alert.show("视频加载出错");
				return null;
			}
		}				
		//qq		
		private function qqLoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,qqLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;	
			var tudouXML:XML = (XML)(loader.data);
			try{
				for(var i:int=tudouXML.video.length();i--;){
					if(tudouXML.video[i].quality=="单文件"){
						loadSingleFile(tudouXML.video[i].files.file.furl.text());
						break;
					}
				}
			
			}catch(error:Error){
				Alert.show("视频加载出错");
			}
		}
		//xunlei	
		private function xunleiLoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,xunleiLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;	
			var tudouXML:XML = (XML)(loader.data);
			try{
				if(tudouXML.video[0].files.file.furl){
					loadSingleFile(tudouXML.video[0].files.file.furl.text());
				}else{
					Alert.show("视频不存在");	
				}

			}catch(error:Error){
				Alert.show("视频加载出错");
			}
		}		
		//56
		private function wu6LoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,wu6LoaderComplete);
			var loader:URLLoader = event.target as URLLoader;	
			var tudouXML:XML = (XML)(loader.data);
			try{
				for(var i:int=0;i<tudouXML.video.length();i++){
					if(tudouXML.video[i].quality=="super"){
						loadSingleFile(tudouXML.video[i].files.file.furl.text());
					}
				}
				
			}catch(error:Error){
				Alert.show("视频加载出错");
			}
		}		
		//Ku6
		private function ku6LoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,ku6LoaderComplete);
			var loader:URLLoader = event.target as URLLoader;	
			try{
				var info:Object = parseku6Info(loader.data as String);	
				_player.load(
					{   type:'sina',
						file:'videoInfo',
						videoInfo:info
					});			
			}
			catch(error:Error)
			{
				log('ku6视频信息解析失败:'+error);
			}
		}				
		private function parseku6Info(src:String):Object
		{
			var tudouXML:XML = (XML)(src);
			var totle:Number=0;
			var ifs:Array = [];
			if(tudouXML.video){
			 	for(var i:int=0;i<tudouXML.video.files.file.length();i++){
					var v_info:Object=xmlarray(tudouXML.video[i]);				
			 	}
				return v_info;	
			}else{
				return null;
			}
		}
		//sina
		private function sinaLoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,sinaLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;
			var tudouXML:XML = (XML)(loader.data);
			if(tudouXML.video){
				try{
					for(var i:int=0;i<tudouXML.video.length();i++){
						if(tudouXML.video[i].quality=="MP4"){
							loadSingleFile(tudouXML.video[i].files.file.furl.text());
							break;					
						}else if(tudouXML.video[i].site=="新浪网"){
							loadSingleFile(tudouXML.video[i].files.file.furl.text());
							break;					
						}else{
							Alert.show("视频加载出错,请尝试刷新");
						}
						
					}
				}catch(error:Error){
					Alert.show("视频加载出错");
				}
			}else{
				Alert.show("获取视频出错");
			}
		}	
		//bilibili
		private function biliLoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,biliLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;
			var tudouXML:XML = (XML)(loader.data);
			try{
				loadSingleFile(tudouXML.video.files.file.furl.text());
			}
			catch(error:Error)
			{
				Alert.show('bili视频信息解析失败:'+error);
			}
		}		
		//letv
		private function letvLoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,letvLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;
			var tudouXML:XML = (XML)(loader.data);
			try{
				for(var i:int=tudouXML.video.length();i--;){
					if(tudouXML.video[i].quality=="1080P"){
						loadSingleFile(tudouXML.video[i].files.file.furl.text());
						break;
					}else if(tudouXML.video[i].quality=="720P"){
						loadSingleFile(tudouXML.video[i].files.file.furl.text());
						break;					
					}else if(tudouXML.video[i].quality=="高清"){
						loadSingleFile(tudouXML.video[i].files.file.furl.text());
						break;					
					}else if(tudouXML.video[i].quality=="标清"){
						loadSingleFile(tudouXML.video[i].files.file.furl.text());
						break;					
					}else{
						Alert.show("视频加载出错");
					}
				}
			}catch(error:Error){
				Alert.show("视频加载出错");
			}
		}	
		//pps
		private function ppsLoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,ppsLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;
			var tudouXML:XML = (XML)(loader.data);
			try{
				for(var i:int=tudouXML.video.length();i--;){
					if(tudouXML.video[i].quality=="高清"){
						loadSingleFile(tudouXML.video[i].files.file.furl.text());
						break;
					}else if(tudouXML.video[i].quality=="标清"){
						loadSingleFile(tudouXML.video[i].files.file.furl.text());
						break;
					}else{
						Alert.show("视频加载出错");
					}
				}
			}catch(error:Error){
				Alert.show("视频加载出错");
			}
		}	
		//17173
		private function yi7173LoaderComplete(event:Event):void
		{			
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,yi7173LoaderComplete);
			var loader:URLLoader = event.target as URLLoader;
			try
			{
				var info:Object = parseyi7173Info(loader.data as String);
				_player.load(
					{   type:'sina',
						file:'videoInfo',
						videoInfo:info
					});	
			}
			catch(error:Error)
			{
				Alert.show('视频信息解析失败:'+error);
			}
		}
		private function parseyi7173Info(src:String):Object
		{
			var tudouXML:XML = (XML)(src);
			var totle:Number=0;
			var ifs:Array = [];
			if(tudouXML.video){
				for(var i:int=0;i<tudouXML.video.length();i++){
					if(tudouXML.video[i].site=="搜狐视频"){				
						for(var b:int=0;b<tudouXML.video[i].files.file.length();b++){
							totle+=parseInt(tudouXML.video[i].files.file[b].time.text())*65000;
							ifs.push({ 
								url:tudouXML.video[i].files.file[b].furl.text(),
								length:parseInt(tudouXML.video[i].files.file[b].time.text())*65000,
								id:b + 1
							});
						}	
						break;
					}
				}
				return {
					length:totle,
					items:ifs
				};
			}else{
				return null;
				Alert.show("视频加载出错");
			}
			
		}			
		//sohu
		private function sohuLoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,sohuLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;	
			try{
				var info:Object = parsesohuInfo(loader.data as String);	
				_player.load(
					{   type:'sina',
						file:'videoInfo',
						videoInfo:info
					});			
			}
			catch(error:Error)
			{
				log('Sohu视频信息解析失败:'+error);
			}
		}				
		private function parsesohuInfo(src:String):Object
		{
			var tudouXML:XML = (XML)(src);
			var totle:Number=0;
			var ifs:Array = [];
			if(tudouXML.video){
				for(var i:int=tudouXML.video.length();i--;i>0){
					if(tudouXML.video[i].quality=="超清"){
						var v_info:Object=xmlarray(tudouXML.video[i]);	
						break;
					}if(tudouXML.video[i].quality=="高清"){
						var v_info:Object=xmlarray(tudouXML.video[i]);	
						break;
					}if(tudouXML.video[i].quality=="普清"){
						var v_info:Object=xmlarray(tudouXML.video[i]);	
						break;
					}
				}
				return v_info;
			}else{
				return null;
			}
		}		
		//iqiyi
		private function iqiyiLoaderComplete(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			event.target.removeEventListener(Event.COMPLETE,iqiyiLoaderComplete);
			var loader:URLLoader = event.target as URLLoader;	
			try{
				var info:Object = parseiqiyiInfo(loader.data as String);	
				_player.load(
					{   type:'sina',
						file:'videoInfo',
						videoInfo:info
					});			
			}
			catch(error:Error)
			{
				log('Sohu视频信息解析失败:'+error);
			}
		}				
		private function parseiqiyiInfo(src:String):Object
		{
			var tudouXML:XML = (XML)(src);
			var totle:Number=0;
			var ifs:Array = [];
			if(tudouXML.video){			
				for(var i:int=tudouXML.video.length();i--;i>0){
				  	if(tudouXML.video[i].quality=="极清"){
						var v_info:Object=xmlarray(tudouXML.video[i]);
						break;
					}else if(tudouXML.video[i].quality=="超清"){
						var v_info:Object=xmlarray(tudouXML.video[i]);
						break;
					}else if(tudouXML.video[i].quality=="高清"){
						var v_info:Object=xmlarray(tudouXML.video[i]);
						break;
					}
				}
				return v_info;
			}else{
				return null;
				Alert.show("视频加载出错");
			}
		}		
		private function takeseconds(xxxx:String):Number{
			var arr:Array=xxxx.split(":");
			var fenzhong:int=arr[0]*60;
			if(xxxx){
				var seconds:Number=Number(fenzhong)+Number(arr[1]);
			}else{
				seconds=300;
			}
			return seconds;
		}
		private function xmlarray(xmlvideo:XML):Object{
			var tudouXML:XML = (XML)(xmlvideo);
			var totle:Number=0;
			var ifs:Array = [];
			if(tudouXML.video){			
				for(var c:int=0;c<tudouXML.files.file.length();c++){
					var xxxx:String=tudouXML.files.file[c].time;
					var times:Number=takeseconds(xxxx);
					totle+=times*1000;
					ifs.push({ 
						url:tudouXML.files.file[c].furl.text(),
						length:times*1000,
						id:c + 1
					});
				}	
				return {
					length:totle,
					items:ifs
				};
			}else{
				return null;
				Alert.show("无法解析视频");
			}
		}		
		/**
		 * 加载一般弹幕文件
		 * @params url 弹幕文件地址
		 **/
		public function loadCmtFile(url:String):void
		{
			_commentView.loadComment(url);
		}
		/**
		 * 加载AMF弹幕文件
		 * @params server 弹幕服务器
		 **/
		public function loadCmtData(server:CommentServer):void
		{
			_commentView.provider.load('',CommentFormat.AMFCMT,server);
		}
		//以下两个函数在代理测试时使用        
		/**
		 * 加载bili弹幕文件
		 * @params cid 弹幕id
		 **/
		public function loadBiliFile(cid:String):void
		{
			loadCmtFile('http://www.bilibili.us/dm,' + cid + '?r=' + Math.ceil(Math.random() * 1000));
		}
		/**
		 * 加载acfun弹幕文件
		 * @params cid 弹幕id
		 **/
		public function loadAcfunFile(cid:String):void
		{
			loadCmtFile('http://124.228.254.234/newflvplayer/xmldata/' + cid + '/comment_on.xml?r=' + Math.random());
		}
		private function log(message:String):void
		{
			EventBus.getInstance().log(message);
		}
	}
}