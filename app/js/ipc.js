const ipcRenderer = require('electron').ipcRenderer;

ipcRenderer.on('mysql-error', function (event, error) {
  console.log(error);
  if(error.code === "ECONNREFUSED") {
    $('#mysql-unconnect').fadeIn();
    error.code = "Error : Can't Connect To Database Server";
  }
  else {
    Materialize.toast(error.code, 5000);
  }
});

ipcRenderer.on('add-rental-complete', function (event, data) {
  Materialize.toast('Rent Complete !!', 4000);
  location.href='#/rent/add/success/' + data;
});

ipcRenderer.on('return-rental-complete', function (event, data) {
  Materialize.toast('Return Complete !!', 4000);
  location.href='#/rent/success/' + data;
});

ipcRenderer.on('add-motorcycle-complete', function () {
  Materialize.toast('Add New Motorcycle Complete !!', 4000);
});

ipcRenderer.on('edit-motorcycle-complete', function () {
  Materialize.toast('Edit Motorcycle Complete !!', 4000);
});

ipcRenderer.on('update-repair-complete', function () {
  Materialize.toast('Update Repair Status Complete !!', 4000);
});
