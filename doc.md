# Thingsboard Mobile App for ChinoINT
_deployment document_

Offical Doc.: https://thingsboard.io/docs/pe/mobile/getting-started/

## Environment  
* >Notice: If Flutter is already installed, remove the original `flutter\bin` from the `PATH` before proceeding.

    Different Versions of Flutter (install [FVM](fvm.app) to manage them. You may find [chocolatey](https://chocolatey.org/install#individual) useful, with which FVM can be easily installed by `choco install fvm`.)
* [Source Codes](https://github.com/thingsboard/flutter_thingsboard_pe_app) of the app corresponding to your platform versions (note that platform version 3.7.0 (PE or not) requires app version 1.2.0, which is not shown in the chart in the offical documentation. Fetch by ```git clone -b release/1.2.0 https://github.com/thingsboard/flutter_thingsboard_pe_app.git```)
* [Android Studio](https://developer.android.com/studio)
* [Java 18](https://www.oracle.com/java/technologies/javase/jdk18-archive-downloads.html) (other versions may not work)

## Setup
### Android Studio
1. In the window with 
    >Welcome to Android Studio

    go to 
    `More Actions`

    then
    `SDK manager`

    find
    `SDK Tools`

    tick options: 
    >Android SDK Build-Tools  
    >Android SDK Command-line Tools  
    >Android Emulator  
    >Android SDK Platform-Tools  

    You may also want to have other verions of `SDK Platforms`.

    Click `Apply` or `OK` to install the chosen above.
2. In `More Actions`,  go to `Virtual Device Manager`.  
    Click the `+` bottom to create a Virtual Machine  
    Click the triangle to run the machine

_Problems may occur trying to start the machine. Check [this](https://stackoverflow.com/questions/67346232/android-emulator-issues-in-new-versions-the-emulator-process-has-terminated) for details.
To resolve, add an environment path for the emulator:
```path: C:\Users\<Your_Username>\AppData\Local\Android\Sdk\emulator```_


### Flutters

1. In terminal, ```fvm releases``` views all versions available.  
2. ```fvm install 3.19.0``` installs one version. ("3.19.0" could be any version. This version is chosen to be the example because it works well for the platform 3.7.0PE.)
3. change the current working directory to the source code (e.g. ```cd D:\...\flutter_thingsboard_app```) and ```fvm use 3.19.0``` 
4. `fvm flutter config --jdk-dir="D:\jdk18"` sets the Java version for the project (change `D:\jdk18` to the root directory where you install your java 18)
### Source Codes
1. Go to `lib/constants/app_constants.dart` and change the link in the line `static const thingsBoardApiEndpoint = 'somelink';` to `http://150.109.49.88:8080/` the api endpoint (or others).
2. In `pubspec.yaml`, change all `^` to `''`. For example, `   thingsboard_pe_client: ^1.2.0` is changed to `  thingsboard_pe_client: '1.2.0'`.

## Modification to the Codes
### Layout
#### Removal of `Alarms` and `Devices`

>_lib/modules/main/main_page.dart_
```
//             TbMainNavigationItem(
//                  page: AlarmsPage(tbContext),
//                  title: 'Alarms',
//                  icon: Icon(Icons.notifications),
//                  path: '/alarms'),
//             TbMainNavigationItem(
//                 page: DevicesMainPage(tbContext),
//                 title: 'Devices',
//                 icon: Icon(Icons.devices_other),
//                 path: '/devices'),
```
The above codes are commented out to hide the `Alarms` and `Devices` tabs at the bottom of the main page. If they are needed, remove the commentation `//`.
#### `More` page improvement
>_lib/modules/more/more_page.dart_

* Make `Profile` option more noticeable

```
        case Authority.CUSTOMER_USER:
          items.addAll([
            MoreMenuItem(             // added
              title: "Profile",       // added 
              icon: Icons.settings,   // added
              path: '/profile'),      // added
            MoreMenuItem(
                title: '${S.of(context).assets}',
                icon: Icons.domain,
```

```
...
child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
        Row(  // deleted
            crossAxisAlignment: CrossAxisAlignment.start,  // deleted
            children: [  // deleted
                Icon(Icons.account_circle,  // deleted
                    size: 48, color: Color(0xFFAFAFAF)),  // deleted
                Spacer(),  // deleted
                IconButton(  // deleted
                    icon: Icon(Icons.settings, color: Color(0xFFAFAFAF)),  // deleted
                    onPressed: () async {  // deleted
                    await navigateTo('/profile');  // deleted
                    setState(() {});  // deleted
                    })  // deleted
            ],  // deleted
        ),  // deleted
        SizedBox(height: 22),
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
...
```
Explanation: move the `Profile` bottom from the top right corner to one of the menu items with its title displayed explicitly.

#### Company Logo
> _lib/modules/home/home_page.dart_

```
                    ? tbContext.wlService.userLogoImage!
                    : SizedBox())),
        actions: [
          ColorFiltered(            // this added
            // invert the colors of the logo since it is white and the app bar is white
            colorFilter: const ColorFilter.matrix(<double>[
              -1.0, 0.0, 0.0, 0.0, 255.0,
              0.0, -1.0, 0.0, 0.0, 255.0,
              0.0, 0.0, -1.0, 0.0, 255.0,
              0.0, 0.0, 0.0, 1.0, 0.0,
            ]),
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
          if (tbClient.isSystemAdmin())
            IconButton(
              icon: Icon(Icons.search),
```
The logo is added to the top right of the `Home` page. To change it, overwrite the file of `assets/images/logo.png`. Color filter is applied. If not needed, replace `ColorFiltered(......)` with `Image.asset('assets/images/logo.png')`

### Notification