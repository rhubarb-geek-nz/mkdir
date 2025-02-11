#!/usr/bin/env pwsh
# Copyright 2025, Roger Brown
# Licensed under the MIT License.

param(
	$ModuleName = 'mkdir',
	$CompanyName = 'rhubarb-geek-nz',
	$ModuleVersion = '1.0.0'
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ModuleId = "$CompanyName.$ModuleName"
$Version = $PSVersionTable.PSVersion
$PublishDir = "Modules\$ModuleId\$ModuleVersion"

trap
{
	throw $PSItem
}

foreach ($Name in 'Modules')
{
	if (Test-Path -LiteralPath $Name)
	{
		Remove-Item "$Name" -Force -Recurse
	} 
}

$command = Get-Command -Name 'mkdir'
$definition = $command.Definition

if ($command.CommandType -ne 'Function')
{
	$definition = [System.Management.Automation.Runspaces.InitialSessionState].GetMethod('GetMkdirFunctionText', [System.Reflection.BindingFlags]'Static, NonPublic').Invoke($null, @())
}

$null = New-Item -Path $PublishDir -ItemType Directory

'# Copyright (c) Microsoft Corporation.',
'# Licensed under the MIT License.',
'function New-Directory',
'{',
$definition,
'}',
'Export-ModuleMember -Function New-Directory' | Set-Content -LiteralPath "$PublishDir\$ModuleName.psm1"

$moduleSettings = @{
	Path = "$ModuleId.psd1"
	RootModule = "$ModuleName.psm1"
	ModuleVersion = $ModuleVersion
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

	Import-PowerShellDataFile -LiteralPath "$ModuleId.psd1" | Export-PowerShellDataFile | Set-Content -LiteralPath "$PublishDir\$ModuleId.psd1"
}
finally
{
	Remove-Item "$ModuleId.psd1"
}
