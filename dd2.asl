state("dd2", "13678479")
{
	int LastQuest : 0xFD40190, 0x18;
	int CurrentQuest : 0xFD40190, 0x5C;
	// bool CameraReady : 0xFD37708, 0x50;
	// bool SetupComplete : 0xFD37708, 0x51;
	bool Playing : 0xFD37708, 0x55;
}

init
{
	switch (modules.First().ModuleMemorySize)
	{
		case 0x2A769000:
			version = "13678479";
			break;
		default:
			version = "unknown";
			break;
	}
}

start
{
	return old.CurrentQuest < 0
		&& current.CurrentQuest == 10030
		&& current.LastQuest < 0;
}

isLoading
{
	return !current.Playing;
}

split
{
	return current.LastQuest != old.LastQuest
		&& current.LastQuest >= 0;
}

exit
{
	timer.IsGameTimePaused = true;
}
