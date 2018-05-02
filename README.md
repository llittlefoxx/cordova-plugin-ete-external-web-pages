# cordova-plugin-ete-external-web-pages
This is a Cordova plugin which opens and closes a webview.

## Installation

    cordova plugin add git+ssh://git@git.mercedes-benz.com:mtlili/cordova-plugin-WebViewOverlayPlugin.git

## Platform 
iOS

## Usage
Using the plugin form your javascript code 
### Open an URL in an external browser 
Example :
```javascript
    webViewOverlay.open(successCallback, urlString, webViewType, titleString);
```
#### parameters
urlString : 
String of the URL that you would like to open in an external webview.

webViewType :
"simple" for a webview without navigation buttons.
"extended" for a webview with navigation buttons.
"fullscreen"for a webview without navigation and close button
 
titleString : 
String value that if you provide will be used as title for the ecternal webview.

### Closing the external browser
Example :
 ```javascript
    webViewOverlay.close();
```
