open Page_ChangeEmailConfirm_Types

let makeResult = (userDto, emailChangeSuccessful): Next.GetServerSideProps.result<props> => {
  let props: props = {
    userDto: userDto,
    emailChangeSuccessful: emailChangeSuccessful,
  }
  Server_Page.props(props)
}

let getServerSideProps: Next.GetServerSideProps.t<props, params, _> = context => {
  let {req, res, params} = context
  let {userId, emailChangeKey} = params
  Server_Middleware.runAll(req, res)->Promise.then(_ => {
    let {client, currentUser} = Server_Middleware.getRequestData(req)
    let currentUserDto = Server_User.toNullCommonUserDto(currentUser)
    client
    ->Server_User.changeEmailConfirm(userId, emailChangeKey)
    ->Promise.thenResolve(result => {
      switch result {
      | Error(_) => makeResult(Js.Null.empty, false)
      | Ok() => makeResult(currentUserDto, true)
      }
    })
  })
}
