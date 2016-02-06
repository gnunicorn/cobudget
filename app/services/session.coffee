null

### @ngInject ###
global.cobudgetApp.factory 'Session', ($auth, CurrentUser, Dialog, LoadBar, $location, $q, Records) ->
  new class Session
    create: (formData, options = {}) ->
      promise = $auth.submitLogin(formData)
      promise.then (user) ->
        global.cobudgetApp.currentUserId = user.id
        membershipsLoadedDeferred = $q.defer()
        global.cobudgetApp.membershipsLoaded = membershipsLoadedDeferred.promise
        Records.users.updateProfile(utc_offset: moment().utcOffset())
        Records.memberships.fetchMyMemberships().then (data) ->
          membershipsLoadedDeferred.resolve(data)
          Records.users.fetchMe().then =>
            LoadBar.stop()
            if options.redirectTo and CurrentUser().hasMemberships()
              switch options.redirectTo
                when 'group'
                  $location.path("/groups/#{CurrentUser().primaryGroup().id}")
                when 'group setup'
                  $location.path("/setup_group")
            else
              @clear().then ->
                $location.path('/')
                Dialog.alert(title: 'error!', content: 'you have no active memberships')
      promise.catch ->
        LoadBar.stop()
      promise

    clear: ->
      deferred = $q.defer()
      if CurrentUser()
        $auth.signOut().then ->
          global.cobudgetApp.currentUserId = null
          deferred.resolve()
      else
        deferred.resolve()
      deferred.promise
