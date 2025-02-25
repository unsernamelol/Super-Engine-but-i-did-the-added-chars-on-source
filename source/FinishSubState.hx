package;

import openfl.Lib;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.ui.FlxBar;
import flixel.FlxCamera;

class FinishSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;

	var music:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;
	var win:Bool = true;
	var ready = false;
	var week:Bool = false;
	var errorMsg:String = "";
	var isError:Bool = false;
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	var iconP1:HealthIcon; 
	var iconP2:HealthIcon;
	public static var pauseGame:Bool = true;
	public static var autoEnd:Bool = true;
	public function new(x:Float, y:Float,?won = true,?week:Bool = false,?error:String = "")
	{
		if (error != ""){
			isError = true;
			errorMsg = error;
			won = false;
			
		}
		FlxG.camera.alpha = PlayState.instance.camGame.alpha = PlayState.instance.camHUD.alpha = 1;
		PlayState.instance.followChar(0);
		if(!isError){
			var inName = if(won)"winSong" else "loseSong";
			PlayState.instance.callInterp(inName,[]);
			PlayState.dad.callInterp(inName,[]);
			PlayState.boyfriend.callInterp(inName,[]);
		}

		this.week = week;
		if(!isError) FlxG.state.persistentUpdate = true; else FlxG.state.persistentUpdate = false;
		win = won;
		FlxG.sound.pause();
		PlayState.instance.generatedMusic = false;
		var dad = PlayState.dad;
		var boyfriend = PlayState.boyfriend;

		// For healthbar shit
		healthBar = PlayState.instance.healthBar;
		healthBarBG = PlayState.instance.healthBarBG;
		iconP1 = PlayState.instance.iconP1;
		iconP2 = PlayState.instance.iconP2;


		if(win){
			for (g in [PlayState.instance.cpuStrums,PlayState.instance.playerStrums]) {
				g.forEach(function(i){
					FlxTween.tween(i, {y:if(FlxG.save.data.downscroll)FlxG.height + 200 else -200},1,{ease: FlxEase.expoIn});
				});
			}
			if (FlxG.save.data.songPosition)
			{
				for (i in [PlayState.songPosBar,PlayState.songPosBG,PlayState.instance.songName,PlayState.instance.songTimeTxt]) {
					FlxTween.tween(i, {y:if(FlxG.save.data.downscroll)FlxG.height + 200 else -200},1,{ease: FlxEase.expoIn});
				}
			}

			FlxTween.tween(healthBar, {y:Std.int(FlxG.height * 0.10)},1,{ease: FlxEase.expoIn});
			FlxTween.tween(healthBarBG, {y:Std.int(FlxG.height * 0.10 - 4)},1,{ease: FlxEase.expoIn});
			FlxTween.tween(iconP1, {y:Std.int(FlxG.height * 0.10 - (iconP1.height * 0.5))},1,{ease: FlxEase.expoIn});
			FlxTween.tween(iconP2, {y:Std.int(FlxG.height * 0.10 - (iconP2.height * 0.5))},1,{ease: FlxEase.expoIn});




			FlxTween.tween(PlayState.instance.kadeEngineWatermark, {y:FlxG.height + 200},1,{ease: FlxEase.expoIn});
			FlxTween.tween(PlayState.instance.scoreTxt, {y:if(FlxG.save.data.downscroll) -200 else FlxG.height + 200},1,{ease: FlxEase.expoIn});
		}
		if(!isError){
			if(win){
				boyfriend.playAnimAvailable(['win','hey','singUP']);
				
				if (PlayState.SONG.player2 == FlxG.save.data.gfChar) dad.playAnim('cheer'); else {dad.playAnimAvailable(['lose','singDOWNmiss']);}
				PlayState.gf.playAnim('cheer',true);
			}else{
				// boyfriend.playAnim('singDOWNmiss');
				// boyfriend.playAnim('lose');

				// dad.playAnim("hey",true);
				// dad.playAnim("win",true);
				boyfriend.playAnimAvailable(['lose','singDOWNmiss']);
				dad.playAnimAvailable(['win','hey','singUP']);
				if (PlayState.SONG.player2 == FlxG.save.data.gfChar) dad.playAnim('sad'); else dad.playAnim("hey");
				PlayState.gf.playAnim('sad',true);
			}
		}
		super();
		if(autoEnd){

			// FlxG.camera.zoom = 1;
			// PlayState.instance.camHUD.zoom = 1;
			if (win) boyfriend.animation.finishCallback = this.finishNew; else finishNew();
			if (FlxG.save.data.camMovement){
				PlayState.instance.followChar(if(win) 0 else 1);
			}
		}
	}


	var cam:FlxCamera;
	public function finishNew(?name:String){
			FlxG.camera.alpha = PlayState.instance.camGame.alpha = PlayState.instance.camHUD.alpha = 1;
			FlxG.camera.zoom = PlayState.instance.defaultCamZoom;
			cam = new FlxCamera();
			FlxG.cameras.add(cam);
			FlxCamera.defaultCameras = [cam];
			if (win) PlayState.boyfriend.animation.finishCallback = null; else PlayState.dad.animation.finishCallback = null;
			ready = true;
			FlxG.state.persistentUpdate = !isError && !pauseGame;
			pauseGame = true;
			autoEnd = true;
			FlxG.sound.pause();

			music = new FlxSound().loadEmbedded(Paths.music(if(win) 'StartItchBuild' else 'gameOver'), true, true);
			music.play(false);
			if(win){
				music.looped = false;
				music.onComplete = function(){music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);music.play(false);} 

			}
			// FlxG.camera.zoom = PlayState.instance.camHUD.zoom = 1;

			FlxG.sound.list.add(music);

			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			if(isError){
				var finishedText:FlxText = new FlxText(20,-55,0, "Error caught!" );
				finishedText.size = 34;
				finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				finishedText.color = FlxColor.RED;
				finishedText.scrollFactor.set();
				var comboText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-75,0,'Error Message:\n${errorMsg}\n\nIf you\'re not the creator of the character or chart,\nit is recommended that you report this to the chart/character\'s developer');
				comboText.size = 28;
				comboText.wordWrap = true;
				comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				comboText.color = FlxColor.WHITE;
				comboText.scrollFactor.set();
				comboText.fieldWidth = FlxG.width - comboText.x;
				var contText:FlxText = new FlxText(FlxG.width - 475,FlxG.height + 100,0,'Press ENTER to exit\nor R to reload.');
				contText.size = 28;
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				contText.color = FlxColor.WHITE;
				contText.scrollFactor.set();
				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
				add(bg);
				add(finishedText);
				add(comboText);
				add(contText);
			}else{

				var finishedText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-55,0, (if(week) "Week" else "Song") + " " + (if(win) "Won!" else "failed...") );
				finishedText.size = 34;
				finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				finishedText.color = FlxColor.WHITE;
				finishedText.scrollFactor.set();
				var comboText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-75,0,'Song/Chart:\n\nSicks - ${PlayState.sicks}\nGoods - ${PlayState.goods}\nBads - ${PlayState.bads}\nShits - ${PlayState.shits}\n\nLast combo: ${PlayState.combo} (Max: ${PlayState.maxCombo})\nMisses: ${PlayState.misses}\n\nScore: ${PlayState.songScore}\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%\n\n${Ratings.GenerateLetterRank(PlayState.accuracy)}');
				comboText.size = 28;
				comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				comboText.color = FlxColor.WHITE;
				comboText.scrollFactor.set();
