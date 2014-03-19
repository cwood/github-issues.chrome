issuesBg = angular.module 'issuesBg', ['ngResource', 'ngRoute'], ($httpProvider) ->

    username = localStorage['username']
    token = localStorage['access_token']
    $httpProvider.defaults.headers.common['Authorization'] = 'Basic ' + window.btoa(username + ':' + token)

issuesBg.controller 'BackgroundCtrl', ($scope, $resource) ->

  userOrgs = $resource("https://api.github.com/users/:userId/orgs", {
    userId: localStorage['username']
  })

  orgs = userOrgs.query()

  updateRepo = (url) ->
    urlParts = url.replace('http://', '').replace('www.', '').trim().split('.')
    queryString = "user:" + localStorage['username'] + ' '
    firstSection = urlParts[0]

    for org in orgs
      queryString += "user:" + org.login + " "

    queryString = queryString + firstSection

    searchResource = $resource("https://api.github.com/search/repositories", {
      q: queryString
    })

    searchResource.get().$promise.then (results) ->
      if results.items.length <= 4 and results.items.length != 0
        localStorage['repo_full_name'] = results.items[0].full_name
        localStorage['repo_endpoint'] = results.items[0].url

        issuesList = $resource(localStorage['repo_endpoint'] + '/issues')

        issuesList.query().$promise.then (issues) ->
          chrome.browserAction.setBadgeText
            text: issues.length.toString()


  chrome.tabs.onActivated.addListener (activeInfo) ->
    chrome.tabs.get activeInfo.tabId, (tabInfo) ->
      if angular.isDefined(tabInfo.url)
        updateRepo(tabInfo.url)

  chrome.tabs.onUpdated.addListener (tabId, changeInfo) ->
    if angular.isDefined(changeInfo.url)
      updateRepo(changeInfo.url)


angular.element(document).ready ->
  angular.bootstrap document, ['issuesBg']
