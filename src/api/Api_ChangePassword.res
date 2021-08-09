let makePayload = (changePasswordResult): Common_User.ChangePassword.changePasswordResult => {
  let errors = switch changePasswordResult {
  | Ok() => Common_User.ChangePassword.emptyErrors()
  | Error(errors) => errors
  }
  {errors: errors}
}

let handlePost = (req: Next.Req.t, res: Next.Res.t) => {
  Server_Api.withBody(req, res, body => {
    Server_Api.withCurrentUser(req, res, currentUser => {
      let changePassword: Common_User.ChangePassword.changePassword = body
      let {client} = Server_Middleware.getRequestData(req)
      client
      ->Server_User.changePassword(currentUser._id, changePassword)
      ->Promise.then(changePasswordResult => {
        let payload = makePayload(changePasswordResult)
        Server_Api.sendSuccess(res, payload)
        Promise.resolve()
      })
    })
  })
}

let default =
  NextConnect.nc()
  ->NextConnect.useHandlerAsync(Server_Middleware.all())
  ->NextConnect.postAsync(handlePost)
