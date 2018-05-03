var app = angular.module('haiku', []);

app.factory('haikus', [ function() {
  var o = {
    entries: [
      { first: 'An old silent pond...', second: 'A frog jumps into the pond,', third: 'splash! Silence again.' }
    ]
  };
  return o;
}]);

app.controller('MainCtrl', [
  '$scope',
  '$http',
  '$interval',
  'haikus',
  function($scope, $http, $interval, haikus) {
    $scope.haikus = haikus.entries;
    var librarian = $interval(function() {
      $http.get('/haikus').then(function(response) {
        console.log(response.data);
        $scope.haikus = [{ first: response.data.first,
                          second: response.data.second,
                           third: response.data.third }];
      });

    }, 5000);

    $scope.addHaiku  = function() {
      if(!$scope.first || $scope.first === '') { return; }
      if(!$scope.second || $scope.second === '') { return; }
      if(!$scope.third || $scope.third === '') { return; }

      var data = { first: $scope.first,
                   second: $scope.second,
                   third: $scope.third };

      $http.post('/haikus', data, function(response) {
        console.log('haiku posted');
      });

      $scope.first = '';
      $scope.firstSylCount = '0';
      $scope.second = '';
      $scope.secondSylCount = '0';
      $scope.third = '';
      $scope.thirdSylCount = '0';
    };

    $scope.countFirstLine = function() {
      var data = { words: $scope.first };
      $http.post('/syllables/count', data).then(function(response) {
        $scope.firstSylCount = response.data.count;
      }, function(response) {
        // error callback
      });
    };
    $scope.countSecondLine = function() {
      var data = { words: $scope.second };
      $http.post('/syllables/count', data).then(function(response) {
        $scope.secondSylCount = response.data.count;
      }, function(response) {
        // error callback
      });
    };
    $scope.countThirdLine = function() {
      var data = { words: $scope.third };
      $http.post('/syllables/count', data).then(function(response) {
        $scope.thirdSylCount = response.data.count;
      }, function(response) {
        // error callback
      });
    };

  }
]);
