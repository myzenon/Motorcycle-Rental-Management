angular.module('motorcycleApp')
  .controller('BarCtrl', function ($rootScope, $scope) {
    $rootScope.$watch('menu', function () {
      if($rootScope.menu == "rental-success") {
        $scope.back = function () {
          location.href="#/";
        };
      }
      else {
        $scope.back = function () {
          window.history.back();
        };
      }
    });
  })
  .controller('RentalCtrl', function ($rootScope, $scope) {
    $rootScope.menu = 'rental';
    $scope.getRentalsList = function (search) {
      var rentalsListDB = ipcRenderer.sendSync('get-rental-list');
      var dateNow = new Date();
      dateNow.setHours(0, 0, 0, 0);
      var rentalsListToday = [];
      var rentalsListExpire = [];
      for(key in rentalsListDB) {
        var rental = rentalsListDB[key];
        if(!rental.date_return_returned) {
          var date_return_expect = new Date(rental.date_return_expect);
          if(dateNow.getTime() > date_return_expect.getTime()) {
            rentalsListExpire.push(rental);
          }
          else if(dateNow.getTime() === date_return_expect.getTime()) {
            rentalsListToday.push(rental);
          }
        }
      }
      $scope.rentalsListToday = rentalsListToday;
      $scope.rentalsListExpire = rentalsListExpire;
    };
    $scope.getRentalsList();
  })
  .controller('RentalAddSelectCtrl', function ($rootScope, $scope) {
    $rootScope.menu = 'rental';
    $scope.getMotorcyclesList = function (search) {
      var motorcyclesListDB;
      if(search) {
        motorcyclesListDB = ipcRenderer.sendSync('get-motorcycle-list-search', { filter : true, search : search });
      }
      else {
        motorcyclesListDB = ipcRenderer.sendSync('get-motorcycle-list', { filter : true });
      }
      var motorcyclesList = {};
      for(index in motorcyclesListDB) {
        var brand = motorcyclesListDB[index].brand_name;
        if(motorcyclesList[brand] === undefined) {
          motorcyclesList[brand] = [];
        }
        motorcyclesList[brand].push(motorcyclesListDB[index]);
      }
      $scope.motorcyclesList = motorcyclesList;
    };
    $scope.$watch('search', function () {
      $scope.getMotorcyclesList($scope.search);
    });
  })
  .controller('RentalAddCtrl', function ($rootScope, $scope, $routeParams) {
    $rootScope.menu = 'rental';
    $scope.motorcycle = ipcRenderer.sendSync('get-motorcycle-view', $routeParams.id)[0];
    $scope.getNextDate = function (amount, type, mode) {
      var date = new Date();
      if(mode === 'day') {
        date.setDate(date.getDate() + amount);
      }
      else if(mode === 'month') {
        date.setMonth(date.getMonth() + amount);
      }
      if(type === 1) {
        var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        return date.getDate() + ' ' + monthName[date.getMonth()] + ' ' + date.getFullYear();
      }
      else if(type === 2) {
        return date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
      }
    };
    $scope.form = {
      motorcycle_id : $scope.motorcycle.id,
      firstname : '',
      lastname : '',
      phone : '',
      dlnum : '',
      cznum : '',
      type : null,
      day : null,
      month : null
    };
    $scope.addRental = function () {
      if($scope.form.firstname == '') {
        Materialize.toast('Error : Please Input First Name', 3000);
      }
      else if($scope.form.lastname == '') {
        Materialize.toast('Error : Please Input Last Name', 3000);
      }
      else if($scope.form.phone == '') {
        Materialize.toast('Error : Please Input Phone Number', 3000);
      }
      else if(!$scope.form.phone.match(/^\d{10}$/)) {
        Materialize.toast('Error : Please Input Phone Number only 10 Digits', 3000);
      }
      else if($scope.form.model === '') {
        Materialize.toast('Error : Please Input Model of Motorcycle', 3000);
      }
      else if($scope.form.dlnum === '') {
        Materialize.toast('Error : Please Input Driving License Number', 3000);
      }
      else if($scope.form.cznum === '') {
        Materialize.toast('Error : Please Input Citizen Number / Passport', 3000);
      }
      else if($scope.form.type === null) {
        Materialize.toast('Error : Please Select Type to Rent', 3000);
      }
      else if(($scope.form.type === 'day') && (($scope.form.day === null) || ($scope.form.day === '') || ($scope.form.day === 0))) {
        Materialize.toast('Error : Please Input Amount of Days to Rent', 3000);
      }
      else if(($scope.form.type === 'day') && (parseInt($scope.form.day) != $scope.form.day)) {
        Materialize.toast('Error : Please Input Amount of Days Only 1 to 1000', 3000);
      }
      else if(($scope.form.type === 'month') && (($scope.form.month === null) || ($scope.form.month === '') || ($scope.form.month === 0))) {
        Materialize.toast('Error : Please Input Amount of Months to Rent', 3000);
      }
      else if(($scope.form.type === 'month') && (parseInt($scope.form.month) != $scope.form.month)) {
        Materialize.toast('Error : Please Input Amount of Months Only 1 to 100', 3000);
      }
      else {
        if($scope.form.type === 'day') {
          $scope.form.amount = $scope.form.day;
          $scope.form.price = $scope.motorcycle.price_per_day;
          $scope.form.date_return_expect = $scope.getNextDate($scope.form.amount, 2, 'day');
          $scope.form.total_cost = ($scope.form.amount * $scope.motorcycle.price_per_day) + $scope.motorcycle.collateral;
        }
        else {
          $scope.form.amount = $scope.form.month;
          $scope.form.price = $scope.motorcycle.price_per_month;
          $scope.form.date_return_expect = $scope.getNextDate($scope.form.amount, 2, 'month');
          $scope.form.total_cost = ($scope.form.amount * $scope.motorcycle.price_per_month) + $scope.motorcycle.collateral;
        }
        $scope.form.collateral = $scope.motorcycle.collateral;
        ipcRenderer.send('add-rental', $scope.form);
      }
    };
    $('input').characterCounter();
  })
  .controller('RentalViewSelectCtrl', function ($rootScope, $scope, $sce) {
    $rootScope.menu = 'rental';
    $scope.showDate = function (date, check) {
      var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      var date_return_expect = new Date(date);
      return date_return_expect.getDate() + ' ' + monthName[date_return_expect.getMonth()] + ' ' + date_return_expect.getFullYear();
    };
    $scope.checkDate = function (date_return_returned, date_return_expect) {
      if(!date_return_returned) {
        return $sce.trustAsHtml('<span class="badge">Rented</span>');
      }
      var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      var date_return_returned = new Date(date_return_returned);
      var date_return_expect = new Date(date_return_expect);
      if(date_return_returned.getTime() > date_return_expect.getTime()) {
        return $sce.trustAsHtml('<span class="badge expire">' + date_return_returned.getDate() + ' ' + monthName[date_return_returned.getMonth()] + ' ' + date_return_returned.getFullYear() + '</span>');
      }
      else {
        return $sce.trustAsHtml('<span class="badge">' + date_return_returned.getDate() + ' ' + monthName[date_return_returned.getMonth()] + ' ' + date_return_returned.getFullYear() + '</span>');
      }
    };
    $scope.getRentalsList = function (search) {
      var rentalsListDB;
      if(search) {
        rentalsListDB = ipcRenderer.sendSync('get-rental-list-search', search);
      }
      else {
        rentalsListDB = ipcRenderer.sendSync('get-rental-list');
      }
      var rentalsList = {};
      for(index in rentalsListDB) {
        var date_rent = $scope.showDate(rentalsListDB[index].date_rent);
        if(rentalsList[date_rent] === undefined) {
          rentalsList[date_rent] = [];
        }
        rentalsList[date_rent].push(rentalsListDB[index]);
      }
      $scope.rentalsList = rentalsList;
    };
    $scope.$watch('search', function () {
      $scope.getRentalsList($scope.search);
    });
  })
  .controller('RentalViewCtrl', function ($rootScope, $scope, $routeParams, $sce) {
    $rootScope.menu = 'rental';
    $scope.rental = ipcRenderer.sendSync('get-rental-view', $routeParams.id)[0];
    $scope.form = {
      id : $scope.rental.id,
      collateral : $scope.rental.collateral,
      nrepair : $scope.rental.nrepair === 1 ? true : false,
      fine : $scope.rental.fine
    };
    $scope.returnRental = function () {
      if((parseInt($scope.form.fine) != $scope.form.fine) && ($scope.form.fine !== null)) {
        Materialize.toast('Error : Please Input Fine Only In Integer Format', 3000);
      }
      else {
        ipcRenderer.send('return-rental', $scope.form);
      }
    };
    $scope.showDate = function (date, check) {
      var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      var date_return_expect = new Date(date);
      return date_return_expect.getDate() + ' ' + monthName[date_return_expect.getMonth()] + ' ' + date_return_expect.getFullYear();
    };
    $scope.checkDate = function (date_return_returned, date_return_expect) {
      var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      var date_return_returned = new Date(date_return_returned);
      var date_return_expect = new Date(date_return_expect);
      if(date_return_returned.getTime() > date_return_expect.getTime()) {
        return $sce.trustAsHtml('<span style="color: #F00;">' + date_return_returned.getDate() + ' ' + monthName[date_return_returned.getMonth()] + ' ' + date_return_returned.getFullYear() + '</span>');
      }
      else {
        return $sce.trustAsHtml(date_return_returned.getDate() + ' ' + monthName[date_return_returned.getMonth()] + ' ' + date_return_returned.getFullYear());
      }
    };
    $scope.getNextDate = function (start, amount, type, mode) {
      var date = new Date(start);
      if(mode === 'day') {
        date.setDate(date.getDate() + amount);
      }
      else if(mode === 'month') {
        date.setMonth(date.getMonth() + amount);
      }
      if(type === 1) {
        var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        return date.getDate() + ' ' + monthName[date.getMonth()] + ' ' + date.getFullYear();
      }
      else if(type === 2) {
        return date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
      }
    };
  })
  .controller('MotorcycleCtrl', function ($rootScope, $scope, $templateRequest, $compile) {
    $rootScope.menu = 'motorcycle';
    $scope.nrepairList = ipcRenderer.sendSync('get-repair-n');
    $scope.wrepairList = ipcRenderer.sendSync('get-repair-w');
    $scope.getMotorcyclesList = function (search) {
      var motorcyclesListDB;
      if(search) {
        motorcyclesListDB = ipcRenderer.sendSync('get-motorcycle-list-search', { filter : false, search : search });
      }
      else {
        motorcyclesListDB = ipcRenderer.sendSync('get-motorcycle-list', { filter : false });
      }
      var motorcyclesList = {};
      for(index in motorcyclesListDB) {
        var brand = motorcyclesListDB[index].brand_name;
        if(motorcyclesList[brand] === undefined) {
          motorcyclesList[brand] = [];
        }
        motorcyclesList[brand].push(motorcyclesListDB[index]);
      }
      $scope.motorcyclesList = motorcyclesList;
    };
    $scope.addMotorcycle = function () {
      $templateRequest('templates/motorcycle-add.html').then(function (template) {
        $compile($("#add-box").html(template).contents())($scope);
        $('#addMotorcycle').openModal();
      });
    };
    $scope.$watch('search', function () {
      $scope.getMotorcyclesList($scope.search);
    });
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
  .controller('MotorcycleAddCtrl', function ($rootScope, $scope, $route) {
    $scope.brands = ipcRenderer.sendSync('get-brand');
    $scope.brands.unshift({ id : 0, name : ' # Create New Brand' });
    var findBrand = function (brand) {
      var check = false;
      $scope.brands.forEach(function (brand_in_list) {
        if(brand_in_list.name === brand) {
          check = true;
        }
      });
      return check;
    };
    var checkExist = function (value) {
      if(value === null) {
        return false;
      }
      else if(value === '') {
        return false;
      }
      else if(value === undefined) {
        return false;
      }
      return true;
    };
    $scope.resetForm = function () {
      $scope.form = {
        brand : '',
        brand_new : '',
        model : '',
        plate_number : '',
        cost : '',
        collateral: '',
        price_per_day : '',
        price_per_month : ''
      };
    };
    $scope.resetForm();
    $scope.addForm = function () {
      if($scope.form.brand == '') {
        Materialize.toast('Error : Please Select Brand of Motorcycle', 3000);
      }
      else if(($scope.form.brand.id == 0) && ($scope.form.brand_new === '')) {
        Materialize.toast('Error : Please Input New Brand Name', 3000);
      }
      else if(findBrand($scope.form.brand_new)) {
        Materialize.toast('Error : New Brand Name has already in list', 3000);
      }
      else if($scope.form.model === '') {
        Materialize.toast('Error : Please Input Model of Motorcycle', 3000);
      }
      else if($scope.form.plate_number === '') {
        Materialize.toast('Error : Please Input Plate Number of Motorcycle', 3000);
      }
      else if(!checkExist($scope.form.cost)) {
        Materialize.toast('Error : Please Input Cost In Positive Integer Format', 3000);
      }
      else if(parseInt($scope.form.cost) != $scope.form.cost) {
        Materialize.toast('Error : Please Input Cost Only In Positive Integer Format', 3000);
      }
      else if(!checkExist($scope.form.collateral)) {
        Materialize.toast('Error : Please Input Collateral In Positive Integer Format', 3000);
      }
      else if(parseInt($scope.form.collateral) != $scope.form.collateral) {
        Materialize.toast('Error : Please Input Collateral Only In Positive Integer Format', 3000);
      }
      else if((!checkExist($scope.form.price_per_day)) && (!checkExist($scope.form.price_per_month))) {
        Materialize.toast('Error : Please Input Price Per Day or Month / In Positive Integer Format', 4500);
      }
      else if((checkExist($scope.form.price_per_day)) && (parseInt($scope.form.price_per_day) != $scope.form.price_per_day)) {
        Materialize.toast('Error : Please Input Price Per Day Only / In Positive Integer Format', 4000);
      }
      else if((checkExist($scope.form.price_per_month)) && (parseInt($scope.form.price_per_month) != $scope.form.price_per_month)) {
        Materialize.toast('Error : Please Input Price Per Month Only / In Positive Integer Format', 4000);
      }
      else {
        if($scope.form.price_per_day === undefined) {
          $scope.form.price_per_day = null;
        }
        if($scope.form.price_per_month === undefined) {
          $scope.form.price_per_month = null;
        }
        ipcRenderer.send('add-motorcycle', $scope.form);
        $('#addMotorcycle').closeModal();
        $route.reload();
      }
    };
  })
  .controller('MotorcycleViewCtrl', function ($rootScope, $scope, $routeParams, $templateRequest, $compile, $route, $location) {
    $rootScope.menu = 'motorcycle';
    $scope.motorcycle = ipcRenderer.sendSync('get-motorcycle-view', $routeParams.id)[0];
    $scope.repairList = ipcRenderer.sendSync('get-motorcycle-repair', $scope.motorcycle.id);
    $scope.rentalList = ipcRenderer.sendSync('get-motorcycle-rental', $scope.motorcycle.id);
    var findBrand = function (brand) {
      var check = false;
      $scope.brands.forEach(function (brand_in_list) {
        if(brand_in_list.name === brand) {
          check = true;
        }
      });
      return check;
    };
    var checkExist = function (value) {
      if(value === null) {
        return false;
      }
      else if(value === '') {
        return false;
      }
      else if(value === undefined) {
        return false;
      }
      return true;
    };
    $scope.resetForm = function () {
      $scope.form = {
        id : $scope.motorcycle.id,
        brand : {id : $scope.motorcycle.brand_id, name : $scope.motorcycle.brand_name},
        brand_new : '',
        model : $scope.motorcycle.model,
        plate_number : $scope.motorcycle.plate_number,
        cost : $scope.motorcycle.cost,
        collateral: $scope.motorcycle.collateral,
        price_per_day : $scope.motorcycle.price_per_day,
        price_per_month : $scope.motorcycle.price_per_month
      };
    };
    $scope.editMotorcycle = function () {
      $templateRequest('templates/motorcycle-edit.html').then(function (template) {
        $compile($("#edit-box").html(template).contents())($scope);
        $scope.brands = ipcRenderer.sendSync('get-brand');
        $scope.brands.unshift({ id : 0, name : ' # Create New Brand' });
        $scope.resetForm();
        $('#editMotorcycle').openModal();
      });
    };
    $scope.deleteMotorcycle = function () {
      if(confirm("Are you sure to delete this mortocycle ?")) {
        var result = ipcRenderer.sendSync('delete-motorcycle', $scope.motorcycle.id);
        if(result) {
          $location.path('/motorcycle');
        }
      }
    };
    $scope.editForm = function () {
      if($scope.form.brand == '') {
        Materialize.toast('Error : Please Select Brand of Motorcycle', 3000);
      }
      else if(($scope.form.brand.id == 0) && ($scope.form.brand_new === '')) {
        Materialize.toast('Error : Please Input New Brand Name', 3000);
      }
      else if(findBrand($scope.form.brand_new)) {
        Materialize.toast('Error : New Brand Name has already in list', 3000);
      }
      else if($scope.form.model === '') {
        Materialize.toast('Error : Please Input Model of Motorcycle', 3000);
      }
      else if($scope.form.plate_number === '') {
        Materialize.toast('Error : Please Input Plate Number of Motorcycle', 3000);
      }
      else if(!checkExist($scope.form.cost)) {
        Materialize.toast('Error : Please Input Cost In Positive Integer Format', 3000);
      }
      else if(parseInt($scope.form.cost) != $scope.form.cost) {
        Materialize.toast('Error : Please Input Cost Only In Positive Integer Format', 3000);
      }
      else if(!checkExist($scope.form.collateral)) {
        Materialize.toast('Error : Please Input Collateral In Positive Integer Format', 3000);
      }
      else if(parseInt($scope.form.collateral) != $scope.form.collateral) {
        Materialize.toast('Error : Please Input Collateral Only In Positive Integer Format', 3000);
      }
      else if((!checkExist($scope.form.price_per_day)) && (!checkExist($scope.form.price_per_month))) {
        Materialize.toast('Error : Please Input Price Per Day or Month / In Positive Integer Format', 4500);
      }
      else if((checkExist($scope.form.price_per_day)) && (parseInt($scope.form.price_per_day) != $scope.form.price_per_day)) {
        Materialize.toast('Error : Please Input Price Per Day Only / In Positive Integer Format', 4000);
      }
      else if((checkExist($scope.form.price_per_month)) && (parseInt($scope.form.price_per_month) != $scope.form.price_per_month)) {
        Materialize.toast('Error : Please Input Price Per Month Only / In Positive Integer Format', 4000);
      }
      else {
        if($scope.form.price_per_day === undefined) {
          $scope.form.price_per_day = null;
        }
        if($scope.form.price_per_month === undefined) {
          $scope.form.price_per_month = null;
        }
        ipcRenderer.send('edit-motorcycle', $scope.form);
        $('#editMotorcycle').closeModal();
        $route.reload();
      }
    };
    $scope.showDate = function (date, check) {
      var monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      var date_return_expect = new Date(date);
      return date_return_expect.getDate() + ' ' + monthName[date_return_expect.getMonth()] + ' ' + date_return_expect.getFullYear();
    };
  })
  .controller('RepairCtrl', function ($rootScope, $scope, $routeParams, $route) {
    $rootScope.menu = 'motorcycle';
    $scope.repair = ipcRenderer.sendSync('get-repair-view', $routeParams.id)[0];
    $scope.form = {
      id : $scope.repair.id,
      problem : $scope.repair.problem,
      cause : $scope.repair.cause,
      cost : $scope.repair.cost
    };
    $scope.sendMotorcycle = function () {
      if(($scope.form.problem === '') || ($scope.form.problem === null)) {
        Materialize.toast('Error : Please Input Problem to Repair', 3000);
      }
      else {
        ipcRenderer.send('update-repair', $scope.form);
      }
    };
    $scope.receiveMotorcycle = function () {
      if(($scope.form.cost === '') || ($scope.form.cost === null)) {
        Materialize.toast('Error : Please Input Cost of Repair', 3000);
      }
      else if(parseInt($scope.form.cost) != $scope.form.cost) {
        Materialize.toast('Error : Please Input Cost Only In Integer Format', 3000);
      }
      else if(($scope.form.cause === '') || ($scope.form.cause === null)) {
        Materialize.toast('Error : Please Input Cause of Problem', 3000);
      }
      else {
        ipcRenderer.send('update-repair', $scope.form);
      }
    };
  })
  .controller('RentalAddSuccessCtrl', function ($rootScope, $scope, $routeParams) {
    $rootScope.menu = 'rental-success';
    $scope.amount = $routeParams.amount;
  })
  .controller('RentalReturnSuccessCtrl', function ($rootScope, $scope, $routeParams) {
    $rootScope.menu = 'rental-success';
    $scope.amount = $routeParams.amount < 0 ? $routeParams.amount * -1 : $routeParams.amount;
    if($routeParams.amount > 0) {
      $scope.message = 'You have to refund customer money';
    }
    else if($routeParams.amount < 0) {
      $scope.message = 'You have to gain addition cost from customer';
    }
    else {
      $scope.message = null;
    }
  })
;
