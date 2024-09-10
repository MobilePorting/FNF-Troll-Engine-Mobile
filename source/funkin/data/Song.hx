package funkin.data;

import moonchart.backend.FormatData.Format;
#if(moonchart)
import moonchart.formats.fnf.legacy.FNFPsych as SupportedFormat;
import moonchart.formats.BasicFormat;
import moonchart.backend.FormatDetector;
#end

import funkin.states.LoadingState;
import funkin.states.PlayState;
import funkin.data.Section.SwagSection;
import haxe.io.Path;
import haxe.Json;

using StringTools;

typedef SwagSong =
{
	//// internal
	@:optional var path:String;
	@:optional var validScore:Bool;

	////
	@:optional var song:String;
	@:optional var bpm:Float;
	@:optional var speed:Float;
	@:optional var notes:Array<SwagSection>;
	@:optional var events:Array<Array<Dynamic>>;
	
	@:optional var tracks:SongTracks; // currently used
	@:noCompletion @:optional var extraTracks:Array<String>; // old te
	@:noCompletion @:optional var needsVoices:Bool; // fnf

	@:optional var player1:String;
	@:optional var player2:String;
	@:optional var player3:String;
	@:optional var gfVersion:String;
	@:optional var stage:String;
    @:optional var hudSkin:String;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
	
	//// Used for song info showed on the pause menu
	@:optional var info:Array<String>;
	@:optional var metadata:SongCreditdata;
}

typedef SongTracks = {
	var inst:Array<String>;
	var ?player:Array<String>;
	var ?opponent:Array<String>;
} 

typedef SongCreditdata = // beacuse SongMetadata is stolen
{
	?artist:String,
	?charter:String,
	?modcharter:String,
	?extraInfo:Array<String>,
}

class Song
{
	public static function getCharts(metadata:SongMetadata):Array<String>
	{
		Paths.currentModDirectory = metadata.folder;
		final songName = Paths.formatToSongPath(metadata.songName);
		final charts = new haxe.ds.StringMap();
		
		function processFileName(unprocessedName:String)
		{		
			var fileName:String = unprocessedName.toLowerCase();
            if (fileName == '$songName.json'){
				charts.set("normal", true);
				return;
			}
			else if (!fileName.startsWith('$songName-') || !fileName.endsWith('.json')){
				return;
			}

			final extension_dot = songName.length + 1;
			charts.set(fileName.substr(extension_dot, fileName.length - extension_dot - 5), true);
		}


		if (metadata.folder == "")
		{
			#if PE_MOD_COMPATIBILITY
			Paths.iterateDirectory(Paths.getPreloadPath('data/$songName/'), processFileName);
			#end
			Paths.iterateDirectory(Paths.getPreloadPath('songs/$songName/'), processFileName);
		}
		#if MODS_ALLOWED
		else
		{
			#if PE_MOD_COMPATIBILITY
			Paths.iterateDirectory(Paths.mods('${metadata.folder}/data/$songName/'), processFileName);
			#end
			Paths.iterateDirectory(Paths.mods('${metadata.folder}/songs/$songName/'), processFileName);
		}
		#end

		return [for (name in charts.keys()) name];
	}

	public static function loadFromJson(jsonInput:String, folder:String, ?isSongJson:Bool = true):Null<SwagSong>
	{
		var path:String = Paths.formatToSongPath(folder) + '/' + Paths.formatToSongPath(jsonInput) + '.json';
		var fullPath = Paths.getPath('songs/$path', false);
		
		#if PE_MOD_COMPATIBILITY
		if (!Paths.exists(fullPath))
			fullPath = Paths.getPath('data/$path', false);
		#end

		var rawJson:Null<String> = Paths.getContent(fullPath);
		if (rawJson == null){
			trace('song JSON file not found: $path');
			return null;
		}
		
		// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		rawJson = rawJson.trim();
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		var songJson:SwagSong = parseJSONshit(rawJson);
		songJson.path = fullPath; 
		if (isSongJson != false) onLoadJson(songJson);

		return songJson;
	}

