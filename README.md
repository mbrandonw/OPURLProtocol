OPURLProtocol
=============

A common use case for `NSURLProtocol` is to observe URLs being loaded in an application, or making simple tweaks to outgoing requests. Unfortunately this requires a lot of boilerplate code that creates `NSURLConnection` objects and implements all of the delegate methods. `OPURLProtocl` is a simple subclass that takes care of that for you so that you can focus on overriding the methods that interest you.
