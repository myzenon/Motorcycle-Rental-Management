const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const ipcMain = require('electron').ipcMain;
// ---------------------------------------------------------------
var mysqlConfig = require('./mysqlConfig.json');
var mysqlPool = require('mysql').createPool(mysqlConfig);
// ---------------------------------------------------------------
var debug = true;
require('./rental.js')(ipcMain, mysqlPool, debug);
require('./motorcycle.js')(ipcMain, mysqlPool, debug);
// ---------------------------------------------------------------
var mainWindow = null;
app.on('window-all-closed', function() {
  app.quit();
});
app.on('ready', function() {
  var electronScreen = electron.screen;
  var size = electronScreen.getPrimaryDisplay().workAreaSize;
  mainWindow = new BrowserWindow({
    width : 1024,
    height : Math.ceil(size.height/1.25),
    minWidth : 1024,
    minHeight: Math.ceil(size.height/1.25),
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
