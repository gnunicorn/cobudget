module.exports =
  onEnter: (ValidateAndRedirectLoggedInUser) ->
    ValidateAndRedirectLoggedInUser()
  url: '/'
  template: require('./landing-page.html')
  controller: (Dialog, LoadBar, $location, Records, $scope, Session) ->

    $scope.startGroup = ->
      LoadBar.start()
      newUser = Records.users.build($scope.formData)
      newUser.save()
        .then (userData) ->
          Session.create(userData).then ->
            $location.path('/setup_group')
        .catch (err) ->
          $location.path('/login').search({setup_group: true, email: newUser.email})
        .finally ->
          LoadBar.stop()
    return
