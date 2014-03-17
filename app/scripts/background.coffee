issuesBg = angular.module 'issuesBg', ['ngResource', 'ngRoute']

issuesBg.controller 'BackgroundCtrl', ($scope, $resource) ->
  console.log "Starting controller"
  chrome.tabs.onUpdate.addListener (changeInfo, tab) ->
    console.log changeInfo

angular.element(document).ready ->
  angular.bootstrap document, ['issuesBg']
  angular.element(document).find('body').attr('ng-controller', 'BackgroundCtrl')
  angular.element(document).scope().$apply()
