param subscriptionID string = 'cb012496-ce0b-4c24-9afe-bb7e27ca8f42cd'
param osDiskID string = concat('/subscriptions/${subscriptionID}/resourceGroups/MIM-rg/providers/Microsoft.Compute/disks/MIM-DC-01_OsDisk')
output stringoutput string = osDiskID
