Connect-AzAccount -Environment AzureUSGovernment

$templateFile = "C:\Templates\Templates\bastion.json"
New-AzResourceGroupDeployment `
 -Name BastionTemplate `
 -ResourceGroupName jb-rg `
 -TemplateFile $templateFile