// Std.int(FlxG.width * 0.45)
				var settingsText:FlxText = new FlxText(comboText.width * 1.10 + FlxG.save.data.guiGap,-30,0,
				(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
				
				+'\n\nSettings:'
				+'\n\n Downscroll: ${FlxG.save.data.downscroll}'
				+'\n Ghost Tapping: ${FlxG.save.data.ghost}'
				+'\n Practice: ${FlxG.save.data.practiceMode}'
				+'\n HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}' + (QuickOptionsSubState.getSetting("Song hscripts") ? '\n  Script Count:${PlayState.instance.interpCount}' : "")
				+'\n Safe Frames: ${FlxG.save.data.frames}'
				+'\n Input Engine: ${PlayState.inputEngineName}, V${MainMenuState.ver}'
				+'\n Song Offset: ${HelperFunctions.truncateFloat(FlxG.save.data.offset + PlayState.songOffset,2)}ms'
				);
				settingsText.size = 28;
				settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				settingsText.color = FlxColor.WHITE;
				settingsText.scrollFactor.set();

				var contText:FlxText = new FlxText(FlxG.width - 475 - FlxG.save.data.guiGap,FlxG.height + 100,0,'Press ENTER to continue\nor R to restart.');
				contText.size = 28;
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				contText.color = FlxColor.WHITE;
				contText.scrollFactor.set();
				// var chartInfoText:FlxText = new FlxText(20,FlxG.height + 50,0,'Offset: ${FlxG.save.data.offset + PlayState.songOffset}ms | Played on ${songName}');
				// chartInfoText.size = 16;
				// chartInfoText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
				// chartInfoText.color = FlxColor.WHITE;
				// chartInfoText.scrollFactor.set();
				

				add(bg);
				add(finishedText);
				add(comboText);
				add(contText);
				add(settingsText);
				// add(chartInfoText);
				healthBar.cameras = healthBarBG.cameras = iconP1.cameras = iconP2.cameras = [cam];

				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
				// FlxTween.tween(chartInfoText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(settingsText, {y:145},0.5,{ease: FlxEase.expoInOut});
			}

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]]; 
	}
	var shouldveLeft = false;
	function retMenu(){
		if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
		PlayState.actualSongName = ""; // Reset to prevent issues
		PlayState.instance.persistentUpdate = true;
		if (shouldveLeft){
			Main.game.forceStateSwitch(new MainMenuState());

		}else{
			switch (PlayState.stateType)
			{
				case 2:FlxG.switchState(new onlinemod.OfflineMenuState());
				case 4:FlxG.switchState(new multi.MultiMenuState());
				case 5:FlxG.switchState(new osu.OsuMenuState());
					

				default:FlxG.switchState(new FreeplayState());
			}
		}
		shouldveLeft = true;
		return;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready){
			var accepted = controls.ACCEPT;
			var oldOffset:Float = 0;


			if (accepted)
			{
				retMenu();
			}

			if (FlxG.keys.justPressed.R)
			{if(win){FlxG.resetState();}else{restart();}}
		}else{
			if(FlxG.keys.justPressed.ANY){
				PlayState.boyfriend.animation.finishCallback = null;
				finishNew();
			}
		}

	}
	function restart()
	{
		ready = false;
		// FlxG.sound.music.stop();
		// FlxG.sound.play(Paths.music('gameOverEnd'));
		if(isError){
			FlxG.resetState();
			if (shouldveLeft){ // Error if the state hasn't changed and the user pressed r already
				MainMenuState.handleError("Caught softlock!");
			}
			shouldveLeft = true;
			return;
		}
		// Holyshit this is probably a bad idea but whatever
		// PlayState.instance.resetInterps();
		// Conductor.songPosition = 0;
		// Conductor.songPosition -= Conductor.crochet * 5;
		
		// PlayState.instance.persistentUpdate = true;
		// PlayState.instance.resetScore();
		// PlayState.songStarted = false;

		// PlayState.strumLineNotes = null;
		// PlayState.instance.generateSong();
		// PlayState.instance.startCountdown();
		// close();
		FlxG.resetState();
	}
	override function destroy()
	{
		if (music != null){music.destroy();}

		super.destroy();
	}

}