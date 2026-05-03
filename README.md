To Do:
- Create login screen that pops up for the firs time users (Instead of creating static user model, create one using login data)
- Connect Firebase
- Shop Item stored locally with Hive, with timer that refreshes 
- Make shop items reset every 2 hours
- Option to create / update profile
- Add data such as total time, completed task, daily login streaks to user
- Add custom_shop size as User variable
- Sort option on task list
- Make items work
- Add SFX for everything
- Make task service a singleton
- Make the app not turn off with screen turn-off time
- Make statistics screen work
- Debug Screen for:
    - Changing config json files
- Some animations
- Add reward collecting animation
- Show expanded item info when pressed from inventory
- Add Daily / Weekly tasks
- Add Daily login reward
- Add lootboxes with animation
- Figure out what to do with crystals
- Add Achievements
- Add more item functionality
- ML classifier for task labels -> Google colab -> Firebase etc
- Rework the GUI into something modern
- Use real SHA fingerprints instead of the debug one



Finished:
- Make custom item store locally (Hive)
- Make profile screen work


How login / signin works:
if user == null:
    show login screen:
        if sign with google:
            if user in firestore:
                download from firestore
                upload to hive
            else:
                creation screen:
                    upload to firestore
                    upload to hive

        else if work offline:
            creation screen:
                upload to hive