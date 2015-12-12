const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const ipcMain = require('electron').ipcMain;
var fs = require('fs');
// ---------------------------------------------------------------
var checkExtensionImage = function (id, callback) {
  var path = './app/img/motorcycle/' + id;
  var searchFile = function (extension, index) {
    try {
      fs.statSync(path + '.' + extension[index]);
      callback(extension[index]);
    }
    catch(e) {
      if(index === extension.length - 1) {
        callback(null);
      }
      else {
        searchFile(extension, index + 1);
      }
    }
  };
  var extension = ['jpg', 'png', 'jpeg', 'gif', 'bmp',];
  searchFile(extension, 0);
};
// ---------------------------------------------------------------
var mysqlConfig = require('./mysqlConfig.json');
var mysqlPool = require('mysql').createPool(mysqlConfig);
// ---------------------------------------------------------------
var debug = true;
require('./rental.js')(ipcMain, mysqlPool, debug);
require('./motorcycle.js')(fs, checkExtensionImage, ipcMain, mysqlPool, debug);
// ---------------------------------------------------------------
var mainWindow = null;
app.on('window-all-closed', function() {
  app.quit();
});
app.on('ready', function() {
  var electronScreen = electron.screen;
  var size = electronScreen.getPrimaryDisplay().workAreaSize;
  mainWindow = new BrowserWindow({
    width : 1280,
    height : Math.ceil(size.height/1.1),
    frame : false
  });
  mainWindow.loadURL('file://' + __dirname + '/app/index.html');
  mainWindow.on('closed', function() {
    mainWindow = null;
  });
});
ipcMain.on('min-app', function () {
  mainWindow.minimize();
});
ipcMain.on('max-app', function () {
  if(mainWindow.isMaximized()) {
    mainWindow.unmaximize();
  }
  else {
    mainWindow.maximize();
  }
});
ipcMain.on('close-app', function () {
  app.quit();
});
ipcMain.on('check-extension-image', function (event, id) {
  checkExtensionImage(id, function (extension) {
    event.returnValue = extension;
  });
});
