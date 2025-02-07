package funkin.states;

import funkin.Conductor;
import openfl.filters.BlurFilter;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.*;
import flixel.tweens.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.objects.shaders.ColorSwap;

using StringTools;

#if DISCORD_ALLOWED
import funkin.api.Discord.DiscordClient;
#end

// used so stages dont break too much
class FakeCharacter
{
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void{}

	public function new(){}
}

@:injectMoreFunctions(["generateSequence"])
class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;
	public static var closedState:Bool = false;

	static function getIntroTextShit():Array<Array<String>>
	{
		var swagGoodArray:Array<Array<String>> = [];

		for (folder in Paths.getFolders("data")) {
			var rawFile:Null<String> = Paths.getText('$folder/introText.txt');
			if (rawFile != null) {
				for (line in rawFile.rtrim().split('\n'))
					swagGoodArray.push(line.split('--'));
			}	
		}

		return swagGoodArray;
	}
	
	public static function getRandomStage()
	{
		// Set up a stage list
		var stages:Array<Array<String>> = []; // [stage name, mod directory]

		Paths.currentModDirectory = "";
		for (stage in Stage.getTitleStages())
			stages.push([stage, ""]);

		#if MODS_ALLOWED
		for (mod in Paths.getModDirectories())
		{
			Paths.currentModDirectory = mod;
			for (stage in Stage.getTitleStages(true))
				stages.push([stage, mod]);
		}
		#end

		return FlxG.random.getObject(stages); // Get a random stage from the list
	}

	// for stage scripts
	public var gf:FakeCharacter = new FakeCharacter();
	public var dad:FakeCharacter = new FakeCharacter();
	public var boyfriend:FakeCharacter = new FakeCharacter();
	public var inCutscene:Bool = false;

	var curWacky:Array<String> = [];

	var blackScreen:FlxSprite;
	var textGroup:FlxTypedGroup<Alphabet>;
	var ngSpr:FlxSprite;
	var blurFilter:BlurFilter;

	var logoBl:TitleLogo;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;
	var bg:Stage;

	//
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	// cam shit raaahhhhh
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;

	var darkness:FlxSprite;
	override public function create():Void
	{
		if (initialized)
			Paths.clearStoredMemory();

		FlxTransitionableState.skipNextTransIn = true;
		persistentUpdate = true;

		////
		camFollow = new FlxPoint(640, 360);
		camFollowPos = new FlxObject(640, 360, 0, 0);
		blurFilter = new BlurFilter(32, 32);

		camGame = new FlxCamera();
		camGame.bgColor = 0xFF000000;
		camGame.follow(camFollowPos);
		camGame.filters = [blurFilter];

		camHUD = new FlxCamera();
		camHUD.bgColor = 0x00000000;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		////
		super.create();

		////
		var randomStage = getRandomStage();
		if (randomStage != null) {
			trace(randomStage);
			Paths.currentModDirectory = randomStage[1];
			bg = new Stage(randomStage[0], true);
			
			#if MULTICORE_LOADING
			var shitToLoad = bg.stageData.preload;
			if (shitToLoad != null) funkin.data.Cache.loadWithList(shitToLoad);
			#end

			camGame.zoom = bg.stageData.defaultZoom;
			if (bg.stageData.title_zoom != null)
				camGame.zoom = bg.stageData.title_zoom;

			var bgColor:Null<FlxColor> = null;
			if (bg.stageData.bg_color != null)
				bgColor = FlxColor.fromString(bg.stageData.bg_color);

			camGame.bgColor = (bgColor != null) ? bgColor : 0xFF000000;

			var camPos = bg.stageData.camera_stage;
			if (camPos == null) camPos = [640, 360];

			camFollow.set(camPos[0], camPos[1]);
			camFollowPos.setPosition(camPos[0], camPos[1]);

			bg.buildStage();
			add(bg);
		}

		var scale = 1920 / camGame.zoom;
		darkness = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
		darkness.scale.set(scale, scale);
		darkness.updateHitbox();
		darkness.scrollFactor.set(0, 0);
		darkness.screenCenter(XY);
		darkness.alpha = 0.4;
		darkness.cameras = [camGame];
		add(darkness);

		// Random logoooo
		swagShader = new ColorSwap();

		logoBl = new TitleLogo();
		logoBl.exists = false;
		logoBl.scrollFactor.set();
		logoBl.screenCenter(XY);
		
		logoBl.shader = swagShader.shader;
		logoBl.cameras = [camHUD];
		add(logoBl);

		//
		titleText = new FlxSprite(140, FlxG.height - 100);
		titleText.exists = false;
		titleText.frames = Paths.getSparrowAtlas('titleEnter');

		titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
		titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		titleText.animation.play('idle');

		titleText.updateHitbox();
		titleText.screenCenter(X);
		titleText.y -= titleText.height / 2;

		titleText.cameras = [camHUD];
		add(titleText);

		////
		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width, FlxG.height);
		blackScreen.updateHitbox();
		blackScreen.cameras = [camHUD];
		add(blackScreen);
		
		FlxTween.tween(blackScreen, {alpha: 0.86}, Conductor.crochet * 0.005, {
			ease: FlxEase.quadInOut,
			songBased: true,
		});

		//
		textGroup = new FlxTypedGroup<Alphabet>();
		textGroup.cameras = [camHUD];
		add(textGroup);
		
		//
		curWacky = FlxG.random.getObject(getIntroTextShit());

		//
		ngSpr = new FlxSprite(0, FlxG.height * 0.52, Paths.image('newgrounds_logo'));
		ngSpr.exists = false;
		ngSpr.scale.set(0.8, 0.8);
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.cameras = [camHUD];
		add(ngSpr);
		
		////
		if (initialized){
			Paths.clearUnusedMemory();
			skipIntro();
		}else{
			initialized = true;
			generateSequence();
		}
	}

	var transitioning:Bool = false;
	var titleTimer:Float = 0;

	function generateSequence() {
		// this could prob be replaced with a json, yaml or even a whole "TitleSequence" script?? :shrug:
		queueOnBeat(0, clearLines);
		queueOnBeat(0, playMusic.bind(null));
		queueNewLineOnBeat(0, 'troll engine by', -15);
		queueNewLineOnBeat(0, 'riconuts', -8);
		queueNewLineOnBeat(0, 'nebula_zorua', -8);

		queueNewLineOnBeat(3, 'and more', -8);
		queueOnBeat(4, clearLines);

		queueNewLineOnBeat(5, 'Without any', 40);
		queueNewLineOnBeat(5, 'association to');

		queueNewLineOnBeat(7, "Newgrounds");
		queueOnBeat(7, () -> ngSpr.exists = true);

		queueOnBeat(8, () -> ngSpr.exists = false);
		queueOnBeat(8, clearLines);

		queueNewLineOnBeat(9, curWacky[0]);
		queueNewLineOnBeat(11, curWacky[1]);
		queueOnBeat(12, clearLines);
		
		queueNewLineOnBeat(13, "Friday");
		queueNewLineOnBeat(14, "Night");
		queueNewLineOnBeat(15, "Funkin");
		queueOnBeat(16, skipIntro);
	}

	public function playMusic(?key:String) {
		var soundAsset = key==null ? null : Paths.music(key);
		if (soundAsset != null) 
			FlxG.sound.playMusic(soundAsset);
		else
			MusicBeatState.playMenuMusic(1, true);
	}

	public function getLineObj(i:Int = 0):Null<Alphabet> 
	{
		var l = textGroup.length;
		if (l == 0) return null;
		i = CoolUtil.updateIndex(l-1, -i, l);
		return textGroup.members[i];
	}

	public function newLine(text:String, offset:Float = 0)
	{
		var lastObj = getLineObj();
		var y = ((lastObj!=null) ? (lastObj.y+60) : 200) - offset;
		var obj = new Alphabet(0, y, text, true);
		obj.cameras = textGroup.cameras;
		obj.screenCenter(X);
		return textGroup.add(obj);
	}

	public function clearLines()
	{
		for (obj in textGroup)
			obj.destroy();
		textGroup.clear();
	}

	public function setLineText(i:Int = 0, text:String)
	{
		var obj = getLineObj(i);
		if (obj != null) obj.text = text;
	}

	public function appendLineText(i:Int = 0, text:String)
	{
		var obj = getLineObj(i);
		if (obj != null) obj.text += text;
	}

	var skippedIntro:Bool = false;
	function skipIntro():Void
	{
		if (skippedIntro) return;
		camGame.filters.remove(blurFilter);

		titleText.exists = true;
		logoBl.exists = true;
		
		ngSpr.exists = false;
		blackScreen.exists = false;
		textGroup.exists = false;

		camHUD.flash(FlxColor.WHITE, 4);
		
		skippedIntro = true;
	}

	var introEvents:Array<Array<Dynamic>> = [];
	public function queueOnTime(time:Float, func:() -> Void)
		introEvents.push([time, func]);

	public function queueOnStep(step:Float, func:() -> Void)
		queueOnTime(Conductor.stepToMs(step), func);

	public function queueOnBeat(beat:Float, func:() -> Void)
		queueOnStep(beat * 4, func);

	public function queueNewLineOnBeat(beat:Float, text:String, offset:Float = 0)
		queueOnBeat(beat, newLine.bind(text, offset));

	private var introEventIdx:Int = 0;
	private function updateIntro()
	{
		while (introEventIdx < introEvents.length) {
			var event = introEvents[introEventIdx];

			if (Conductor.songPosition < event[0]) 
				break;

			try {
				event[1]();
			}catch(e){
				trace(curDecBeat, introEventIdx, e, event[1]);
			}

			introEventIdx++;
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if (skippedIntro) {
			if (bg != null && bg.stageScript != null) {
				bg.stageScript.set("curBeat", curBeat);
				bg.stageScript.call('onBeatHit', []);
			}
		}
		if (logoBl != null)
			logoBl.time = 0;
	}
	var section:Int = -100;
	override function stepHit()
	{
		super.stepHit();

		if (bg != null && bg.stageScript != null)
		{
			if (skippedIntro){
				bg.stageScript.set("curStep", curStep);
				bg.stageScript.call('onStepHit', []);
			}
			var nuSection:Int = Math.floor(curBeat / 4);
			if (section != nuSection)
			{
				section = nuSection;
				if (skippedIntro){
					bg.stageScript.set("curSection", section);
					bg.stageScript.call('onSectionHit', []);
				}
			}
		}
	}

	private static function getPressedEnter():Bool 
	{
		#if FLX_KEYBOARD
		if (FlxG.keys.justPressed.ENTER)
			return true;
		#end

		#if FLX_MOUSE
		if (FlxG.mouse.justPressed)
			return true;
		#end

		#if mobile
		for (touch in FlxG.touches.list){
			if (touch.justPressed) {
				return true;
				break;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				return true;

			#if switch
			if (gamepad.justPressed.B)
				return true;
			#end
		}

		return false;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		else
			Conductor.songPosition += elapsed;

		if (bg != null && bg.stageScript != null) {
			bg.stageScript.set("curDecBeat", curDecBeat);
			bg.stageScript.set("curDecStep", curDecStep);
			bg.stageScript.call('update', [elapsed]);
		}

		var lerpVal:Float = Math.exp(-elapsed * 2.4);
		camFollowPos.setPosition(
			FlxMath.lerp(camFollow.x,  camFollowPos.x, lerpVal), 
			FlxMath.lerp(camFollow.y,  camFollowPos.y, lerpVal)
		);

		if (swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		titleTimer = (titleTimer + elapsed) % 2;

		if (getPressedEnter())
			skipIntro();

		if (!skippedIntro) {
			updateIntro();
		}
		else
		{
			if (transitioning) {
				if (getPressedEnter()) {
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				}
			}
			else if (getPressedEnter())
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				titleText.animation.play('press');

				darkness.exists = false;
				camHUD.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1, null, true);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(0.9, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
			}
			else {
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = 2 - timer;

				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
		}

		if (bg != null && bg.stageScript != null)
			bg.stageScript.call('onUpdate', [elapsed]);

		super.update(elapsed);
	}
}

class TitleLogo extends FlxSprite
{
	public var titleName:String;

	public function new(?X:Float, ?Y:Float, ?Name:String)
	{
		var titleGraphic = Paths.image('logo');

		if (titleGraphic == null || Name != null){
			titleGraphic = Paths.image('titles/${Name != null ? Name : FlxG.random.getObject(getTitlesList())}');
		}

		super(X, Y, titleGraphic);
		antialiasing = true;
	}

	public var time:Float = 0;
	public var frameRate:Float = 1 / 24;
	public var size:Float = 0.72;

	override public function update(elapsed:Float){
		//// Title animation!
		time += elapsed;

		var time = time / frameRate;
		var size = size;

		if (time > 5){
			
		}else if (time > 3)
			size *= 1.008;
		else if (time > 1)
			size *= 1.038;
		else{
			size *= 0.98;
		}

		scale.set(size, size);

		super.update(elapsed);
	}

	public static function getTitlesList():Array<String>
	{
		var titleNames:Array<String> = [];
		var foldersToCheck:Array<String> = Paths.getFolders('images/titles');
		
		for (folder in foldersToCheck){
			Paths.iterateDirectory(folder, function(path:String){
				var file = new haxe.io.Path(path);

				if (!titleNames.contains(file.file) && file.ext == "png")
					titleNames.push(file.file);
			});
		}

		if (titleNames.length < 1)
			titleNames.push("");

		return titleNames;
	}
}