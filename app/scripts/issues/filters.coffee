issuesApp = angular.module 'issues.filters', ['ngSanitize']

issuesApp.filter 'markdown', ($sanitize) ->
  (input) ->
    if input
      converter = new Showdown.converter
        extensions: ['github']
      converter.makeHtml((input))
    else
      ''
