angular.module('motorcycleApp')
  .controller('BarCtrl', function ($rootScope) {

  })
  .controller('RentalCtrl', function ($rootScope) {
    $rootScope.menu = 'rental';
  })
  .controller('MotorcycleCtrl', function ($rootScope) {
    $rootScope.menu = 'motorcycle';
  })
  .controller('ClockCtrl', function ($scope, $interval) {
    var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    var setNowDateTime = function () {
      var date = new Date();
      $scope.date = date.getDate();
      $scope.month = monthName[date.getMonth()];
      $scope.year = date.getFullYear();
      $scope.hours = date.getHours();
      $scope.minutes = date.getMinutes();
      $scope.seconds = date.getSeconds();
    };
    setNowDateTime();
    $interval(setNowDateTime, 1000);
  })
;
