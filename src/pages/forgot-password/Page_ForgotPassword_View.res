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
  ~user,
  ~forgotPasswordError,
  ~email,
  ~isSubmitting,
  ~onEmailChange,
  ~onReCaptchaChange,
  ~onForgotPasswordClick,
  ~emailError,
  ~reCaptchaError,
  ~attemptCount,
) => {
  <Layout_Main user={user}>
    <FormContainer>
      <Title text="Forgot Password" size=#Primary />
      <ErrorMessage error={forgotPasswordError} />
      <EmailField
        label="Email address of your account"
        value={email}
        onChange={onEmailChange}
        error={emailError}
      />
      <ReCaptchaField
        key={"recaptcha-" ++ Belt.Int.toString(attemptCount)}
        reCaptchaSiteKey={reCaptchaSiteKey}
        onChange={onReCaptchaChange}
        error={reCaptchaError}
      />
      <div className="mb-6">
        <Button
          color=#Green
          full=true
          onClick=onForgotPasswordClick
          state={isSubmitting ? #Processing : #Ready}>
          {React.string("Forgot Password")}
        </Button>
      </div>
    </FormContainer>
  </Layout_Main>
}
