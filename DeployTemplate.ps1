Connect-AzAccount -Environment AzureUSGovernment
emp\$templateFile = "C:\Templates\Templates\bastion.json"
$parameterFile = "C:\Templates\Templates\parameters.josn"
New-AzResourceGroupDeployment `
 -Name BastionTemplate `
 -ResourceGroupName jb-rg `
 -TemplateFile $templateFile `
 -TemplateParameterFile $parameters