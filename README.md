In progress:
- Create users/userid/tasks, users/userid/custom_items collections in firestore
- Create a button that uploads tasks / user / custom items to firestore

To Do:
- Add character limit for tasks / custom item fields
- Add limit of 100 for tasks, 10 daily, 10 weekly = 120
- Store the last 100 finished tasks locally
- Clear hive boxes when logging out / logging in (Make logout method call "Reset every hive boxes")
- Remove abandoned tasks box
- Only store the last 10 completed tasks in hive only
- Update the statistics everytime task is deleted / completed etc
- Shop Item stored locally with Hive, with timer that refreshes 
- Make shop items reset every 2 hours
- Option to create / update profile
- Add data such as total time, completed task, daily login streaks to user
- Fix high quality items being cheaper than low quality
- Achievement screen
- Add custom_shop size as User variable
- Sort option on task list
- Make items work
- Add SFX for everything
- Make task service a singleton
- Make the app not turn off with screen turn-off time
- Make statistics screen work
- Debug Screen for:
    - Changing config json files
- Add reward collecting animation
- Fix the jankiness in task creation
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
- Logout button
- In production is backend logic to delete images from cloudinary


Finished:
- Make custom item store locally (Hive)
- Make profile screen work
- Create login screen that pops up for the firs time users (Instead of creating static user model, create one using login data)
- Add rules to firestore
- Connect Firebase
- Create limit for custom items, equipped custom items
- Create achievements model
- Create static achievements in firestore, and only store the ids in user.achievements[] 
- Figure out how to upload images to firestore