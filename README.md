# Genar CMD
A Windows command-line software for generating installable android app versions of your website.


## Getting Started
To successfully get Genar CMD to run, you need `Command Prompt` and `Windows PowerShell` which are mostly installed out-of-the-box on newer Windows versions.<br>

Once that is set, follow the steps below to setup Genar CMD.<br>

**Step 1.** Clone this repo to your local computer.<br>
**Step 2.** From your File Explorer, Navigate to the folder of the cloned repo.<br>
**Step 3.** Run/Start `kick_start.bat` and follow the initial setup instructions on the `Prompt`.<br>

`kick_start.bat` process includes checking for, downloading and setting up (if not found or not well setup) all the necessary environment variables required to be able to run the app generation process.


## Generating Your App
The current version of Genar CMD provides very limited configuration input for an app generation.<br>

You can find the configuration values in the `gen_config.json` file. Alter the values to your preference - in accordance to the appropriate format. See [Configuration Values](#configuration_values).<br>

Once you are done setting up your app's configuration, follow the steps below to start your build process.<br>

**Step 1.** Run/Start `gen_app.bat` and follow the build process instructions on the `Prompt`.<br>
**Step 2.** Once your build has been successfully completed. You can find the output `.apk` in the `output` folder located at the root folder of the cloned repo.<br>


## Configuration Values
Below are the configuration values required for an app generation process.<br>
**NOTE:** These values can be found in the `gen_config.json` file in the project root folder.<br>

| Key | Value Type | Description |
| --- | --- | --- |
| `appName` | string | The name of your app. |
| `appIcon` | string | File name of your app.<br> This file should exist in the `gen_assets` folder before running the `gen_app.bat` script. |
| `splashIcon` | string | File name of the icon you want on your app's splash screen.<br> This file should also exist in the `gen_assets` folder before running the `gen_app.bat` script. |
| `baseUrl` | string | The URL of your website.<br> This will be loaded as the main activity of your app when it launches. |
| `colorPrimary` | string | A 7-lenght-hex-string value of your app's primary color.<br> Example is: #FFFFFF. |
| `colorAccent` | string | A 7-lenght-hex-string value of your app's accent color.<br> Example is: #FFFFFF. |
| `pullToRefresh` | boolean | Whether or not to enable pull-to-refresh feature.<br> Note: This feature is still being perfected and may act buggy sometimes. |


## Extras
Utility functions (including base project setup, configuration synchronizing and other file migrations) logic can be found in `jar_helpers/FileUtil.java`.<br>
Any altrations to this logic will require a new Java compilation.<br>
Compilation can be done by following the steps below.<br>

**Step 1.** Open your Command Prompt and CD into the root folder of the cloned project.<br>
**Step 2.** Run `javac jar_helpers/FileUtil.java` command to compile your changes.<br>

NOTE:: Compilation will ONLY work after Genar CMD has already been successfylly setup (`kick_start.bat`) has been executed successfully.<br>
This is because, Java 17 would be installed and made available in any new Command Prompt session.


## Contributions & Support
Genar CMD welcomes contributions and support of any form to enabe it to expand and even make iOS builds possible on Apple™ computers.


## License
MIT
