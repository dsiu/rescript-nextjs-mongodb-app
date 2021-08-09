module User = {
  type t = {
    id: string,
    email: string,
    emailChange: option<string>,
  }

  type dto = {
    id: string,
    email: string,
    emailChange: Js.Null.t<string>,
  }

  let toDto = (user: t): dto => {
    {
      id: user.id,
      email: user.email,
      emailChange: Js.Null.fromOption(user.emailChange),
    }
  }

  let fromDto = (dto: dto): t => {
    {
      id: dto.id,
      email: dto.email,
      emailChange: Js.Null.toOption(dto.emailChange),
    }
  }

  let fromNullDto = (dto: Js.Null.t<dto>): option<t> => {
    Js.Null.toOption(dto)->Belt.Option.map(fromDto)
  }
}

module Signup = {
  type signup = {
    email: string,
    password: string,
    reCaptcha: option<string>,
  }

  type signupError = [#RequestFailed]
  type emailError = [#EmailEmpty | #EmailInvalid | #EmailNotAvailable]
  type passwordError = [#PasswordEmpty]
  type reCaptchaError = [#ReCaptchaEmpty | #ReCaptchaInvalid]

  type errors = {
    signup: option<signupError>,
    email: option<emailError>,
    password: option<passwordError>,
    reCaptcha: option<reCaptchaError>,
  }

  type signupResult = {errors: errors}

  external asSignupResult: Js.Json.t => signupResult = "%identity"

  let emptyErrors = (): errors => {
    signup: None,
    email: None,
    password: None,
    reCaptcha: None,
  }

  let hasErrors = (errors: errors): bool => {
    Belt.Option.isSome(errors.signup) ||
    Belt.Option.isSome(errors.email) ||
    Belt.Option.isSome(errors.password) ||
    Belt.Option.isSome(errors.reCaptcha)
  }

  let validateEmail = (email): option<emailError> => {
    let emailTrimmed = String.trim(email)
    if Validator.isEmpty(emailTrimmed) {
      Some(#EmailEmpty)
    } else if !Validator.isEmail(emailTrimmed) {
      Some(#EmailInvalid)
    } else {
      None
    }
  }

  let validatePassword = (password): option<passwordError> => {
    if Validator.isEmpty(password) {
      Some(#PasswordEmpty)
    } else {
      None
    }
  }

  let validateReCaptcha = (reCaptcha): option<reCaptchaError> => {
    switch reCaptcha {
    | Some(_) => None
    | None => Some(#ReCaptchaEmpty)
    }
  }

  let validateSignup = ({email, password, reCaptcha}: signup): errors => {
    signup: None,
    email: validateEmail(email),
    password: validatePassword(password),
    reCaptcha: validateReCaptcha(reCaptcha),
  }

  let signupErrorToString = (error: signupError): string => {
    switch error {
    | #RequestFailed => "There was a problem signing up, please try again"
    }
  }

  let emailErrorToString = (error: emailError): string => {
    switch error {
    | #EmailEmpty => "Enter an email address"
    | #EmailInvalid => "Enter a valid email address"
    | #EmailNotAvailable => "That email address is not available"
    }
  }

  let passwordErrorToString = (error: passwordError): string => {
    switch error {
    | #PasswordEmpty => "Enter a password"
    }
  }

  let reCaptchaErrorToString = (error: reCaptchaError): string => {
    switch error {
    | #ReCaptchaEmpty => "Are you sure you're a robot?"
    | #ReCaptchaInvalid => "Are you sure you're a robot?"
    }
  }
}

module ResendActivation = {
  type resendActivation = {email: string}

  type resendActivationError = [
    | #EmailEmpty
    | #EmailInvalid
    | #RequestFailed
    | #AlreadyActivated
    | #UserNotFound
  ]

  type errors = {resendActivation: option<resendActivationError>}

  type resendActivationResult = {errors: errors}

  external asResendActivationResult: Js.Json.t => resendActivationResult = "%identity"

  let emptyErrors = (): errors => {
    resendActivation: None,
  }

  let hasErrors = (errors: errors): bool => {
    Belt.Option.isSome(errors.resendActivation)
  }

  let validateEmail = (email): option<resendActivationError> => {
    let emailTrimmed = String.trim(email)
    if Validator.isEmpty(emailTrimmed) {
      Some(#EmailEmpty)
    } else if !Validator.isEmail(emailTrimmed) {
      Some(#EmailInvalid)
    } else {
      None
    }
  }

  let validateResendActivation = ({email}: resendActivation): errors => {
    resendActivation: validateEmail(email),
  }

  let resendError = message => {
    "There was a problem resending the activation email. " ++ message
  }

  let resendActivationErrorToString = (error: resendActivationError): string => {
    switch error {
    | #RequestFailed => resendError("Please try again.")
    | #EmailEmpty => resendError("Check the email below is a valid email address.")
    | #EmailInvalid => resendError("Check the email below is a valid email address.")
    | #AlreadyActivated => resendError("Your account has already been activated.")
    | #UserNotFound => resendError("That email address was not found.")
    }
  }

  let errorsToString = (errors: errors) => {
    switch errors.resendActivation {
    | Some(error) => resendActivationErrorToString(error)
    | None => "An unknown error occurred. Please contact us for support."
    }
  }
}

module Login = {
  type login = {
    email: string,
    password: string,
  }

  type loginError = [#RequestFailed | #LoginFailed | #AccountNotActivated]
  type emailError = [#EmailEmpty | #EmailInvalid]
  type passwordError = [#PasswordEmpty]

  type errors = {
    login: option<loginError>,
    email: option<emailError>,
    password: option<passwordError>,
  }

  type loginResult = {
    errors: errors,
    nextUrl: option<string>,
  }

  let hasErrors = (errors: errors): bool => {
    Belt.Option.isSome(errors.login) ||
    Belt.Option.isSome(errors.email) ||
    Belt.Option.isSome(errors.password)
  }

  let emptyErrors = (): errors => {
    login: None,
    email: None,
    password: None,
  }

  external asLoginResult: Js.Json.t => loginResult = "%identity"

  let validateEmail = (email): option<emailError> => {
    let emailTrimmed = String.trim(email)
    if Validator.isEmpty(emailTrimmed) {
      Some(#EmailEmpty)
    } else if !Validator.isEmail(emailTrimmed) {
      Some(#EmailInvalid)
    } else {
      None
    }
  }

  let validatePassword = (password): option<passwordError> => {
    if Validator.isEmpty(password) {
      Some(#PasswordEmpty)
    } else {
      None
    }
  }

  let validateLogin = ({email, password}: login): errors => {
    login: None,
    email: validateEmail(email),
    password: validatePassword(password),
  }

  let emailErrorToString = (error: emailError): string => {
    switch error {
    | #EmailEmpty => "Enter your email address"
    | #EmailInvalid => "Enter a valid email address"
    }
  }

  let passwordErrorToString = (error: passwordError): string => {
    switch error {
    | #PasswordEmpty => "Enter a password"
    }
  }
}

module Logout = {
  type logoutResult = {result: [#Ok]}
}

module ChangeEmail = {
  type changeEmail = {email: string}

  type changeEmailError = [
    | #RequestFailed
    | #UserNotFound
    | #AccountNotActivated
    | #SameAsCurrentEmail
    | #EmailNotAvailable
  ]

  type emailError = [#EmailEmpty | #EmailInvalid]

  type changeEmailErrors = {
    changeEmail: option<changeEmailError>,
    email: option<emailError>,
  }

  type changeEmailResult = {errors: changeEmailErrors}

  external asChangeEmailResult: Js.Json.t => changeEmailResult = "%identity"

  let hasErrors = (errors: changeEmailErrors): bool => {
    Belt.Option.isSome(errors.changeEmail) || Belt.Option.isSome(errors.email)
  }

  let validateEmail = (email): option<emailError> => {
    let emailTrimmed = String.trim(email)
    if Validator.isEmpty(emailTrimmed) {
      Some(#EmailEmpty)
    } else if !Validator.isEmail(emailTrimmed) {
      Some(#EmailInvalid)
    } else {
      None
    }
  }

  let validateChangeEmail = ({email}: changeEmail): changeEmailErrors => {
    changeEmail: None,
    email: validateEmail(email),
  }

  let generalError = "An error occurred when trying to change your email. Please try again."

  let changeEmailErrorToString = (error: changeEmailError): string => {
    switch error {
    | #RequestFailed => generalError
    | #UserNotFound => generalError
    | #AccountNotActivated => generalError
    | #SameAsCurrentEmail => "The email address you provided is the same as your current email address."
    | #EmailNotAvailable => "That email address is not available."
    }
  }

  let emailErrorToString = (error: emailError): string => {
    switch error {
    | #EmailEmpty => "Enter an email address"
    | #EmailInvalid => "Enter a valid email address"
    }
  }
}

module ChangePassword = {
  type changePassword = {
    currentPassword: string,
    newPassword: string,
    newPasswordConfirm: string,
  }

  type changePasswordError = [
    | #RequestFailed
    | #UserNotFound
    | #AccountNotActivated
    | #CurrentPasswordInvalid
  ]
  type currentPasswordError = [#CurrentPasswordEmpty]
  type newPasswordError = [#NewPasswordEmpty]
  type newPasswordConfirmError = [#NewPasswordConfirmEmpty | #NewPasswordConfirmMismatch]

  type errors = {
    changePassword: option<changePasswordError>,
    currentPassword: option<currentPasswordError>,
    newPassword: option<newPasswordError>,
    newPasswordConfirm: option<newPasswordConfirmError>,
  }

  type changePasswordResult = {errors: errors}

  external asChangePasswordResult: Js.Json.t => changePasswordResult = "%identity"

  let emptyErrors = (): errors => {
    changePassword: None,
    currentPassword: None,
    newPassword: None,
    newPasswordConfirm: None,
  }

  let hasErrors = (errors: errors): bool => {
    Belt.Option.isSome(errors.changePassword) ||
    Belt.Option.isSome(errors.currentPassword) ||
    Belt.Option.isSome(errors.newPassword) ||
    Belt.Option.isSome(errors.newPasswordConfirm)
  }

  let validateCurrentPassword = (currentPassword): option<currentPasswordError> => {
    if Validator.isEmpty(currentPassword) {
      Some(#CurrentPasswordEmpty)
    } else {
      None
    }
  }

  let validateNewPassword = (newPassword): option<newPasswordError> => {
    if Validator.isEmpty(newPassword) {
      Some(#NewPasswordEmpty)
    } else {
      None
    }
  }

  let validateNewPasswordConfirm = (newPassword, newPasswordConfirm): option<
    newPasswordConfirmError,
  > => {
    if Validator.isEmpty(newPasswordConfirm) {
      Some(#NewPasswordConfirmEmpty)
    } else if newPassword != newPasswordConfirm {
      Some(#NewPasswordConfirmMismatch)
    } else {
      None
    }
  }

  let validateChangePassword = (
    {currentPassword, newPassword, newPasswordConfirm}: changePassword,
  ): errors => {
    changePassword: None,
    currentPassword: validateCurrentPassword(currentPassword),
    newPassword: validateNewPassword(newPassword),
    newPasswordConfirm: validateNewPasswordConfirm(newPassword, newPasswordConfirm),
  }

  let changePasswordErrorToString = (error: changePasswordError): string => {
    switch error {
    | #RequestFailed => "An error occurred when trying to change your password. Please try again."
    | #UserNotFound => "An error occurred when trying to change your password. The account was not found. Please contact us for support."
    | #AccountNotActivated => "An error occurred when trying to change your password. The account is not activated. Please contact us for support."
    | #CurrentPasswordInvalid => "The current password you entered is not correct. Please try again."
    }
  }

  let currentPasswordErrorToString = (error: currentPasswordError): string => {
    switch error {
    | #CurrentPasswordEmpty => "Enter your current password"
    }
  }

  let newPasswordErrorToString = (error: newPasswordError): string => {
    switch error {
    | #NewPasswordEmpty => "Enter your new password"
    }
  }

  let newPasswordConfirmErrorToString = (error: newPasswordConfirmError): string => {
    switch error {
    | #NewPasswordConfirmEmpty => "Re-enter your new password"
    | #NewPasswordConfirmMismatch => "This does not match the password above"
    }
  }
}

module ForgotPassword = {
  type forgotPassword = {
    email: string,
    reCaptcha: option<string>,
  }

  type forgotPasswordError = [
    | #RequestFailed
    | #AccountNotActivated
    | #EmailNotFound
  ]

  type emailError = [#EmailEmpty | #EmailInvalid]

  type reCaptchaError = [#ReCaptchaEmpty | #ReCaptchaInvalid]

  type errors = {
    forgotPassword: option<forgotPasswordError>,
    email: option<emailError>,
    reCaptcha: option<reCaptchaError>,
  }

  type forgotPasswordResult = {errors: errors}

  external asForgotPasswordResult: Js.Json.t => forgotPasswordResult = "%identity"

  let emptyErrors = (): errors => {
    forgotPassword: None,
    email: None,
    reCaptcha: None,
  }

  let hasErrors = (errors: errors): bool => {
    Belt.Option.isSome(errors.forgotPassword) ||
    Belt.Option.isSome(errors.email) ||
    Belt.Option.isSome(errors.reCaptcha)
  }

  let validateEmail = (email): option<emailError> => {
    let emailTrimmed = String.trim(email)
    if Validator.isEmpty(emailTrimmed) {
      Some(#EmailEmpty)
    } else if !Validator.isEmail(emailTrimmed) {
      Some(#EmailInvalid)
    } else {
      None
    }
  }

  let validateReCaptcha = (reCaptcha): option<reCaptchaError> => {
    switch reCaptcha {
    | Some(_) => None
    | None => Some(#ReCaptchaEmpty)
    }
  }

  let validateForgotPassword = (forgotPassword: forgotPassword): errors => {
    forgotPassword: None,
    email: validateEmail(forgotPassword.email),
    reCaptcha: validateReCaptcha(forgotPassword.reCaptcha),
  }

  let forgotPasswordErrorToString = (error: forgotPasswordError): string => {
    switch error {
    | #RequestFailed => "There was a problem processing your forgot password request. Please try again."
    | #EmailNotFound => "No account was found with that email address. Please try again."
    | #AccountNotActivated => "That account has not been activated. Please contact us for support."
    }
  }

  let emailErrorToString = (error: emailError): string => {
    switch error {
    | #EmailEmpty => "Enter an email address"
    | #EmailInvalid => "Enter a valid email address"
    }
  }

  let reCaptchaErrorToString = (error: reCaptchaError): string => {
    switch error {
    | #ReCaptchaEmpty => "Are you sure you're a robot?"
    | #ReCaptchaInvalid => "Are you sure you're a robot?"
    }
  }
}

module ResetPassword = {
  type resetPassword = {
    userId: string,
    resetPasswordKey: string,
    password: string,
    passwordConfirm: string,
    reCaptcha: option<string>,
  }

  type resetPasswordError = [
    | #RequestFailed
    | #ResetPasswordInvalid
    | #ResetPasswordExpired
    | #AccountNotActivated
  ]

  type passwordError = [#PasswordEmpty]

  type passwordConfirmError = [
    | #PasswordConfirmEmpty
    | #PasswordConfirmMismatch
  ]

  type reCaptchaError = [
    | #ReCaptchaEmpty
    | #ReCaptchaInvalid
  ]

  type errors = {
    resetPassword: option<resetPasswordError>,
    password: option<passwordError>,
    passwordConfirm: option<passwordConfirmError>,
    reCaptcha: option<reCaptchaError>,
  }

  type errorsDto = {
    resetPassword: Js.Null.t<resetPasswordError>,
    password: Js.Null.t<passwordError>,
    passwordConfirm: Js.Null.t<passwordConfirmError>,
    reCaptcha: Js.Null.t<reCaptchaError>,
  }

  type resetPasswordResult = {errors: errors}

  external asResetPasswordResult: Js.Json.t => resetPasswordResult = "%identity"

  let emptyErrors = (): errors => {
    resetPassword: None,
    password: None,
    passwordConfirm: None,
    reCaptcha: None,
  }

  let resetPasswordErrorsToDto = (errors: errors): errorsDto => {
    resetPassword: Js.Null.fromOption(errors.resetPassword),
    password: Js.Null.fromOption(errors.password),
    passwordConfirm: Js.Null.fromOption(errors.passwordConfirm),
    reCaptcha: Js.Null.fromOption(errors.reCaptcha),
  }

  let dtoToResetPasswordErrors = (errors: errorsDto): errors => {
    resetPassword: Js.Null.toOption(errors.resetPassword),
    password: Js.Null.toOption(errors.password),
    passwordConfirm: Js.Null.toOption(errors.passwordConfirm),
    reCaptcha: Js.Null.toOption(errors.reCaptcha),
  }

  let refineResetPasswordKeyError = error => {
    switch error {
    | #ResetPasswordKeyInvalid => #ResetPasswordInvalid
    | #UserNotFound => #ResetPasswordInvalid
    | #AccountNotActivated => #AccountNotActivated
    | #ResetPasswordNotRequested => #ResetPasswordInvalid
    | #ResetPasswordExpired => #ResetPasswordExpired
    }
  }

  let hasErrors = (errors: errors): bool => {
    Belt.Option.isSome(errors.resetPassword) ||
    Belt.Option.isSome(errors.password) ||
    Belt.Option.isSome(errors.passwordConfirm) ||
    Belt.Option.isSome(errors.reCaptcha)
  }

  let validatePassword = (password): option<passwordError> => {
    if Validator.isEmpty(password) {
      Some(#PasswordEmpty)
    } else {
      None
    }
  }

  let validatePasswordConfirm = (password, passwordConfirm): option<passwordConfirmError> => {
    if Validator.isEmpty(passwordConfirm) {
      Some(#PasswordConfirmEmpty)
    } else if password != passwordConfirm {
      Some(#PasswordConfirmMismatch)
    } else {
      None
    }
  }

  let validateReCaptcha = (reCaptcha): option<reCaptchaError> => {
    switch reCaptcha {
    | Some(_) => None
    | None => Some(#ReCaptchaEmpty)
    }
  }

  let validateResetPassword = ({password, passwordConfirm, reCaptcha}: resetPassword): errors => {
    resetPassword: None,
    password: validatePassword(password),
    passwordConfirm: validatePasswordConfirm(password, passwordConfirm),
    reCaptcha: validateReCaptcha(reCaptcha),
  }

  let passwordErrorToString = (error: passwordError): string => {
    switch error {
    | #PasswordEmpty => "Enter your new password"
    }
  }

  let passwordConfirmErrorToString = (error: passwordConfirmError): string => {
    switch error {
    | #PasswordConfirmEmpty => "Re-enter your new password"
    | #PasswordConfirmMismatch => "This does not match the password above"
    }
  }

  let reCaptchaErrorToString = (error: reCaptchaError): string => {
    switch error {
    | #ReCaptchaEmpty => "Are you sure you're a robot?"
    | #ReCaptchaInvalid => "Are you sure you're a robot?"
    }
  }
}
