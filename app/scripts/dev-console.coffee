issuesApp = angular.module 'issuesApp', ['ngRoute', 'zj.namedRoutes', 'issues.controllers', 'issues.filters'], (
    $routeProvider, $locationProvider, $httpProvider, $compileProvider
  ) ->

    $routeProvider.when '/panes/dev-console.html',
      controller: "IssuesListCtrl"
      templateUrl: '/partials/list.html'
      name: 'root'
    $routeProvider.when '/panes/dev-console.html/closed',
      controller: "ClosedIssuesListCtrl"
      templateUrl: '/partials/list.html'
      name: 'closed'
    $routeProvider.when '/panes/dev-console.html/:issue/',
      controller: "IssueDetailCtrl"
      templateUrl: "/partials/detail.html"
      name: 'issue-detail'
    $routeProvider.otherwise '/panes/dev-console.html'

    username = localStorage['username']
    token = localStorage['access_token']

    $locationProvider.html5Mode(true)
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|chrome-extension):/)
    $httpProvider.defaults.headers.common['Authorization'] = 'Basic ' + window.btoa(username + ':' + token)

issuesApp.run ($rootScope, $location) ->
    $rootScope.domain = localStorage['repo_full_name']

    $rootScope.activeLink = (path) ->
      return path == $location.path()

angular.element(document).ready ->
	angular.bootstrap document, ['issuesApp']
