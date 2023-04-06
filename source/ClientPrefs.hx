package;

#if !macro
import Controls.KeyboardScheme;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
#end

enum OptionType
{
	Toggle;
	Dropdown;
	Number;
	Button;
}

typedef OptionData =
{
	display:String,
	desc:String,
	type:OptionType,
	?value:Dynamic,
	data:Map<String, Dynamic>,
}

#if !macro
@:build(newoptions.OptionMacro.build())
#end
class ClientPrefs
{
	static var defaultOptionDefinitions = getOptionDefinitions();

	inline public static function getOptionDefinitions():Map<String, OptionData>
	{
		return [
			// gameplay
			"controllerMode" => {
				display: "Controller Mode",
				desc: "When toggled, lets you play the game with a controller instead.",
				type: Toggle,
				value: true,
				data: []
			},
			"noReset" => {
				display: "Disable Reset Button",
				desc: "When toggled, you won't be able to press your bound Reset button.",
				type: Toggle,
				value: true,
				data: []
			},
			"ghostTapping" => {
				display: "Ghost Tapping",
				desc: "When toggled, you won't get penalised for inputs which don't hit notes.",
				type: Toggle,
				value: true,
				data: []
			},
			"directionalCam" => {
				display: "Directional Camera",
				desc: "When toggled, the camera will move with the focused character's animations",
				type: Toggle,
				value: true,
				data: []
			},
			"judgePreset" => {
				display: "Judgement Preset",
				desc: "Presets for the judgement windows",
				type: Dropdown,
				value: "Standard",
				data: ["options" => ["Standard", "Psych", "Vanilla", "Stepmania", "ITG", "Custom"]]
			},
			"noteOffset" => {
				display: "Offset",
				desc: "How much to offset notes, song events, etc.",
				type: Number,
				value: 0,
				data: ["suffix" => "ms", "min" => -1000, "max" => 1000, "step" => 1,]
			},
			"ratingOffset" => {
				display: "Judgements Offset",
				desc: "How much to offset hit windows.",
				type: Number,
				value: 0,
				data: ["suffix" => "ms", "min" => -100, "max" => 100, "step" => 1,]
			},
			"hitsoundVolume" => {
				display: "Hitsound Volume",
				desc: "The volume of hitsounds. 0% to disable",
				type: Number,
				value: 0,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 1,
					"type" => "percent" // saved value is value / 100
				]
			},
			"missVolume" => {
				display: "Miss Volume",
				desc: "The volume of miss sounds. 0% to disable",
				type: Number,
				value: 50,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 1,
					"type" => "percent" // saved value is value / 100
				]
			},
			"useEpics" => {
				display: "Use Epics",
				desc: "When toggled, epics will be used as the highest judgement.",
				type: Toggle,
				value: false,
				data: []
			},
			"flashing" => {
				display: "Flashing Lights",
				desc: "When toggled, flashing lights will be shown ingame.",
				type: Toggle,
				value: true,
				data: []
			},
			"camShakeP" => {
				display: "Camera Shaking",
				desc: "A multiplier to camera shake intensity.",
				type: Number,
				value: 1,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 5,
					"type" => "percent" // saved value is value / 100
				]
			},
			"camZoomP" => {
				display: "Camera Zooming",
				desc: "A multiplier to camera zoom intensity.",
				type: Number,
				value: 1,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 5,
					"type" => "percent" // saved value is value / 100
				]
			},
			// UI
			"timeBarType" => {
				display: "Time Bar",
				desc: "How to display the time bar",
				type: Dropdown,
				value: "Time Left",
				data: ["options" => ["Time Left", "Time Elapsed", "Song Name", "Disabled"]]
			},
			"hudOpacity" => {
				display: "Opacity",
				desc: "How visible the HUD should be. 100% is fully visible and 0% is invisible.",
				type: Number,
				value: 1,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 1,
					"type" => "percent" // saved value is value / 100
				]
			},
			"hpOpacity" => {
				display: "Health Bar Opacity",
				desc: "How visible the health bar should be. 100% is fully visible and 0% is invisible.",
				type: Number,
				value: 1,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 1,
					"type" => "percent" // saved value is value / 100
				]
			},
			"timeOpacity" => {
				display: "Time Bar Opacity",
				desc: "How visible the time bar should be. 100% is fully visible and 0% is invisible.",
				type: Number,
				value: 1,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 1,
					"type" => "percent" // saved value is value / 100
				]
			},
			"stageOpacity" => {
				display: "Stage Darkness",
				desc: "Darkens the stage by the specified amount. 100% is entirely dark, 0% is entirely bright.",
				type: Number,
				value: 0,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 1,
					"type" => "percent" // saved value is value / 100
				]
			},
			"simpleJudge" => {
				display: "Alt Judgements",
				desc: "Makes judgements pop in alot simpler and displays only one at a time.",
				value: false,
				type: Toggle,
				data: []
			},
			"scoreZoom" => {
				display: "Zoom On Hit",
				desc: "When toggled, the score text zooms when you hit a note",
				type: Toggle,
				value: true,
				data: []
			},
			"customizeHUD" => {
				display: "Customize HUD Placements",
				desc: "Lets you customize where judgements and combo are displayed",
				type: Button,
				data: []
			},
			"noteOpacity" => {
				display: "Note Opacity",
				desc: "How visible the notes and receptors should be. 100% is fully visible and 0% is invisible.",
				type: Number,
				value: 1,
				data: [
					"suffix" => "%",
					"min" => 0,
					"max" => 100,
					"step" => 1,
					"type" => "percent" // saved value is value / 100
				]
			},
			"holdSubdivs" => {
				display: "Hold Subdivisions",
				desc: "How many times each hold note should be subdivided. More numbers means more lag, but smoother holds",
				type: Number,
				value: 2,
				data: [
					"min" => 1,
					"max" => 6,
					"step" => 1
				]
			},
			"optimizeHolds" => {
				display: "Optimize Holds",
				desc: "When toggled, hold notes will be less accurate, but use less extra calls and thus less lag.",
				type: Toggle,
				value: true,
				data: []
			},
			"downScroll" => {
				display: "Downscroll",
				desc: "When toggled, notes will go from top to bottom instead of bottom to top.",
				type: Toggle,
				value: false,
				data: []
			},
			"midScroll" => {
				display: "MiddleScroll",
				desc: "When toggled, notes will be centered.",
				type: Toggle,
				value: false,
				data: []
			},
			"noteSplashes" => {
				display: "Note Splashes",
				desc: "When toggled, hitting top judgements will cause a particles to spawn.",
				type: Toggle,
				value: true,
				data: []
			},
			"noteSkin" => {
				display: "Note Colours",
				desc: "Changes how notes get their colours. Column bases it on direction, Quants bases it on beat.",
				type: Dropdown,
				value: "Column",
				data: ["options" => ["Column", "Quants"]]
			},
			"epicWindow" => {
				display: "Epic Window",
				desc: "The hit window to hit an Epic.",
				type: Number,
				value: 22,
				data: ["suffix" => "ms", "min" => 0, "max" => 200, "step" => 0.1]
			},
			"sickWindow" => {
				display: "Sick Window",
				desc: "The hit window to hit a Sick.",
				type: Number,
				value: 45,
				data: ["suffix" => "ms", "min" => 0, "max" => 200, "step" => 0.1]
			},
			"goodWindow" => {
				display: "Good Window",
				desc: "The hit window to hit a Good.",
				type: Number,
				value: 90,
				data: ["suffix" => "ms", "min" => 0, "max" => 200, "step" => 0.1]
			},
			"badWindow" => {
				display: "Bad Window",
				desc: "The hit window to hit a Bad.",
				type: Number,
				value: 135,
				data: ["suffix" => "ms", "min" => 0, "max" => 200, "step" => 0.1]
			},
			"hitWindow" => {
				display: "Max Hit Window",
				desc: "The hit window to hit notes at all",
				type: Number,
				value: 166,
				data: ["suffix" => "ms", "min" => 0, "max" => 200, "step" => 0.1]
			},
			"drawDistanceModifier" => {
				display: "Draw Distance Multiplier",
				desc: "Changes how close/far a note must be to start drawing.",
				type: Number,
				value: 1,
				data: ["suffix" => "x", "min" => 0.5, "max" => 2, "step" => 0.1]
			},
			"customizeColours" => {
				display: "Customize Colors",
				desc: "Lets you change the colours of your notes",
				type: Button,
				data: []
			},
			// video
			"shaders" => {
				display: "Shaders",
				desc: "Changes which shaders can load",
				type: Dropdown,
				value: "All",
				data: ["options" => ["All", "Minimal", "None"]]
			},
			"showFPS" => {
				display: "Show FPS",
				desc: "When toggled, an FPS counter is showed in the top left.",
				type: Toggle,
				value: true,
				data: []
			},
			"framerate" => {
				display: "Max Framerate",
				desc: "The highest framerate the game can hit.",
				type: Number,
				value: 60,
				data: ["suffix" => " FPS", "min" => 30, "max" => 240, "step" => 1,]
			},
			"lowQuality" => {
				display: "Low Quality",
				desc: "When toggled, many assets won't be loaded to try to reduce strain on lower-end PCs.",
				type: Toggle,
				value: false,
				data: []
			},
			"globalAntialiasing" => {
				display: "Antialiasing",
				desc: "When toggled, sprites are able to be antialiased.",
				type: Toggle,
				value: false,
				data: []
			},
			"loadingThreads" => {
				display: "Loading Threads",
				desc: "Amount of CPU threads allowed to be used to load assets.",
				type: Number,
				value: 1,
				data: [
					"min" => 1, 
					"max" => Std.parseFloat(Sys.getEnv("NUMBER_OF_PROCESSORS")),
					"step" => 1
				]
			}
		];
	}

	#if !macro
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'perfect' => false,
		'instaRespawn' => false,
		'botplay' => false,
		'opponentplay' => false,
		'disableModcharts' => false
	];

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic
	{
		return (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static var quantHSV:Array<Array<Int>> = [
		[0, -20, 0], // 4th
		[-130, -20, 0], // 8th
		[-80, -20, 0], // 12th
		[128, -30, 0], // 16th
		[-120, -70, -35], // 20th
		[-80, -20, 0], // 24th
		[50, -20, 0], // 32nd
		[-80, -20, 0], // 48th
		[160, -15, 0], // 64th
		[-120, -70, -35], // 96th
		[-120, -70, -35] // 192nd
	];

	//
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var comboOffset:Array<Int> = [-60, 60, -260, -80];

	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'dodge' => [SPACE],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN, NONE],
		'debug_2' => [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
		// trace(defaultKeys);
	}

	static var optionSave:FlxSave = new FlxSave();

	static var manualLoads = ["gameplaySettings", "quantHSV", "arrowHSV", "comboOffset"];

	public static function initialize()
		optionSave.bind("options_v2");
	

	public static function save(?definitions:Map<String, OptionData>)
	{
		if (definitions != null)
		{
			for (key => val in definitions){
				if (val.type == Number && val.data.exists("type") && val.data.get("type") == 'percent')
					Reflect.setField(optionSave.data, key, val.value / 100);
				else
					Reflect.setField(optionSave.data, key, val.value);
				
			}
		}
		else
			for (name in options)
				Reflect.setField(optionSave.data, name, Reflect.field(ClientPrefs, name));

		
		// some dumb hardcoded saves
		for (name in manualLoads)
			Reflect.setField(optionSave.data, name, Reflect.field(ClientPrefs, name));
/* 		optionSave.data.gameplaySettings = gameplaySettings;
		optionSave.data.quantHSV = quantHSV;
		optionSave.data.arrowHSV = arrowHSV;
		optionSave.data.comboOffset = comboOffset; */
		optionSave.flush();
		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
	}

	public static function load()
	{
		for (name in options){
			if (Reflect.field(optionSave.data, name)!=null)
				Reflect.setField(ClientPrefs, name, Reflect.field(optionSave.data, name));
			else
				Reflect.setField(ClientPrefs, name, ClientPrefs.defaultOptionDefinitions.get(name).value);
		}

		if (optionSave.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = optionSave.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}

		// some dumb hardcoded saves
		for (name in manualLoads)
			if (Reflect.field(optionSave.data, name) != null)
				Reflect.setField(ClientPrefs, name, Reflect.field(optionSave.data, name));

		if (Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
		if (save != null && save.data.customControls != null)
		{
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls)
				keyBinds.set(control, keys);

			reloadControls();
		}
		if (framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = Math.floor(framerate);
			FlxG.drawFramerate = Math.floor(framerate);
		}
		else
		{
			FlxG.drawFramerate = Math.floor(framerate);
			FlxG.updateFramerate = Math.floor(framerate);
		}

	}

	public static function reloadControls()
	{
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		StartupState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		StartupState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		StartupState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = StartupState.muteKeys;
		FlxG.sound.volumeDownKeys = StartupState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = StartupState.volumeUpKeys;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
	#end
}