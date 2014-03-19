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
      for result in results.items
        console.log result.name
        if result.name.match(/\.\w+$/)
          console.log result.name
          localStorage['repo_full_name'] = result.full_name
          localStorage['repo_endpoint'] = result.url

          issuesList = $resource(localStorage['repo_endpoint'] + '/issues')

          issuesList.query().$promise.then (issues) ->
            chrome.browserAction.setBadgeText
              text: issues.length.toString()
          break


  chrome.tabs.onActivated.addListener (activeInfo) ->
    chrome.tabs.get activeInfo.tabId, (tabInfo) ->
      if angular.isDefined(tabInfo.url)
        updateRepo(tabInfo.url)

  chrome.tabs.onUpdated.addListener (tabId, changeInfo) ->
    if angular.isDefined(changeInfo.url)
      updateRepo(changeInfo.url)


angular.element(document).ready ->
  angular.bootstrap document, ['issuesBg']
