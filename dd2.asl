state("dd2")
{
	int LastQuest : 0xFD3DB78, 0x18;
	int CurrentQuest : 0xFD3DB78, 0x5C;
	bool Playing : 0xFD35020, 0x55;
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
