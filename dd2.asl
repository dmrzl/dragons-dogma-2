state("dd2")
{
	/* QuestLogManager + 0x18 */
	int LastQuest : 0xFD3DB78, 0x18;
	/* QuestLogManager + 0x5c */
	int CurrentQuest : 0xFD3DB78, 0x5C;
	/* MainFlowManager + 0x58 */
	int FlowPhase : 0xFD35020, 0x58;
	/* PauseManager + 0x38 */
	uint CurrentPauseTypes : 0xFD4A9A0, 0x38;
	/* PauseManager + 0x40 */
	uint CurrentPauseTargets : 0xFD4A9A0, 0x40;
	/* PauseManager + 0x44 */
	uint CurrentHideTargets : 0xFD4A9A0, 0x44;
}

startup
{
	settings.Add("OutroSplit", false, "Split on Outro (experimental)");
}

start
{
	return old.CurrentQuest < 0
		&& current.CurrentQuest == 10030
		&& current.LastQuest < 0;
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
