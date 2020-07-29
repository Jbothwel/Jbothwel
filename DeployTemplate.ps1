Connect-AzAccount -Environment AzureUSGovernment

$templateFile = "C:\Templates\bastion.json"
New-AzResourceGroupDeployment `
 -Name BastionTemplate `
 -ResourceGroupName jb-rg `
 -TemplateFile $templateFile
