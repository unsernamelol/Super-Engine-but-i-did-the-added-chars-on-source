package osu;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.media.Sound;
import sys.FileSystem;
import lime.media.AudioBuffer;

import Section.SwagSection;

class OsuPlayState extends onlinemod.OfflinePlayState
{
  public static var instFile:String  = "";
  var loadedSong:Sound;
  override function loadSongs(){
    {try{
    // instFile = "/home/steph/Games/FNF/Link to FNF/Multiplayer/FNFBR/assets/music/freakyMenu.ogg";
    loadedVoices = new FlxSound();
    trace('Loading ${instFile}');
    if (!FileSystem.exists(instFile)) {MainMenuState.handleError('${instFile} doesn\'t exist!');}
    loadedSong = Sound.fromFile(instFile);
    if (loadedSong == null || loadedSong.length == 0) MainMenuState.handleError('${instFile} couldn\'t be loaded!');
    }catch(e){MainMenuState.handleError('Caught "loadSongs" crash: ${e.message}');}}
  }
  override function startSong(?alrLoaded:Bool = false)
  {
    FlxG.sound.playMusic(loadedSong, 1, false);

    // We be good and actually just use an argument to not load the song instead of "pausing" the game
    super.startSong(true);
  }
  override function create()
    {try{
    stateType=5;
    shouldLoadJson = false;
  	super.create();

  }catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}');}}
  override function openSubState(SubState:FlxSubState)
  {
    if (Type.getClass(SubState) == PauseSubState)
    {
      super.openSubState(new PauseSubState(PlayState.boyfriend.x,PlayState.boyfriend.y));
      return;
    }

    super.openSubState(SubState);
  }
}
