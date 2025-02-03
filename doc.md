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

### Firebase 
#### init
1. Sign in to your [Firebase](https://console.firebase.google.com/) account. Once you're in, click the “Create a project” button;

2. Enter your desired project name in the field provided, then click “Continue”;

3. Next up is deciding on Google Analytics for your project. You have the option to keep it enabled or disable it if you prefer not to use it. Once you've made your choice, click “Continue”;
4. After setting up Google Analytics, confirm your project creation by clicking the “Create project” button;
5. Your Firebase project is now ready. Click “Continue” to open the Firebase project control panel;
6. In the menu on the left, go to “Project Overview” -> “Project settings” page;
7. In the “Project settings” page, switch over to the “Cloud Messaging” tab. Here, ensure the Firebase Cloud Messaging API is enabled to use messaging features;
8. Head over to the “Service accounts” tab next. Within the “Admin SDK configuration snippet”, select the “Java” section. Then, click on the “Generate new private key” button. This action will generate a private key for your service account - crucial for secure server communication;
9. Confirm the generation of your private key by clicking on the “Generate key” button. Keep this key safe, as you'll need it for the ThingsBoard server-side operations;

To integrate Firebase into the mobile application, you’ll need to complete the initial two steps outlined in the [“Add Firebase to your Flutter app”](https://firebase.google.com/docs/flutter/setup) guide available at Firebase’s official documentation.

#### FireStore


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
...
        case Authority.CUSTOMER_USER:
          items.addAll([

// added the below

            MoreMenuItem(            
              title: "Profile",       
              icon: Icons.settings,   
              path: '/profile'),      

// added the above

            MoreMenuItem(
                title: '${S.of(context).assets}',
                icon: Icons.domain,
...
```

```
...
child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

// deleted below codes

        Row(  
            crossAxisAlignment: CrossAxisAlignment.start,  
            children: [  
                Icon(Icons.account_circle,  
                    size: 48, color: Color(0xFFAFAFAF)),  
                Spacer(),  
                IconButton(  
                    icon: Icon(Icons.settings, color: Color(0xFFAFAFAF)),  
                    onPressed: () async {  
                    await navigateTo('/profile');  
                    setState(() {});  
                    })  
            ],  
        ),  

// deleted above codes

        SizedBox(height: 22),
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
...
```
Explanation: move the `Profile` bottom from the top right corner to one of the menu items with its title displayed explicitly.

#### Company Logo
> _lib/modules/home/home_page.dart_

```
...
                    ? tbContext.wlService.userLogoImage!
                    : SizedBox())),
        actions: [

// added codes below

          ColorFiltered(            
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

// added codes above 

          if (tbClient.isSystemAdmin())
            IconButton(
              icon: Icon(Icons.search),
...
```
The logo is added to the top right of the `Home` page. To change it, overwrite the file of `assets/images/logo.png`. Color filter is applied. If not needed, replace `ColorFiltered(......)` with `Image.asset('assets/images/logo.png')`

### Notification


>_lib/utils/services/notification_service.dart_

Added:  
`import 'package:cloud_firestore/cloud_firestore.dart';`  
`import 'package:firebase_core/firebase_core.dart';`  


The idea: 
* Save the FCM token to the firebase firestore database at the same time when it is saved to the Thingsboard database
* Use email address as the key mapping the token
* Send push notifications to the devices using the email address fetched from the firestore

Details:

```
...
    _tbContext = context;

    _log.debug('NotificationService::init()');
  
// added codes below

    final customerID = context.userDetails!.customerId.toString();  
    // get the customer id with format 

    final customerIDonly = customerID.substring(customerID.indexOf('{') + 5, customerID.indexOf('}'));
    // get the customer id without format i.e. the ID itself

    await FirebaseMessaging.instance.subscribeToTopic(
      customerIDonly,
    );
    // subscribe the topic of the id so that users with the same customer receive the same notifications

// added codes above

    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
...
```
```
...
  Future<void> _saveToken(
    String token, 

    // added the two parameters below
    String email, 
    String CustomerID

  ) async {
    await _tbClient.getUserService().saveMobileSession(
        token, MobileSessionInfo(DateTime.now().millisecondsSinceEpoch));

// added codes below

    // map the email address to the FCM token 
    final user = <String, dynamic>{
      "email": email,
      "token": token,
    };

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection(CustomerID).add(user).then((DocumentReference doc) =>
        print('DocumentSnapshot added with ID: ${doc.id}'));
    // add to the firestore the mapping
    // all users with the same customer are in the same 'collection' whose name is the customer ID

// added codes above
  }
...
```
```
...

  Future<String?> _resetToken(String? token, 

    // added the parameter
   String CustomerID

  ) async {
    if (token != null) {
      _tbClient.getUserService().removeMobileSession(token);
    }

// added codes below

    FirebaseFirestore db = FirebaseFirestore.instance;

    db.collection(CustomerID).where('token', isEqualTo: token).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
    // simple remove the old token invalid in the firestore

// added codes above

    await _messaging.deleteToken();
    return await getToken();
  }

...
```

Then, parse the required arguments to all calls of modified methods. e.g.  
`_saveToken(_fcmToken!, context.userDetails!.email, customerIDonly);`

#### Sending Notifications

