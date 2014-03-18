issuesApp = angular.module 'issuesApp', ['ngAnimate', 'ngSanitize', 'ngRoute', 'ngResource'], (
    $routeProvider, $locationProvider, $httpProvider, $compileProvider
  ) ->

    $routeProvider.when '/popup.html',
      controller: "IssuesListCtrl"
      templateUrl: '/partials/list.html'
    $routeProvider.when '/popup.html/:issueId/',
      controller: "IssueDetailCtrl"
      templateUrl: "/partials/detail.html"

    username = localStorage['username']
    token = localStorage['access_token']

    $locationProvider.html5Mode(true)
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|chrome-extension):/)
    $httpProvider.defaults.headers.common['Authorization'] = 'Basic ' + window.btoa(username + ':' + token)

issuesApp.run ($rootScope) ->

  chrome.tabs.query
    active: true
  , (tabs) ->

    url = angular.element('<a />')
    url.attr('href', tabs[0].url)
    $rootScope.domain = localStorage['repo_full_name']

issuesApp.controller 'IssuesListCtrl', ($scope, $rootScope, $resource, $routeParams, $animate, $location) ->

  Issues = $resource(localStorage['repo_endpoint'] + "/issues")
  $scope.issues = Issues.query()

  $scope.issues.$promise.then (issues) ->
    console.log issues
    chrome.browserAction.setBadgeText
      text: issues.length

issuesApp.filter 'markdown', ($sanitize) ->
  (input) ->
    converter = new Showdown.converter
      extensions: ['github']
    return converter.makeHtml((input))

issuesApp.controller 'IssueDetailCtrl', ($scope, $resource, $routeParams, $animate) ->

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
    currentIssue = issue.get()
    issue.patch
      state: States.closed if currentIssue.state == States.open else States.open

  comments = $resource(localStorage['repo_endpoint'] + "/issues/:issueId/comments",
    {issueId: $routeParams.issueId})
  $scope.posts = comments.query()

angular.element(document).ready ->
	angular.bootstrap document, ['issuesApp']
