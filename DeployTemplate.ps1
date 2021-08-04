Connect-AzAccount -Environment AzureUSGovernment
$templateFile = "C:\repro\Templates\bastion.json"
$parameterFile = "C:\repro\Templates\Bastion.parameters.json"
New-AzResourceGroupDeployment `
 -Name BastionTemplate `
 -ResourceGroupName jb-rg `
 -TemplateFile $templateFile `
 -TemplateParameterFile $parameterFile