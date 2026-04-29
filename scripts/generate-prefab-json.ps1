param(
    [Parameter(Mandatory = $true)]
    [string]$SpecPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

function Get-Number {
    param(
        [Parameter(Mandatory = $false)]
        $Value,
        [Parameter(Mandatory = $true)]
        [double]$DefaultValue
    )

    if ($null -eq $Value) {
        return $DefaultValue
    }
    return [double]$Value
}

function New-FileId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix,
        [Parameter(Mandatory = $true)]
        [int]$Index
    )

    return ("{0}{1:D5}" -f $Prefix, $Index)
}

if (-not (Test-Path -Path $SpecPath)) {
    throw "Spec file not found: $SpecPath"
}

$spec = Get-Content -Raw -Path $SpecPath | ConvertFrom-Json
if ($null -eq $spec.nodes) {
    throw "Spec must include 'nodes'."
}

$nodes = @($spec.nodes)
if ($nodes.Count -eq 0) {
    throw "Spec must include at least one node."
}

$nameToIndex = @{}
for ($i = 0; $i -lt $nodes.Count; $i++) {
    $name = [string]$nodes[$i].name
    if ([string]::IsNullOrWhiteSpace($name)) {
        throw "Node at index $i has an empty name."
    }
    if ($nameToIndex.ContainsKey($name)) {
        throw "Duplicate node name found: $name"
    }
    $nameToIndex[$name] = $i
}

$rootName = [string]$spec.root
if ([string]::IsNullOrWhiteSpace($rootName)) {
    throw "Spec must include a non-empty 'root' field."
}
if (-not $nameToIndex.ContainsKey($rootName)) {
    throw "Root node '$rootName' was not found in nodes."
}

for ($i = 0; $i -lt $nodes.Count; $i++) {
    $nodeName = [string]$nodes[$i].name
    if ($nodeName -eq $rootName) {
        continue
    }

    $parentName = [string]$nodes[$i].parent
    if ([string]::IsNullOrWhiteSpace($parentName)) {
        throw "Node '$nodeName' must have a parent."
    }
    if (-not $nameToIndex.ContainsKey($parentName)) {
        throw "Node '$nodeName' references missing parent '$parentName'."
    }
}

$records = New-Object System.Collections.ArrayList

function Add-Record {
    param([Parameter(Mandatory = $true)]$Record)
    [void]$records.Add($Record)
    return ($records.Count - 1)
}

$prefabName = [string]$spec.prefabName
if ([string]::IsNullOrWhiteSpace($prefabName)) {
    $prefabName = "GeneratedPrefab"
}

$prefabRecordId = Add-Record -Record @{
    "__type__" = "cc.Prefab"
    "_name" = $prefabName
    "_objFlags" = 0
    "__editorExtras__" = @{}
    "_native" = ""
    "data" = @{ "__id__" = 0 }
    "optimizationPolicy" = 0
    "persistent" = $false
}

$entries = New-Object System.Collections.ArrayList
$entryByName = @{}

