let makePayload = (contactResult): Common_Contact.contactResult => {
  let errors = switch contactResult {
  | Ok() => Common_Contact.emptyErrors()
  | Error(errors) => errors
  }
  {errors: errors}
}

let handlePost = (req: Next.Req.t, res: Next.Res.t) => {
  Server_Api.withBody(req, res, body => {
    let contact: Common_Contact.contact = body
    Server_Contact.contact(contact)->Promise.then(contactResult => {
      let payload = makePayload(contactResult)
      Server_Api.sendSuccess(res, payload)
      Promise.resolve()
    })
  })
}

let default =
  NextConnect.nc()
  ->NextConnect.useHandlerAsync(Server_Middleware.all())
  ->NextConnect.postAsync(handlePost)
