module Main = Layout_Main
module Title = Component_Title
module AlertMessage = Component_AlertMessage

open Component_Form
open Component_Button

module ErrorMessage = {
  @react.component
  let make = (~error) => {
    switch error {
    | Some(error) => <AlertMessage type_=#Error> {React.string(error)} </AlertMessage>
    | None => React.null
    }
  }
}

@react.component
let make = (
  ~reCaptchaSiteKey,
  ~email,
  ~emailError,
  ~password,
  ~passwordError,
  ~reCaptchaError,
  ~isSubmitting,
  ~signupError,
  ~signupAttemptCount,
  ~onEmailChange,
  ~onPasswordChange,
  ~onReCaptchaChange,
  ~onSignupClick,
) => {
  <Layout_Main user={None}>
    <FormContainer>
      <Title text="Sign Up" size=#Primary />
      <ErrorMessage error={signupError} />
      <TextField label="Email" value={email} onChange={onEmailChange} error={emailError} />
      <PasswordField
        label="Password"
        value={password}
        onChange={onPasswordChange}
        error={passwordError}
        showPasswordStrength=true
      />
      <ReCaptchaField
        key={"recaptcha-" ++ Belt.Int.toString(signupAttemptCount)}
        reCaptchaSiteKey={reCaptchaSiteKey}
        onChange={onReCaptchaChange}
        error={reCaptchaError}
      />
      <Button
        color=#Green full=true onClick=onSignupClick state={isSubmitting ? #Processing : #Ready}>
        {React.string("Sign Up")}
      </Button>
    </FormContainer>
  </Layout_Main>
}