	public static function onLoadEvents(songJson:Dynamic){
		if(songJson.events == null){
			songJson.events = [];
			
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				var i:Int = 0;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if (note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}

		return songJson;
	}

	/** sanitize/update json values to a valid format**/
	private static function onLoadJson(songJson:Dynamic)
	{
		var swagJson:SwagSong = songJson;

		onLoadEvents(swagJson);

		////
		if (songJson.gfVersion == null){
			if (songJson.player3 != null){
				songJson.gfVersion = songJson.player3;
				songJson.player3 = null;
			}
			else
				songJson.gfVersion = "gf";
		}
		
		//// new tracks system
		if (swagJson.tracks == null) {
			var instTracks:Array<String> = ["Inst"];

			if (swagJson.extraTracks != null) {
				for (name in swagJson.extraTracks)
					instTracks.push(name);
			}

			////
			var playerTracks:Array<String> = null;
			var opponentTracks:Array<String> = null;

			/**
			 * If 'needsVoices' is false, no tracks will be defined for the player or opponent
			 * If the chart folder couldn't be retrieved then "Voices-Player" and "Voices-Opponent" are used
			 * If a "Voices-Player" exists then it is defined as a player track, otherwise "Voices" is used
			 * If a "Voices-Opponent" exists then it is defined as an opponent track, otherwise "Voices" is used
			 */
			inline function sowy() {
				//// 1
				if (!swagJson.needsVoices) {
					playerTracks = [];
					opponentTracks = [];
					return false;
				}

				//// 2
				if (swagJson.path==null) return true;
				var jsonPath:Path = new Path(swagJson.path);

				var folderPath = jsonPath.dir;
				if (folderPath == null) return true; // probably means that it's on the same folder as the exe but fuk it

				//// 3 and 4
				inline function existsInFolder(name)
					return Paths.exists(Path.join([folderPath, name]));

				var defaultVoices = existsInFolder('Voices.ogg') ? ["Voices"] : [];

				inline function voiceTrack(name)
					return existsInFolder('$name.ogg') ? [name] : defaultVoices;
				
				playerTracks = voiceTrack("Voices-Player");
				opponentTracks = voiceTrack("Voices-Opponent");
				return false;
			}
			if (sowy()) {
				playerTracks = ["Voices-Player"];
				opponentTracks = ["Voices-Opponent"];
			}

			////
			swagJson.tracks = {inst: instTracks, player: playerTracks, opponent: opponentTracks};
		}

		////
		if (swagJson.arrowSkin == null || swagJson.arrowSkin.trim().length == 0)
			swagJson.arrowSkin = "NOTE_assets";

		if (swagJson.splashSkin == null || swagJson.splashSkin.trim().length == 0)
			swagJson.splashSkin = "noteSplashes";

		if (songJson.hudSkin==null)
			songJson.hudSkin = 'default';

		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}

    #if moonchart
	public static var moonchartExtensions(get, null):Array<String> = [];
    static function get_moonchartExtensions(){
		if (moonchartExtensions.length == 0){
		    for (key => data in FormatDetector.formatMap)
                if (!moonchartExtensions.contains(data.extension))
                    moonchartExtensions.push(data.extension);
        }
		return moonchartExtensions;
    }
    #end
	static public function loadSong(metadata:SongMetadata, ?difficulty:String, ?difficultyIdx:Int = 1) {
		Paths.currentModDirectory = metadata.folder;

		var songLowercase:String = Paths.formatToSongPath(metadata.songName);
		var diffSuffix:String;

		if (difficulty == null || difficulty == "" || difficulty == "normal"){
			difficulty = 'normal';
			diffSuffix = '';
		}else{
			difficulty = difficulty.trim().toLowerCase();
			diffSuffix = '-$difficulty';
		}
		
		var chartFileName:String = songLowercase + diffSuffix + ".json";
		
		if (Main.showDebugTraces)
			trace('playSong', Paths.currentModDirectory, chartFileName);
		var format:Format = FNF_LEGACY_PSYCH;

		#if (moonchart)
		var chartFilePath:String = '';
		for (ext in moonchartExtensions){
			for (input in [songLowercase, songLowercase + diffSuffix]){
                var path:String = Paths.formatToSongPath(songLowercase) + '/' + Paths.formatToSongPath(input) + '.' + ext;
                var filePath:String = Paths.getPath("songs/" + path);
				var fileFormat:Format = FormatDetector.findFormat([filePath]);
                if(fileFormat != null){
					chartFilePath = filePath;
                    format = fileFormat;
                }
            }
			if (chartFilePath != '')
                break;
        }

        if(chartFilePath == ''){
            trace("Couldn't find ANY CHART WTF????");
            // Find a better way to do this
            return;
        }

		
		var formatInfo = FormatDetector.getFormatData(format);

		var SONG:SwagSong = switch(format) {
			case FNF_LEGACY_PSYCH | FNF_LEGACY:
				trace('Chart format $format is good to be read ^.^');
				Song.loadFromJson(songLowercase + diffSuffix, songLowercase);

			default:
				trace('Converting from format $format!');
				
				var chart:moonchart.formats.BasicFormat<{}, {}>;
				chart = Type.createInstance(formatInfo.handler, []);
				chart = chart.fromFile(chartFilePath);
				
				var converted = new SupportedFormat().fromFormat(chart, difficulty);
				converted.path = chartFilePath;
				onLoadJson(converted);
		}
		#else
		var SONG:SwagSong = Song.loadFromJson(songLowercase + diffSuffix, songLowercase);
		#end

		PlayState.SONG = SONG;
		PlayState.difficulty = difficultyIdx;
		PlayState.difficultyName = difficulty;
		PlayState.isStoryMode = false;	
	}

	static public function switchToPlayState()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.volume = 0;

		LoadingState.loadAndSwitchState(new PlayState());	
	}

	static public function playSong(metadata:SongMetadata, ?difficulty:String, ?difficultyIdx:Int = 1)
	{
		loadSong(metadata, difficulty, difficultyIdx);
		switchToPlayState();
	} 
}

@:structInit
class SongMetadata
{
	public var songName:String = '';
	public var folder:String = '';
	public var charts(get, null):Array<String>;
	function get_charts()
		return (charts == null) ? charts = Song.getCharts(this) : charts;

	public function new(songName:String, ?folder:String = '')
	{
		this.songName = songName;
		this.folder = folder != null ? folder : '';
	}

	public function play(?difficultyName:String = ''){
        if(charts.contains(difficultyName))
			return Song.playSong(this, difficultyName, charts.indexOf(difficultyName));
    
        trace("Attempt to play null difficulty: " + difficultyName);
    }

	public function toString()
		return '$folder:$songName';
}