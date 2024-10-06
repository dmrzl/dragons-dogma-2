state("dd2")
{
	/* QuestLogManager + 0x84 */
	int LastQuest : 0xF8E66B8, 0x84;
	/* QuestLogManager + 0x8c */
	int CurrentQuest : 0xF8E66B8, 0x8C;
	/* MainFlowManager + 0xE8 */
	int FlowPhase : 0xF8E2A58, 0xE8;
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
		vars.SetTextComponent("Pause Target:", current.CurrentPauseTargets.ToString("0"));
		vars.SetTextComponent("Hide Targets:", current.CurrentHideTargets.ToString("0"));
	}
}

isLoading
{
	return false;
	//int phase = current.FlowPhase;
	//return phase != 25 // InGame
	//    && phase != 8; // TitleMenu
}

split
{
	return current.LastQuest != old.LastQuest
		&& (current.LastQuest >= 0 || old.LastQuest >= 0);
}

exit
{
	timer.IsGameTimePaused = true;
}
