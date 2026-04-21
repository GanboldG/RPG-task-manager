Planned things to do:

Easier:
- Add Task delete penalty
- Rework item rarity (Any item can be any rarity, rarity range is defined in config file)
- Add more item variety
- Debug Screen for:
    - See what's on the config files
- Change the app icon into something serious
- Improved / cleaner / smoother GUI
- Add crystal cap on user (maybe 5-10)+


Harder:
- Add Daily / Weekly tasks
- Add Daily login rewards
- Add lootboxes with animation
- Figure out what to do with crystals
- Add Achievements
- Add more item functionality
- Make items work
- Make items' functionality clear in the GUI
- Make statistics screen work
- Add firebase functions
- ML classifier for task labels -> Google colab -> Firebase etc
- Add SFX for everything

Things to keep in mind:
- Minimal to None popups
- Keep everything simple yet customizable



Brainstorming (Item randomization):
For each specific items:
- Rarity chance is fixed
- Base duration / effect of items are specificied in the item
- For each additional level, variance increases, base increases

rarity multiplies the base duration / effect / variance

baseDuration
baseEffect