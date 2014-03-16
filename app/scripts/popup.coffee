issuesApp = angular.module 'issuesApp', ['ngAnimate', 'ngSanitize', 'ngRoute', 'ngResource'], (
    $routeProvider, $locationProvider, $httpProvider, $compileProvider
  ) ->

    $routeProvider.when '/popup.html',
      controller: "IssuesListCtrl"
      templateUrl: '/partials/list.html'
    $routeProvider.when '/popup.html/:issueId/',
      controller: "IssueDetailCtrl"
      templateUrl: "/partials/detail.html"

    $locationProvider.html5Mode(true)
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|chrome-extension):/)
    $httpProvider.defaults.headers.common['Authorization'] = 'Basic ' + window.btoa(username + token)

issuesApp.run ($rootScope) ->

  chrome.tabs.query
    active: true
  , (tabs) ->

    url = angular.element('<a />')
    url.attr('href', tabs[0].url)
    $rootScope.domain = url[0].host

issuesApp.controller 'IssuesListCtrl', ($scope, $rootScope, $resource, $routeParams, $animate, $location) ->

  Issues = $resource("https://api.github.com/repos/hzdg/rainbowroom.com/issues")
  $scope.issues = Issues.query()

  chrome.browserAction.setBadgeText
    text: $scope.issues.length.toString()

issuesApp.controller 'IssueDetailCtrl', ($scope, $resource, $routeParams, $animate) ->

  States =
    open: 'open'
    closed: 'closed'

  issue = $resource("https://api.github.com/repos/hzdg/rainbowroom.com/issues/:issueId",
    {issueId: $routeParams.issueId})
  $scope.issue = issue.get()

  $scope.toggleOpen = (issue) ->
    issue = $resource("https://api.github.com/repos/hzdg/rainbowroom.com/issues/:issueId",
      {issueId: $routeParams.issueId})
    currenIssue = issue.get()
    issue.patch
      state: State.closed if currentIssue.state is States.open else State.open

  comments = $resource("https://api.github.com/repos/hzdg/rainbowroom.com/issues/:issueId/comments",
    {issueId: $routeParams.issueId})
  $scope.posts = comments.query()

  $scope.toHtml = (markdown) ->
    markdown.toHtml(markdown)

issuesApp.directive 'markdown', ($sanitize) ->
  restrict: 'E'
  link: (scope, element) ->
    converter = new Showdown.converter
      extensions: ['github']
    html = $sanitize(converter.makeHtml(scope.issue))
    element.html(html)

angular.element(document).ready ->
	angular.bootstrap document, ['issuesApp']
