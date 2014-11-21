Spearal iOS Sample Application
==============================

A sample iPhone application based on SpearalIOS / Spring MVC / JPA2.

## How to run the demo?

Clone (recursively) this repository:

````bash
$ git clone --recursive https://github.com/spearal-examples/spearal-example-ios.git
````

Start XCode 6.1 (other versions may not work) and open the `spearal-example-ios/spearal-example-ios.xcworkspace` file. You can then run the demo by clicking on the top-left arrow of the workspace window (make sure the "SpearalIOSExample" target is selected).

If you get an error, this is likely due to OpenShift hibernating the server application if it wasn't used recently. Browse to https://examples-spearal.rhcloud.com/spring-angular/index-spearal.html and hit refresh until the application wakes up. Then, rerun the iOS demo.
