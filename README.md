# Walk Tracker

## About
It is a simple application which fetches user's location every 100 meters and load an image from Flickr to the list.

### Bonus

I have added some improvements to the behaviour of the application:
- Avoiding duplication of images (as no one likes having the same picture duplicated in its gallery)
- Recoverable - application first tries to fetch the image in 100 m radius. If that fails, it tries with 1 km radius.
- Caching of images
- Choosing proper size of image before fetching it

## Tech Stack
- Xcode 13.3.1
- SwiftUI
- Combine
- CoreLocation
- XCTest
- SF Symbols

## Before running app

If you are using simulator, make sure to have default location or GPX file chosen for your scheme (but it should be set). Lack of this casuses *CLLocationManager* to causes an error. The project contains three GPX:
- Warsaw-60KM:H
- Hamburg-30KM:H
- Amersfoort-15KM:H

## Schemes
- App Online - Use to connect with Flickr API
- App Offline - Use application without interacting with remote services (mechanism faking responses using JSON files in Project)
- Unit Tests - **Use for running tests**. It contains a mechanism for faking responses (the same which is used in App Offline)

## Configurations

Using one of 3 build configurations (and associated to them .xcconfig files):

- Debug
- Offline
- Release

## Architecture

Application is quite simple so it doesn't require complex architecture. Using simplified version of Onion-like architecture. It consists of:

- Data e.g. Repositories
- Domain e.g. UseCases
- Presentation e.g. View, ViewModels

## Possible Improvements

What could be improved:

### Automation

It's always good to have some kind of bootstrap.sh which would take advantage of such tools like *Tuist*, *XcodeGen* etc. to generate project files, assets, translations. It could be also used for registering *.xctemplate* files to autogenerate code which is repeating.

### Modularisation

It's small app but if it would grow up a lot, it could be modularised using frameworks or packages from Swift Package Manager - XcodeGen could be used for that.

### Code generation

*Sourcery* could be used for auto-creation of the code.

### Tests

It would be very useful to configure Snapshot and UI Tests to the application which could be treated as Smoke Tests.
 **There is an implementation of few tests for repositories, useCases and viewModels. In real world, I would do tests for all of the objects.**

### CI / CD

For code reviews and deployment e.g. fastlane + Bitrise.
