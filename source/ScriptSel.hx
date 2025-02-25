package;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;

import sys.io.File;
import sys.FileSystem;

using StringTools;

class ScriptSel extends SearchMenuState
{
	static var defText:String = "Use shift to scroll faster";
	var descriptions:Map<String,String> = new Map<String,String>();
	override function addToList(char:String,i:Int = 0){
		songs.push(char);
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, char, true, false);
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0)
			controlLabel.alpha = 0.6;
		if(FlxG.save.data.scripts.contains(char)){
			controlLabel.color = FlxColor.GREEN;
		}
		grpSongs.add(controlLabel);
	}

	override function ret(){
		FlxG.switchState(new OptionsMenu());
	}
	override function create()
	{try{
		searchList = [];
		retAfter = false;
		if(FileSystem.exists('mods/scripts'))
			{

				for (directory in FileSystem.readDirectory('mods/scripts/'))
				{
					if (FileSystem.exists("mods/scripts/"+directory+"/script.hscript"))
					{
						searchList.push(directory);
						if (FileSystem.exists("mods/scripts/"+directory+"/description.txt")){
							descriptions[directory] = File.getContent('mods/scripts/${directory}/description.txt');
						}
					}
				}
		}
		if (searchList[0] == null){searchList.push('No scripts found!');trace('No scripts found!');}
		// searchList = TitleState.choosableStages;
		super.create();
	}catch(e) MainMenuState.handleError('Error with stagesel "create" ${e.message}');}

	override function changeSelection(change:Int = 0){
		super.changeSelection(change);
		if (songs[curSelected] != "" && descriptions[songs[curSelected]] != null ){
		  updateInfoText('${defText}; ' + descriptions[songs[curSelected]]);
		}else{
		  updateInfoText('${defText}; No description for this script.');
		}
	}

	override function select(sel:Int = 0){
		// FlxG.save.data.selStage = songs[sel];
		if(songs[sel] != 'No scripts found!'){

			if(!FlxG.save.data.scripts.remove(songs[sel])){
				FlxG.save.data.scripts.push(songs[sel]);
				grpSongs.members[sel].color = FlxColor.GREEN;
			}else{grpSongs.members[sel].color = FlxColor.WHITE;}

			// reloadList();
		}
	}
}
