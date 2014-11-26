function AudioEncode() {
}

encodeAudio.prototype.encodeAudio = function (filePath, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "AudioEncode", "encodeAudio", [filePath]);
};

AudioEncode.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.encodeAudio = new AudioEncode();
  return window.plugins.encodeAudio;
};

cordova.addConstructor(AudioEncode.install);