for ($i = 0; $i -lt $nodes.Count; $i++) {
    $node = $nodes[$i]
    $nodeName = [string]$node.name

    $nodeRecordId = Add-Record -Record @{
        "__type__" = "cc.Node"
        "_name" = $nodeName
        "_objFlags" = 0
        "__editorExtras__" = @{}
        "_parent" = $null
        "_children" = @()
        "_active" = $true
        "_components" = @()
        "_prefab" = @{ "__id__" = 0 }
        "_lpos" = @{
            "__type__" = "cc.Vec3"
            "x" = (Get-Number -Value $node.x -DefaultValue 0)
            "y" = (Get-Number -Value $node.y -DefaultValue 0)
            "z" = (Get-Number -Value $node.z -DefaultValue 0)
        }
        "_lrot" = @{ "__type__" = "cc.Quat"; "x" = 0; "y" = 0; "z" = 0; "w" = 1 }
        "_lscale" = @{ "__type__" = "cc.Vec3"; "x" = 1; "y" = 1; "z" = 1 }
        "_mobility" = 0
        "_layer" = 33554432
        "_euler" = @{ "__type__" = "cc.Vec3"; "x" = 0; "y" = 0; "z" = 0 }
        "_id" = ""
    }

    $uiTransformRecordId = Add-Record -Record @{
        "__type__" = "cc.UITransform"
        "_name" = ""
        "_objFlags" = 0
        "__editorExtras__" = @{}
        "node" = @{ "__id__" = $nodeRecordId }
        "_enabled" = $true
        "__prefab" = @{ "__id__" = 0 }
        "_contentSize" = @{
            "__type__" = "cc.Size"
            "width" = (Get-Number -Value $node.width -DefaultValue 100)
            "height" = (Get-Number -Value $node.height -DefaultValue 100)
        }
        "_anchorPoint" = @{
            "__type__" = "cc.Vec2"
            "x" = (Get-Number -Value $node.anchorX -DefaultValue 0.5)
            "y" = (Get-Number -Value $node.anchorY -DefaultValue 0.5)
        }
        "_id" = ""
    }

    $compPrefabInfoRecordId = Add-Record -Record @{
        "__type__" = "cc.CompPrefabInfo"
        "fileId" = (New-FileId -Prefix "cmp" -Index $i)
    }

    $prefabInfoRecordId = Add-Record -Record @{
        "__type__" = "cc.PrefabInfo"
        "root" = @{ "__id__" = 0 }
        "asset" = @{ "__id__" = 0 }
        "fileId" = (New-FileId -Prefix "pf" -Index $i)
        "instance" = $null
        "targetOverrides" = $null
        "nestedPrefabInstanceRoots" = $null
    }

    $records[$nodeRecordId]["_components"] = @(@{ "__id__" = $uiTransformRecordId })
    $records[$nodeRecordId]["_prefab"] = @{ "__id__" = $prefabInfoRecordId }
    $records[$uiTransformRecordId]["__prefab"] = @{ "__id__" = $compPrefabInfoRecordId }

    $entry = [ordered]@{
        name = $nodeName
        parent = [string]$node.parent
        nodeRecordId = $nodeRecordId
        uiTransformRecordId = $uiTransformRecordId
        compPrefabInfoRecordId = $compPrefabInfoRecordId
        prefabInfoRecordId = $prefabInfoRecordId
    }

    [void]$entries.Add($entry)
    $entryByName[$nodeName] = $entry
}

$rootEntry = $entryByName[$rootName]
$rootNodeRecordId = [int]$rootEntry.nodeRecordId

$records[$prefabRecordId]["data"] = @{ "__id__" = $rootNodeRecordId }

foreach ($entry in $entries) {
    $nodeName = [string]$entry.name
    $nodeRecordId = [int]$entry.nodeRecordId

    if ($nodeName -eq $rootName) {
        $records[$nodeRecordId]["_parent"] = $null
    }
    else {
        $parentName = [string]$entry.parent
        $parentNodeRecordId = [int]$entryByName[$parentName].nodeRecordId
        $records[$nodeRecordId]["_parent"] = @{ "__id__" = $parentNodeRecordId }
    }

    $childRefs = New-Object System.Collections.ArrayList
    foreach ($childEntry in $entries) {
        if ([string]$childEntry.parent -eq $nodeName) {
            [void]$childRefs.Add(@{ "__id__" = [int]$childEntry.nodeRecordId })
        }
    }
    $records[$nodeRecordId]["_children"] = $childRefs

    $prefabInfoRecordId = [int]$entry.prefabInfoRecordId
    $records[$prefabInfoRecordId]["root"] = @{ "__id__" = $rootNodeRecordId }
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDirectory) -and -not (Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$json = $records | ConvertTo-Json -Depth 30
Set-Content -Path $OutputPath -Value $json -Encoding UTF8

Write-Host "Prefab scaffold generated (project-compatible fields): $OutputPath"
