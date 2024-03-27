state("dd2", "13678479"){
	int LastQuest : 0x0FD40190, 0x18;
	int CurrentQuest : 0x0FD40190, 0x5C;
	bool CameraReady : 0x0FD37708, 0x50;
	bool SetupComplete : 0x0FD37708, 0x51;
	bool Playing : 0x0FD37708, 0x55;
}

startup
{
	settings.Add("AutoStart", true, "Auto Start");
	settings.Add("AutoSplit", true, "Auto Split");
}

init
{
	var module = modules.First();
	switch (module.ModuleMemorySize)
	{
		case (712413184):
			version = "13678479";
			break;
		default:
			version = "unknown";
			break;
	}
}

start
{
	if(settings["AutoStart"]) {
		return old.CurrentQuest < 0
		    && current.CurrentQuest == 10030
		    && current.LastQuest < 0;
	}
	return false;
}

isLoading
{
	return !current.Playing;
}

split
{
	if (settings["AutoSplit"]) {
		return current.LastQuest != old.LastQuest
			&& current.LastQuest >= 0;
	}
	return false;
}

exit
{
	timer.IsGameTimePaused = true;
}