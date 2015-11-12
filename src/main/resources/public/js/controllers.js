var phoneApp = angular.module('phoneApp', []);
 

/*phoneApp.controller('PhoneListCtrl', function ($scope,$http) {*/

phoneApp.controller('PhoneListCtrl', ['$scope', '$http',
  function ($scope, $http) {
        $scope.phones = [
            {'name': 'Nexus S',
            'snippet': 'Fast just got faster with Nexus S.',
            'age': 21},
            {'name': 'Motorola XOOM with Wi-Fi',
            'snippet': 'The Next, Next Generation tablet.',
            'age': 7},
            {'name': 'MOTOROLA XOOM',
            'snippet': 'The Next, Next Generation tablet.',
            'age': 9}
        ];
        /*
        $http.get('phones/phones.json').success(function(data) {
            $scope.phones = data;
        });
        */
        $scope.orderProp = 'age';
}]);

