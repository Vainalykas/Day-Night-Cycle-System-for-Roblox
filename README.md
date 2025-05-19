1. Copy this script into a Script object in ServerScriptService in your Roblox game.
2. The system will automatically control the day/night cycle using Lighting.TimeOfDay.
3. To set the length of a full day (in real seconds), change the DAY_LENGTH_SECONDS variable.
4. To get the current time of day (in hours), call:
   GetCurrentDayTime()
5. To get notified when day or night starts, customize the onDayNightChanged(isDay) function.
6. You can manually set the time of day using SetDayTime(hour) (0 = midnight, 12 = noon, 18 = evening, etc.).
7. The system will automatically update Lighting.Brightness and Lighting.OutdoorAmbient for day/night, but you can customize this in onDayNightChanged.
