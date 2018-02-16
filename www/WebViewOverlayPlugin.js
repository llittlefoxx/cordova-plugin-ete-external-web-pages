/**
 * Created by Mohamed ali Tlili
 * mohamedali.tlili@esprit.tn
 * mohamedali.tlili@etecture.de
*/

function WebViewOverlayPlugin() {};
/*
 *  urlString : 
 *  String of the URL that you would like to open in an external webview.
 *  
 *  webViewType :
 *  "simple" for a webview without navigation buttons.
 *  "extended" for a webview with navigation buttons.
 *  "fullscreen"for a webview without navigation and close button
 *  
 *  titleString : 
 *  String value that if you provide will be used as title for the ecternal webview.
 */
WebViewOverlayPlugin.prototype.open = function (successCallback, urlString, webViewType, titleString) {
    var params = [urlString];
    if (titleString != null) {
        params.push(titleString);
    }
    if (webViewType != null) {
        params.push(webViewType);
    }
	cordova.exec(successCallback, null, 'WebViewOverlayPlugin', 'open', params);
};

// closing the external webview
WebViewOverlayPlugin.prototype.close = function() {
	cordova.exec(null, null, 'WebViewOverlayPlugin', 'close', []);
};

// Attaching the webViewOverlay object to the window object
window.webViewOverlay = new WebViewOverlayPlugin();