# Pinta 

AMF service test and debug utility

## AMF debugging made easy
Pinta is a utility that allows a developer to make custom AMF service calls, and view detailed output. The developer can use this utility to test services without having to develop a client application. Automatic service discovery can be used to detect available services (currently only for AMFPHP), and they can be defined manually.

## Features

* Tree, text and debug view on call results
* AMFPHP auto service discovery support
* Cross-platform Adobe AIR application
* JSON notation for sending Object parameters

## Installation
* Install the Adobe AIR runtime environment from http://get.adobe.com/air/
* Download the latest Pinta version on the right
* Open the downloaded installer. Magic will happen.

## Usage
* Create a connection profile by specifying a gateway (endpoint) URL and name
* Specify service names and methods in them, or use the auto-discovery feature if the server is using AMFPHP and has the service browser installed (which is default)
* Make calls to methods in the lower panel and observe the output
