angular.module('motorcycleApp')
  .config(function ($routeProvider) {
   $routeProvider
     .when('/', {
       templateUrl : 'templates/rental.html',
       controller : 'RentalCtrl'
     })
     .when('/rent/add', {
       templateUrl : 'templates/rental-add-select.html',
       controller : 'RentalAddSelectCtrl'
     })
     .when('/rent/add/:id', {
       templateUrl : 'templates/rental-add.html',
       controller : 'RentalAddCtrl'
     })
     .when('/rent/add/success/:amount', {
       templateUrl : 'templates/rental-add-success.html',
       controller : 'RentalAddSuccessCtrl'
     })
     .when('/rent/', {
       templateUrl : 'templates/rental-view-select.html',
       controller : 'RentalViewSelectCtrl'
     })
     .when('/rent/:id', {
       templateUrl : 'templates/rental-view.html',
       controller : 'RentalViewCtrl'
     })
     .when('/rent/success/:amount', {
       templateUrl : 'templates/rental-return-success.html',
       controller : 'RentalReturnSuccessCtrl'
     })
     .when('/motorcycle', {
       templateUrl : 'templates/motorcycle.html',
       controller : 'MotorcycleCtrl'
     })
     .when('/motorcycle/:id', {
       templateUrl : 'templates/motorcycle-view.html',
       controller : 'MotorcycleViewCtrl'
     })
     .when('/repair/:id', {
       templateUrl : 'templates/repair.html',
       controller : 'RepairCtrl'
     })
     .otherwise({ redirectTo: '/' })
   ;
  })
;
