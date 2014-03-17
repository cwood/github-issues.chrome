issuesOptions = angular.module 'issuesOptions', []

issuesOptions.controller 'optionsCtrl', ($scope) ->

    $scope.user =
        username: localStorage['username'] ? ''
        access_token: localStorage['access_token'] ? ''

    $scope.saveToLocal = (user) ->
        localStorage['username'] = user.username
        localStorage['access_token'] = user.access_token

angular.element(document).ready ->
    angular.bootstrap document, ['issuesOptions']
