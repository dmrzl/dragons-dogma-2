state("dd2")
{
	/* QuestLogManager + 0x18 */
	int LastQuest : 0xFD4ABC0, 0x18;
	/* QuestLogManager + 0x5c */
	int CurrentQuest : 0xFD4ABC0, 0x5C;
	/* MainFlowManager + 0x58 */
	int FlowPhase : 0xFD411E8, 0x58;
	/* PauseManager + 0x38 */
	uint CurrentPauseTypes : 0xFD57A10, 0x38;
	/* PauseManager + 0x40 */
	uint CurrentPauseTargets : 0xFD57A10, 0x40;
	/* PauseManager + 0x44 */
	uint CurrentHideTargets : 0xFD57A10, 0x44;
}

startup
{
	vars.SetTextComponent = (Action<string, string>)((id, text) =>
	{
	    var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
	    var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
	    if (textSetting == null)
	    {
	        var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
	        var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
	        timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
	
	        textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
	        textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
	    }
	

        if (textSetting != null) {
			textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
		}
    });
	settings.Add("OutroSplit", false, "Split on Outro (experimental)");
	settings.Add("Debug", false, "Debug Output");
}

start
{
	return old.CurrentQuest < 0
		&& current.CurrentQuest == 10030
		&& current.LastQuest < 0;
}

update
{
	if(settings["Debug"]) 
	{
		vars.SetTextComponent("Current Quest:", current.CurrentQuest.ToString("0"));
		vars.SetTextComponent("Last Quest:", current.LastQuest.ToString("0"));
		vars.SetTextComponent("Pause Type:", current.CurrentPauseTypes.ToString("0"));
		vars.SetTextComponent("Pause Target:", current.CurrentPauseTargets.ToString("0"));
		vars.SetTextComponent("Hide Targets:", current.CurrentHideTargets.ToString("0"));
	}
}

isLoading
{
	int phase = current.FlowPhase;
	return phase != 25 // InGame
	    && phase != 8; // TitleMenu
}

split
{
	if(settings["OutroSplit"]) {
		// this one is super ugly. it is quite easy to split when the Konami logo
		// disappears, but hard to find a change that signifies it appearing
		// hence the quite specific pause state values
		uint oldPauseTypes = old.CurrentPauseTypes;
		uint curPauseTypes = current.CurrentPauseTypes;
		uint oldPauseTargets = old.CurrentPauseTargets;
		uint curPauseTargets = current.CurrentPauseTargets;
		uint oldHideTargets = old.CurrentHideTargets;
		uint curHideTargets = current.CurrentHideTargets;
		if (old.CurrentPauseTypes == 128 &&
	    	old.CurrentPauseTargets == 512 &&
			current.CurrentPauseTypes == 64 &&
	    	current.CurrentPauseTargets == 1279 &&
			current.CurrentQuest >= 10200
		) {
			return true;
		}
	}

	return current.LastQuest != old.LastQuest
		&& current.LastQuest >= 0;
}

exit
{
	timer.IsGameTimePaused = true;
}
