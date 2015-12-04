angular.module('motorcycleApp')
  .config(function ($routeProvider) {
   $routeProvider
     .when('/', {
       templateUrl : 'templates/Rental.html',
       controller : 'RentalCtrl'
     })
     .when('/motorcycle', {
       templateUrl : 'templates/motorcycle.html',
       controller : 'MotorcycleCtrl'
     })
     .otherwise({ redirectTo: '/' })
   ;
  })
;
