# task_manager_app

A project made using Flutter as Front End and using Cloud BackApp as Backend As A Service (BaaS).

## Getting Started

This project is a starting point for our Flutter application.

To setup this project, please follow the below steps:
1) Install Flutter, if using macOS, you can install using homebrew. Else you can manually install as well.

2) Install cocoapods from homebrew if using macOS, else install it manually.

3) Our project consists of 3 screens, including login, register and task management page, where the user is allowed
to perform CRUD operations on the number of tasks he is assigned. In our case, the user is registered as a Student. 
    3.1) The files login_page.dart, register_page.dart, task_page.dart are created and logic inside it is for the user to login if 
    it is an existing user, register itself as a user to the application if he is a new user, and a Task Page, where he is allowed to create, view, update and delete his tasks based on his preferences. 

4) Create main.dart file which would be the entry point of the application and will make the connection to the Back4App Cloud Database.

5) Create your databases and tables inside after logging into Back4App application which would be user and Task. You can log in to the
Back4App dashboard from: https://parseapi.back4app.com/ .

6) Once the databases and tables are created, you can go to the base directory and follow the following steps:
    6.1) flutter clean: Cleans all the dependencies. 
    6.2) flutter pub get: Downloads all the dependencies and refreshes it
    6.3) flutter run: Runs the application, the command can vary with flutter run -d <platform_name> based on the platform we are running
    the application. 