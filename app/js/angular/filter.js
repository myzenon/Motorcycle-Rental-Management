angular.module('motorcycleApp')
  .filter('TwoDigits', function() {
    return function(input) {
      if(input < 10) {
          input = '0' + input;
      }
      return input;
    }
  })
  .filter('Status', function() {
    return function(status) {
      if(status === 'avaliable') {
        return 'Avaliable';
      }
      else if(status === 'rented') {
        return 'Rented';
      }
      else if(status === 'nrepair') {
        return 'Need To Repair';
      }
      else if(status === 'wrepair') {
        return 'Waiting for Repair';
      }
    }
  })
  .filter('DateReturn', function ($sce) {
    return function (date_return_expect) {
      var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      var dateNow = new Date();
      dateNow.setHours(0, 0, 0, 0);
      var date_return_expect = new Date(date_return_expect);
      if(dateNow.getTime() > date_return_expect.getTime()) {
        return $sce.trustAsHtml('<span class="badge expire">' + date_return_expect.getDate() + ' ' + monthName[date_return_expect.getMonth()] + ' ' + date_return_expect.getFullYear() + '</span>');
      }
      else {
        return $sce.trustAsHtml('<span class="badge">' + date_return_expect.getDate() + ' ' + monthName[date_return_expect.getMonth()] + ' ' + date_return_expect.getFullYear() + '</span>');
      }
    };
  })
;
