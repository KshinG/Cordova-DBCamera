var argscheck = require('cordova/argscheck'),
exec = require('cordova/exec');

_logMessage = function(message){
  return console.log(message);
};

exports.openCamera = function(success, error) {
    success = success || _logMessage;
    error = error || _logMessage;
    exec(success, error, "DBCamera", "openCamera", []);
};

exports.openCameraWithSettings = function(success, error) {
    success = success || _logMessage;
    error = error || _logMessage;
    exec(success, error, "DBCamera", "openCameraWithSettings", []);
};

exports.openCustomCamera = function(success, error, options) {
     success = success || _logMessage;
     error = error || _logMessage;
     options = options || {};
     var getValue = argscheck.getValue;
     var sceneText = getValue(options.sceneText, "No Text");
     var targetWidth = getValue(options.targetWidth, -1);
     var targetHeight = getValue(options.targetHeight, -1);
     var args = [sceneText,targetWidth,targetHeight];
     exec(success, error, "DBCamera", "openCustomCamera", args);
};

exports.openCameraWithoutSegue = function(success, error) {
    success = success || _logMessage;
    error = error || _logMessage;
    exec(success, error, "DBCamera", "openCameraWithoutSegue", []);
};

exports.openCameraWithoutContainer = function(success, error) {
    success = success || _logMessage;
    error = error || _logMessage;
    exec(success, error, "DBCamera", "openCameraWithoutContainer", []);
};

exports.cleanup = function(success, error) {
    success = success || _logMessage;
    error = error || _logMessage;
    exec(success, error, "DBCamera", "cleanup", []);
};