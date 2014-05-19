issuesApp = angular.module 'issues.controllers', ['ngAnimate', 'ngSanitize', 'ngResource']

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

issuesApp.controller 'IssueDetailCtrl', ($scope, $resource, $routeParams, $animate, $http) ->

  States =
    open: 'open'
    closed: 'closed'

  issue = $resource(localStorage['repo_endpoint'] + "/issues/:issue",
    {issue: $routeParams.issue})
  $scope.issue = issue.get()

  $scope.createTab = (url) ->
    chrome.tabs.create
      url: url

  $scope.toggleOpen = (issue) ->
    issue = $resource(localStorage['repo_endpoint'] + "/issues/:issue",
      {issue: $routeParams.issue})
    issue.get().$promise.then (currentIssue) ->

      updateIssue = $http
        url: localStorage['repo_endpoint'] + "/issues/" + $routeParams.issue
        method: 'PATCH'
        data:
          tite: currentIssue.title
          state: if currentIssue.state == States.open then States.closed else States.open

      updateIssue.then (issue) ->
        $scope.issue = issue.data

  comments = $resource(localStorage['repo_endpoint'] + "/issues/:issue/comments",
    {issue: $routeParams.issue})
  $scope.posts = comments.query()

  labels = $resource(localStorage['repo_endpoint'] + "/issues/:issue/labels",
    {issue: $routeParams.issueId})
  $scope.labels = labels.query()
