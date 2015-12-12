window.jQuery = require('./components/jquery/dist/jquery.min.js');
window.$ = jQuery;
window.Hammer = require('./components/Materialize/js/hammer.min.js');

var checkMotorcycleImage = function (id) {
  var extension = ipcRenderer.sendSync('check-extension-image', id);
  var css = {
    "background-image" : "url('" + (extension === null ? "img/moto.jpg" : "img/motorcycle/" + id + "." + extension) + "')"
  };
  return css;
};
