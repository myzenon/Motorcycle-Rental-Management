window.jQuery = require('./components/jquery/dist/jquery.min.js');
window.$ = jQuery;
window.Hammer = require('./components/Materialize/js/hammer.min.js');


$.UrlExists = function(url) {
	var http = new XMLHttpRequest();
  console.log(http);
  http.onerror = function (error) {
    console.log(error);
  };
    http.open('GET', 'img/motorcycle/' + url, false);
    http.send();
    return http.response !== "";
};

var checkImage = function (id) {
  if($.UrlExists(id + '.png')) {
    return id + '.png';
  }
  else if($.UrlExists(id + '.jpg')) {
    return id + '.jpg';
  }
  else if($.UrlExists(id + '.jpeg')) {
    return id + '.jpeg';
  }
  else if($.UrlExists(id + '.gif')) {
    return id + '.gif';
  }
  else if($.UrlExists(id + '.bmp')) {
    return id + '.bmp';
  }
};
