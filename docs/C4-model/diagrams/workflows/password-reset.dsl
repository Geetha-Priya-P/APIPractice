dynamic apiContainer "PasswordResetRequest" "Password Reset Workflow" {
    webapp -> nginxContainer "Password Reset Request"
    nginxContainer -> passwordChangeControllerComponent "Forward: Password Reset Request"                   
    passwordChangeControllerComponent -> sqlContainer "Get User"            
    passwordChangeControllerComponent -> rabbitContainer "Publish: Tenant Password Reset Request Event to Queue X5.Admin.Messages.TenantPasswordResetRequestEvent"
    passwordResetHandlerComponent -> rabbitContainer "Handle: Tenant Password Reset Request Event from Queue X5.Admin.Messages.TenantPasswordResetRequestEvent"                      
    passwordResetHandlerComponent -> sqlContainer "Get User"            
    passwordResetHandlerComponent -> rabbitContainer "Publish: Send Reset Password Template Command to Queue X5.Shared.Messages.SendResetPasswordTemplateCommand"
    passwordResetHandlerComponent -> sqlContainer "Update User"            
    sendEmailHandlerComponent -> rabbitContainer "Handle: Send Reset Password Template Command from Queue X5.Shared.Messages.SendResetPasswordTemplateCommand"
    sendEmailHandlerComponent -> sqlContainer "Get Blacklist"            
    sendEmailHandlerComponent -> sesSystem "Send Email using Template"  
}