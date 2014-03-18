issuesBg = angular.module 'issuesBg', ['ngResource', 'ngRoute'], ($httpProvider) ->

    username = localStorage['username']
    token = localStorage['access_token']
    $httpProvider.defaults.headers.common['Authorization'] = 'Basic ' + window.btoa(username + ':' + token)

issuesBg.controller 'BackgroundCtrl', ($scope, $resource) ->

  userOrgs = $resource("https://api.github.com/users/:userId/orgs", {
    userId: localStorage['username']
  })

  orgs = userOrgs.query()

  chrome.tabs.onUpdated.addListener (tabId, changeInfo) ->
    if angular.isDefined(changeInfo.url)

      firstSection = changeInfo.url.replace('http://', '').split('.')[0]
      queryString = "user:" + localStorage['username'] + ' '

      for org in orgs
        queryString += "user:" + org.login + " "

      queryString = queryString + firstSection

      searchResource = $resource("https://api.github.com/search/repositories", {
        q: queryString
      })

      searchResource.get().$promise.then (results) ->
        console.log results
        if results.items.length <= 4 and results.items.length != 0
          localStorage['repo_full_name'] = results.items[0].full_name
          localStorage['repo_endpoint'] = results.items[0].url

angular.element(document).ready ->
  angular.bootstrap document, ['issuesBg']
