issuesApp = angular.module 'issuesApp', ['ngAnimate', 'ngSanitize', 'ngRoute', 'ngResource'], (
    $routeProvider, $locationProvider, $httpProvider, $compileProvider
  ) ->

    $routeProvider.when '/popup.html',
      controller: "IssuesListCtrl"
      templateUrl: '/partials/list.html'
    $routeProvider.when '/popup.html/closed',
      controller: "ClosedIssuesListCtrl"
      templateUrl: '/partials/list.html'
    $routeProvider.when '/popup.html/:issueId/',
      controller: "IssueDetailCtrl"
      templateUrl: "/partials/detail.html"

    username = localStorage['username']
    token = localStorage['access_token']

    $locationProvider.html5Mode(true)
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|chrome-extension):/)
    $httpProvider.defaults.headers.common['Authorization'] = 'Basic ' + window.btoa(username + ':' + token)

issuesApp.run ($rootScope, $location) ->
    $rootScope.domain = localStorage['repo_full_name']

    $rootScope.activeLink = (path) ->
      return path == $location.path()

issuesApp.controller 'ClosedIssuesListCtrl', ($scope, $resource, $animate) ->

  closedIssues = $resource(localStorage['repo_endpoint'] + "/issues", {
      state: "closed"
  })
  $scope.issues = closedIssues.query()

issuesApp.controller 'IssuesListCtrl', ($scope, $rootScope, $resource, $routeParams, $animate, $location) ->

  Issues = $resource(localStorage['repo_endpoint'] + "/issues", {
    state: 'open'
  })
  $scope.issues = Issues.query()

  $scope.issues.$promise.then (issues) ->
    chrome.browserAction.setBadgeText
      text: issues.length.toString()

issuesApp.filter 'markdown', ($sanitize) ->
  (input) ->
    converter = new Showdown.converter
      extensions: ['github']
    return converter.makeHtml((input))

issuesApp.controller 'IssueDetailCtrl', ($scope, $resource, $routeParams, $animate, $http) ->

  States =
    open: 'open'
    closed: 'closed'

  issue = $resource(localStorage['repo_endpoint'] + "/issues/:issueId",
    {issueId: $routeParams.issueId})
  $scope.issue = issue.get()

  $scope.createTab = (url) ->
    chrome.tabs.create
      url: url

  $scope.toggleOpen = (issue) ->
    issue = $resource(localStorage['repo_endpoint'] + "/issues/:issueId",
      {issueId: $routeParams.issueId})
    issue.get().$promise.then (currentIssue) ->

      updateIssue = $http
        url: localStorage['repo_endpoint'] + "/issues/" + $routeParams.issueId
        method: 'PATCH'
        data:
          tite: currentIssue.title
          state: if currentIssue.state == States.open then States.closed else States.open

      updateIssue.then (issue) ->
        $scope.issue = issue.data

  comments = $resource(localStorage['repo_endpoint'] + "/issues/:issueId/comments",
    {issueId: $routeParams.issueId})
  $scope.posts = comments.query()

  labels = $resource(localStorage['repo_endpoint'] + "/issues/:issueId/labels",
    {issueId: $routeParams.issueId})
  $scope.labels = labels.query()

angular.element(document).ready ->
	angular.bootstrap document, ['issuesApp']
