In progress:
- Achievement screen
- Add reward collecting animation
- Add a lot of animations
- Add SFX for everything

- Make app work in the background, with full noification control
- Make the app not turn off with screen turn-off time


To Do:
- Make shop items reset every 2 hours (Shop Item stored locally with Hive, with timer that refreshes)
- Make it possible to load tasks from json file
- Make achievements work
- Make items work
- Make shop reroll work
- Add more items
- Full friends / leaderboard functionality
- Help functions to explain the app
- Option to create / update profile
- Clear hive boxes when logging out / logging in (Make logout method call "Reset every hive boxes")
- Fix custom item images loading every seconds (janky)
- Make login not download images for 30 seconds
- Settings for changing config json files
- Fix the jankiness in task creation
- Show expanded item info when pressed from inventory
- Add Daily / Weekly tasks
- Make logout function actually work instead of shutting down the app
- Add Daily login reward
- Figure out what to do with crystals
- Add deadline calculation (The faster you complete the more you get)
- ML classifier for task labels -> Google colab -> Firebase etc
- Use real SHA fingerprints instead of the debug one
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
- Add simple user statistics overview functions
- Add logout button
- Sort option on task list
- Add detailed statistics
- Add lootboxes with animation
- Fix item generation bug where OP items are cheaper
- Make it possible to download mapped data (tasks, stats) into json