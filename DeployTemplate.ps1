Connect-AzAccount -Environment AzureUSGovernment
emp\$templateFile = "C:\Templates\Templates\bastion.json"
$parameterFile = "C:\Repro\Templates\Bastion.parameters.josn"
New-AzResourceGroupDeployment `
 -Name BastionTemplate `
 -ResourceGroupName jb-rg `
 -TemplateFile $templateFile `
 -TemplateParameterFile $parameterFile