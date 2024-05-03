dynamic apiContainer "LAPNavigationIntegration" "X5 to LAP navigation integration" {
    title "X5 to LAP navigation integration"
    description "The redirection that uses SSO mechanism, so LAP does not prompt a user for credentials once it's authorized at X5"
    frontendContainer -> lapRedirectionControllerComponent "Redirection after CLICK on LAP url"
    lapRedirectionControllerComponent -> lapJwtControllerComponent "Acquire token for a given user ID"
    lapJwtControllerComponent -> lapRedirectionControllerComponent "Return bearer token with the user ID included"
    lapRedirectionControllerComponent -> liveAssetsSystem "Redirection with the acquired bearer token (ideally in the http headers but eventually can be in an url query parameters)"
}