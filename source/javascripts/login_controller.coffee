---
---

class LoginController
  constructor: ->
    @loadLoginView()

  loadLoginView: ->
    host = "backend.photo-site.dev"
    path = "//#{host}/login"
    $.get path, (form) =>
      $(".login-view").append form

new LoginController()
