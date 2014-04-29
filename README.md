# Purpose

ACPReminder provides automatic local notificacions, for example, to marketing your app or explain to user different use cases of your app... It will schedule automatically some predefined messages when the user closes the application, and it will be triggered, if the user doesn't open the app in that predefined period of time.
</br></br>
<p align="center">
<img src="image.png" width="400px" height="251px" align="center"/>
</p>
</br>

## Installation
</br>
### From CocoaPods

	pod `ACPReminder` 

### From source

Clone the repository

[*$ git clone git@github.com:antoniocasero/ACPReminder.git*]()

Or just drag ACPReminder(.h.m) to your project.

</br>
## How to use it

You just need to import the class **ACPReminder** in your `appDelegate` 

- In the method `applicationDidEnterBackground:(UIApplication *)application`. 

```
ACPReminder * localNotifications = [ACPReminder sharedInstance];
[local createLocalNotification];
```
It will schedule your local notification, 

- In the method `applicationDidBecomeActive:(UIApplication *)application`  add this line of code

```
[localNotifications checkIfLocalNotificationHasBeenTriggered];
``` 
 It will check if we have any local notification scheduled, if the notification has not been triggered, it will reset it.
 
### Configuration

You can define the messages that you want to present to the user, the way to present the messages could be random/sequential, scheduling the time between the messages..

####Properties
```
@property (nonatomic, strong) NSArray* messages;
```
Array of strings, contains the messages that you want to present as local notifications.

```
@property (nonatomic, strong) NSArray* timePeriods;
```
Array of time periods, between the local notification presented and the next one.

```
@property (nonatomic, assign) BOOL randomMessage;
```

This property controls how the messages are selected from the array. If the attribute is YES, the message will be selected from the array randomly, if the flag is NO, sequentially (by default).

```
@property (nonatomic, assign) BOOL circularTimePeriod;
```

The array of time periods is sequential, if the attribute is set to YES when the last element is taken, the next one will be the first element. Otherwise it will keep the last element.



</br>

**Remember**, with great power comes great responsibility. You know what I mean..

</br>

## Compatibility

- Supports ARC. 
- Compatible with iOS5+.

## Release Notes

- v1.0 Initial release

## License

`ACPReminder` is available under the MIT license. See the LICENSE file for more info.

