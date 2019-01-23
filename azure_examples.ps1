# Remove all powershell cached creds:
Get-AzureAccount | ForEach-Object { Remove-AzureAccount $_.ID -Force }

# List azure accounts
Get-AzureAccount

# List azure subscriptions
Get-AzureSubscription | Format-Table SubscriptionName, IsDefault, IsCurrent, DefaultAccount, SubscriptionId

# Add cached account for azure
Add-AzureAccount

# Lists azure vms in subscription
Get-AzureVM



