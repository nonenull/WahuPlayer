package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.controller.RepeatOptions;
	import com.longtailvideo.jwplayer.player.PlayerVersion;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.longtailvideo.jwplayer.utils.TypeChecker;
	
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	/**
	 * Configuration data for the player
	 *
	 * @author Pablo Schklowsky
	 */
	public dynamic class PlayerConfig extends EventDispatcher {
		protected var _singleItem:PlaylistItem = new PlaylistItem();

		protected var _playlistfile:String	= null;

		protected var _autostart:Boolean 	= true; 
		protected var _bandwidth:Number		= 1500;
		protected var _bufferlength:Number 	= 2; 
		protected var _displaytitle:Boolean = true; 
		protected var _fullscreen:Boolean 	= false;
		protected var _item:Number			= 0;
		protected var _linktarget:String 	= "_blank";
		protected var _levels:Array			= null;
		protected var _mute:Boolean 		= false;
		protected var _repeat:String 		= RepeatOptions.NONE; 
		protected var _shuffle:Boolean 		= false; 
		protected var _smoothing:Boolean 	= true;
		
		//TODO: Move to ENUM class
		protected var _stretching:String 	= "uniform"; 
		protected var _volume:Number 		= 90;

		protected var _backcolor:Color		= null;
		protected var _frontcolor:Color		= null;
		protected var _lightcolor:Color		= null;
		protected var _screencolor:Color	= null;

		//TODO: Move to ENUM class
		protected var _controlbar:String 	= "bottom";
		protected var _dock:Boolean 		= true;
		protected var _height:Number 		= 400;
		protected var _icons:Boolean 		= true;
		protected var _logo:String 			= null;
		protected var _playlist:String 		= "none";
		protected var _playlistsize:String 	= "180";
		protected var _skin:String 			= null;
		protected var _width:Number 		= 280;
		
		protected var _plugins:String   = ""; //plugins initial string
		protected var _pluginConfig:Object 	= {};
		
		protected var _id:String			= "";
		protected var _playerready:String	= "";
		protected var _debug:String			= Logger.NONE;
		
		public function PlayerConfig():void {
			controlbar = _controlbar;
			playlist = _playlist;
			playlistsize = _playlistsize;
			logo = _logo;
		}
		
		public function setConfig(config:Object):void {
			for (var item:String in config) {
				if (item.indexOf(".") > 0) {
					setPluginProperty(item, config[item]);
					_singleItem[item.toLowerCase()] = config[item];
				} else if (_singleItem.hasOwnProperty(item)) {
					if (item == "file" && Strings.extension(config[item]) == "xml" && !(config['provider'])) {
						setProperty("playlistfile", config[item]);					
					} else if (item == "levels" && config[item] is Array) {
						for (var i:Number = 0; i < (config[item] as Array).length; i++) {
							var level:Object = config[item][i];
							_singleItem.addLevel(new PlaylistItemLevel(level.file, level.bitrate, level.width, level.streamer));
						}
					} else {
						_singleItem[item.toLowerCase()] = config[item];
					}
				} else if (config[item.toLowerCase()] != null) {
					setProperty(item, config[item]);
				}
			}
		}
		
		protected function setProperty(name:String, value:*):void {
			if (hasOwnProperty(name) && value is String) {
				try {
					this[name] = TypeChecker.fromString(value, TypeChecker.getType(this, name));
				} catch (e:Error) {
					// 'name' was a read-only property
				}
			} else {
				this[name] = value;
			}
		}

		/**
		 * Sets the value of a plugin config property 
		 * @param name The parameter name in the form "pluginId.propertyname"
		 * @param value The value to set.
		 */
		protected function setPluginProperty(name:String, value:*):void {
			var pluginId:String = name.substring(0, name.indexOf(".")).toLowerCase();
			var pluginProperty:String = name.substring(name.indexOf(".") + 1, name.length).toLowerCase();

			if (pluginId && pluginProperty) {
				if (!_pluginConfig.hasOwnProperty(pluginId)) {
					_pluginConfig[pluginId] = new PluginConfig(pluginId);
				}
				if (value is String) {
					_pluginConfig[pluginId][pluginProperty] = TypeChecker.fromString(value);
				} else {
					_pluginConfig[pluginId][pluginProperty] = value;
				}
			}
		}

		/**
		 * Returns a string representation of the playlist's current PlaylistItem property.
		 * @param key The requested PlaylistItem property
		 */
		protected function playlistItem(key:String):String {
			try {
				return _singleItem[key].toString();
			} catch (e:Error) {
			}

			return "";
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// PLAYLIST PROPERTIES
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/** Location of xml playlist file to load **/
		public function get playlistfile():String { return _playlistfile; }
		public function set playlistfile(x:String):void { 
			_playlistfile = x; 
		}


		/** Author of the video, shown in the display or playlist. **/
		public function get author():String { return playlistItem('author'); }

		/** Publish date of the media file. **/
		public function get date():String { return playlistItem('date'); }

		/** Text description of the file. **/
		public function get description():String { return playlistItem('description'); }

		/** Duration of the file in seconds. **/
		public function get duration():String { return playlistItem('duration'); }

		/** Location of the mediafile or playlist to play. **/
		public function get file():String { return playlistItem('file'); }

		/** Location of a preview image; shown in display and playlist. **/
		public function get image():String { return playlistItem('image'); }
		
		/** URL to an external page the display, controlbar and playlist can link to. **/
		public function get link():String { return playlistItem('link'); }

		/** Unique identifier for media content. **/		
		public function get mediaid():String { return playlistItem('mediaid'); }		
		
		/** Position in seconds where playback has to start. Won't work for regular (progressive) videos, but only for streaming (HTTP / RTMP). **/
		public function get start():String { return playlistItem('start'); }
		
		/** Location of an rtmp/http server instance to use for streaming. Can be an RTMP application or external PHP/ASP file. **/
		public function get streamer():String { return playlistItem('streamer'); }
		
		/** Keywords associated with the media file. **/
		public function get tags():String { return playlistItem('tags'); }

		/** Title of the video, shown in the display or playlist. **/
		public function get title():String { return playlistItem('title'); }

		/**
		 * By default, the type is detected by the player based upon the file extension. If there's no suitable
		 * extension or the player detects the type wrong, it can be manually set. The following default types are
		 * supported:
		 * <ul>
		 * <li>video: progressively downloaded FLV / MP4 video, but also AAC audio.</li>
		 * <li>sound: progressively downloaded MP3 files.</li>
		 * <li>image: JPG/GIF/PNG images.</li>
		 * <li>youtube: videos from Youtube.</li>
		 * <li>http: FLV/MP4 videos played as http speudo-streaming.</li>
		 * <li>rtmp: FLV/MP4/MP3 files played from an RTMP server.</li>
		 * </ul>
		 **/
		public function get provider():String { return playlistItem('provider'); }

		/** Deprecated.  Use "provider" flashvar. **/
		public function get type():String { return playlistItem('provider'); }

		/** PlaylistItem representing single-item playlist based on flashvars (e.g. config[file], config[image], etc. **/
		public function get singleItem():PlaylistItem { return _singleItem; }

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// LAYOUT PROPERTIES
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/** Background color of the controlbar and playlist. This is white with the default skin. **/
		public function get backcolor():Color { return _backcolor; }
		public function set backcolor(x:Color):void { _backcolor = x; }
		
		/** Color of all icons and texts in the controlbar and playlist. **/
		public function get frontcolor():Color { return _frontcolor; }
		public function set frontcolor(x:Color):void { _frontcolor = x; }

		/** Color of an icon or text when you rollover it with the mouse. **/
		public function get lightcolor():Color { return _lightcolor; }
		public function set lightcolor(x:Color):void { _lightcolor = x; }

		/** Background color of the display. **/
		public function get screencolor():Color { return _screencolor; }
		public function set screencolor(x:Color):void { _screencolor = x; }

		/** Position of the controlbar. Can be set to top, bottom, over and none.  @default bottom **/
		public function get controlbar():String { 
			if (_pluginConfig['controlbar'] && _pluginConfig['controlbar'].hasOwnProperty('position'))
				return _pluginConfig['controlbar']['position'];
			else return _controlbar;
		}
		public function set controlbar(x:String):void { 
			setPluginProperty('controlbar.position', x.toLowerCase()); 
		}

		/** Set this to true to show the dock with large buttons in the top right of the player. Available since 4.5.  @default true **/
		public function get dock():Boolean { return _dock; }
		public function set dock(x:Boolean):void {
			_dock = x;
		}

		/** Height of the display in pixels. @default 280 **/
		public function get height():Number { return _height; }
		public function set height(x:Number):void { _height = x; }

		/** Set this to false to hide the play button and buffering icon in the middle of the video. Available since 4.2.  @default true **/
		public function get icons():Boolean { return _icons; }
		public function set icons(x:Boolean):void { _icons = x; }

		/** Location of an external jpg, png or gif image to show in a corner of the display. With the default skin, this is top-right, but every skin can freely place the logo. **/
		public function get logo():String { 
			if (_pluginConfig['logo'] &&  _pluginConfig['logo'].hasOwnProperty('file'))
				return _pluginConfig['logo']['file'];
			else return _logo;
		}
		public function set logo(x:String):void {
			if (x != null) {
				setPluginProperty('logo.file', x.toLowerCase());
			}
		}

		/** Position of the playlist. Can be set to bottom, over, right or none. @default none **/
		public function get playlist():String { 
			if (_pluginConfig['playlist'] && _pluginConfig['playlist'].hasOwnProperty('position'))
				return _pluginConfig['playlist'] && _pluginConfig['playlist']['position'];
			else return _playlist;
		}
		public function set playlist(x:String):void { 
			setPluginProperty('playlist.position', x.toLowerCase()); 
		}

		/** When below this refers to the height, when right this refers to the width of the playlist. @default 180 **/
		public function get playlistsize():String { return _playlistsize; }
		public function set playlistsize(x:String):void {
			_playlistsize = x;
			setPluginProperty('playlist.size', x.toString());
		}

		/** 
		 * Location of a SWF or ZIP file with the player graphics. The player skinning documentation gives more info on this.  
		 * SVN contains a couple of example skins. 
		 **/
		public function get skin():String { return _skin; }
		public function set skin(x:String):void { _skin = x; }

		/** Width of the display in pixels. @default 400 **/
		public function get width():Number { return _width; }
		public function set width(x:Number):void { _width = x; }

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// BEHAVIOR PROPERTIES
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/** Automatically start the player on load. @default false **/
		public function get autostart():Boolean { return _autostart; }
		public function set autostart(x:Boolean):void { _autostart = x; }

		/** Automatically start the player on load. @default false **/
		public function get bandwidth():Number { return _bandwidth; }
		public function set bandwidth(x:Number):void { _bandwidth = x; }

		/** 
		 * Number of seconds of the file that has to be loaded before starting. Set this to a low value to enable instant-start and to a 
		 * high value to get less mid-stream buffering. 
		 * @default 1
		 **/
		public function get bufferlength():Number { return _bufferlength; }
		public function set bufferlength(x:Number):void { _bufferlength = x; }

		/** Set this to true to print the title of a video in the display. @default true **/
		public function get displaytitle():Boolean { return _displaytitle; }
		public function set displaytitle(x:Boolean):void { _displaytitle = x; }

		/** Current fullscreen state **/		
		public function get fullscreen():Boolean { return _fullscreen; }
		public function set fullscreen(x:Boolean):void { _fullscreen = x; }		
		
		/** PlaylistItem that should start to play. Use this to set a specific start-item. @default 0 **/
		public function get item():Number { return _item; }
		public function set item(x:Number):void { _item = x; }

		/** Browserframe where link from the display are opened in. Some possibilities are '_self' (same frame) or '_blank' (new browserwindow). @default _blank **/
		public function get linktarget():String { return _linktarget; }
		public function set linktarget(x:String):void { _linktarget = x; }
		
		/** Mute all sounds on startup. This value is set in a user cookie, and is retrieved the next time the player loads. **/
		public function get mute():Boolean { return _mute; }
		public function set mute(x:Boolean):void { _mute = x;}

		/** Set to list to play the entire playlist once, to always to continously play the song/video/playlist and to single to continue repeating the selected file in a playlist. @default none **/
		public function get repeat():String { return _repeat; }
		public function set repeat(x:String):void { _repeat = x.toLowerCase(); }

		/** Shuffle playback of playlist items. @default false **/
		public function get shuffle():Boolean { return _shuffle; }
		public function set shuffle(x:Boolean):void { _shuffle = x; }

		/** this sets the smoothing of videos, so you won't see blocks when a video is upscaled. Set this to false to get performance improvements with old computers / big files. Available since 4.4. @default false **/
		public function get smoothing():Boolean { return _smoothing; }
		public function set smoothing(x:Boolean):void { _smoothing = x; }

		/** Defines how to resize images in the display. Can be none (no stretching), exactfit (disproportionate), uniform (stretch with black borders) or fill (uniform, but completely fill the display). @default uniform **/
		public function get stretching():String{ return _stretching; }
		public function set stretching(x:String):void { _stretching = x.toLowerCase(); }

		/** Startup volume of the player. Can be 0 to 100. Is saved in a cookie. @default 90 **/
		public function get volume():Number { return _volume; }
		public function set volume(x:Number):void { _volume = x; }

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// PLUGINS
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/** Which plugins to load **/		
		public function get plugins():String { return _plugins; }
		public function set plugins(x:String):void { _plugins = x; }

		/** The current debugging mode. **/		
		public function get debug():String {
			return _debug;
		}

		public function set debug(x:String):void {
			if (x != "0"){
				_debug = x; 
			}
		}
		
		/**
		 * Returns a PluginConfig containing plugin configuration information
		 * 
		 * @param pluginId Name of the plugin whose config to return.
		 */
		public function pluginConfig(pluginId:String):PluginConfig {
			pluginId = pluginId.toLowerCase();
			if (_pluginConfig.hasOwnProperty(pluginId)) {
				return _pluginConfig[pluginId] as PluginConfig;
			} else if (this[pluginId] && getQualifiedClassName(this[pluginId]) == "Object") {
				var duplicatedConfig:PluginConfig = new PluginConfig(pluginId, this[pluginId]);
				_pluginConfig[pluginId] = duplicatedConfig;
				return duplicatedConfig;
			} else {
				var newConfig:PluginConfig = new PluginConfig(pluginId);
				_pluginConfig[pluginId] = newConfig;
				return newConfig;
			}
		}
		
		/** A list of available pluginConfig keys. **/
		public function get pluginIds():Array {
			var names:Array = [];

			// Only include loaded plugins
			for each (var lp:String in _plugins.split(",")) {
				var plugName:String = (lp.substr(lp.lastIndexOf("/")+1).replace(/(.*)\.swf$/i, "$1").split("-")[0] as String).toLowerCase();
				if (plugName) {
					names.push(plugName);
				}
			}
			
			return names;
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// JAVASCRIPT INTERACTION
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/** The player's Javascript objectID. Auto-detected, but should be set manually for Linux Javascript support. **/
		public function get id():String { return _id; }
		public function set id(x:String):void { PlayerVersion.id = _id = x; }
		
		/** Javascript player ready callback handlers **/		
		public function get playerready():String { return _playerready; }
		public function set playerready(x:String):void { _playerready = x; }
		
		
	}
}
