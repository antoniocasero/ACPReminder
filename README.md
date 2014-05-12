# Purpose

ACPReminder provides automatic local notifications, for example, to marketing your game or explain to user different use cases of your app... It will schedule automatically one of your predefined messages when the user closes your application, and it will be trigger, if the user doesn't open the app in a predefined period of time.</br>
</br></br>
<p align="center">
<img src="image.png" width="400px" height="251px" align="center"/>
</p>
</br>

## Installation
</br>
### From CocoaPods

	pod 'ACPReminder', '~> 1.0.0'

### From source

Clone the repository

[*$ git clone git@github.com:antoniocasero/ACPReminder.git*]()

Or just drag ACPReminder(.h.m) to your project.

</br>
## How to use it

You just need to import the class **ACPReminder** in your `appDelegate`. There is two main methods: 

- In the method `applicationDidEnterBackground:(UIApplication *)application`. 

```
ACPReminder * localNotifications = [ACPReminder sharedManager];
[localNotifications createLocalNotification];
```
It will schedule your local notification, 

- In the method `applicationDidBecomeActive:(UIApplication *)application`  add this line of code

```
[localNotifications checkIfLocalNotificationHasBeenTriggered];
``` 
 It will check if we have any local notification scheduled, if the notification has not been triggered, it will reset it.


###Properties
```
@property (nonatomic, strong) NSArray* messages;
```
Array of NSString, contains the messages that you want to present as local notifications. It's highly recommended to use NSLocalizedString.

```
@property (nonatomic, strong) NSArray* timePeriods;
```
Array of NSNumbers, define the time periods between the local notification presented and the next one. By default, the numbers represent days but there is an attribute, only for testing purposes, to convert those days into seconds. (@see sample code).

```
@property (nonatomic, assign) BOOL randomMessage;
```

This property controls how the messages are selected from the array. If the attribute is YES, the message will be selected from the array randomly, if the flag is NO, sequentially (by default).

```
@property (nonatomic, assign) BOOL circularTimePeriod;
```

The array of time periods is sequential, if the attribute is set to YES when the last element is taken, the next one will be the first element. Otherwise the next element will be the last one from the array again.


```
@property (nonatomic, strong) NSString* appDomain;
```

This attribute define the domain of your notifications, to prevent collisions.

####Example

    ACPReminder * localNotifications = [ACPReminder sharedManager];
    
    localNotifications.messages = @[@"Hey - This potion's really odd. Come and See", @"Your Village miss you"", @"Did you know our new features?"]; 
    localNotifications.timePeriods = @[@(7),@(10)];
    localNotifications.appDomain = @"com.mydomain.appName";

    [localNotifications createLocalNotification];


For more details on this, check the Sample Application in this repo.

</br>

**Remember**, with great power comes great responsibility. You know what I mean...

</br>

## Compatibility

- Supports ARC. 
- Compatible with iOS5, iOS6 and iOS7.

## Release Notes

- v1.0 Initial release

## License

`ACPReminder` is available under the MIT license. See the LICENSE file for more info.

