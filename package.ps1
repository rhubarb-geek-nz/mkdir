# Copyright 2025, Roger Brown
# Licensed under the MIT License.

param(
	$ModuleName = 'mkdir',
	$CompanyName = 'rhubarb-geek-nz'
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ModuleId = "$CompanyName.$ModuleName"
$Version = $PSVersionTable.PSVersion
$PublishDir = $ModuleId

trap
{
	throw $PSItem
}

if (-not $IsWindows)
{
	throw 'Must run with Windows PowerShell 7'
}

foreach ($Name in $PublishDir)
{
	if (Test-Path -LiteralPath $Name)
	{
		Remove-Item "$Name" -Force -Recurse
	} 
}

$null = New-Item -Path $PublishDir -ItemType Directory

Invoke-Command -ScriptBlock {
	'# Copyright (c) Microsoft Corporation.'
	'# Licensed under the MIT License.'
	'function New-Directory'
	'{'
	(Get-Command -Name 'mkdir').Definition
	'}'
	'Export-ModuleMember -Function New-Directory'
} | Set-Content -LiteralPath "$PublishDir\$ModuleName.psm1" -Encoding utf8BOM

$moduleSettings = @{
	Path = "$ModuleId.psd1"
	RootModule = "$ModuleName.psm1"
	ModuleVersion = '1.0.0'
	Guid = '54ab514e-bb66-4909-a7a0-25b959429bb6'
	Author = 'Roger Brown'
	CompanyName = $CompanyName
	Copyright = 'Copyright © 2025 Roger Brown'
	Description = "New-Directory function generated from PowerShell $Version mkdir"
	FunctionsToExport = @('New-Directory')
	CmdletsToExport = @()
	VariablesToExport = '*'
	AliasesToExport = @()
	ProjectUri = "https://github.com/$CompanyName/$ModuleName"
}

try
{
	New-ModuleManifest @moduleSettings

	Import-PowerShellDataFile -LiteralPath "$ModuleId.psd1" | Export-PowerShellDataFile | Set-Content -LiteralPath "$PublishDir\$ModuleId.psd1" -Encoding utf8BOM
}
finally
{
	Remove-Item "$ModuleId.psd1"
}
