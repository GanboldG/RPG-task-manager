In progress:

To Do:
- Add statistics fields to user (total time, completed task, daily login streaks)
- Update the statistics everytime task is deleted / completed etc
- Show the statistics on profile in very fancy way
- Achievement screen
- Sort option on task list:
    - After sorting, the list key should be recalculated
    - "Sort by date, time left, closest deadline, alphabetical etc"
- Add logout button

- Clear hive boxes when logging out / logging in (Make logout method call "Reset every hive boxes")
- Shop Item stored locally with Hive, with timer that refreshes s
- Make shop items reset every 2 hours
- Option to create / update profile
- Custom item images loads after seconds (janky)
- Make login not download images for 30 seconds
- Make items work
- Add SFX for everything
- Make task service a singleton
- Make it possible to download mapped data (tasks, stats) into json
- Make the app not turn off with screen turn-off time
- Debug Screen for:
    - Changing config json files
- Add reward collecting animation
- Fix the jankiness in task creation
- Show expanded item info when pressed from inventory
- Add Daily / Weekly tasks
- Add Daily login reward
- Add lootboxes with animation
- Figure out what to do with crystals
- Add deadline calculation (The faster you complete the more you get)
- Full friends / leaderboard functionality
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
- Create users/userid/tasks, users/userid/custom_items collections in firestore
- Create a button that uploads tasks / user / custom items to firestore
- Add character limit for tasks / custom item fields
- Add limit of 60 for tasks, 10 daily, 10 weekly = 120
- Add custom_shop size as User variable
- Store the last 100 finished tasks locally, and show on profile