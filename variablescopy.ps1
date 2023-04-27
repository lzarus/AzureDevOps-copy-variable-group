Param(
  [string]$VarGroupIdsrc = "1",
  $source = [PSCustomObject]@{
    organization = ""
    project      = ""
    pat          = ""
  },
  $destination = [PSCustomObject]@{
    organization = ""
    project      = ""
    pat          = ""
  },
  $user = ""
           
)
function authOf ($tkn) {
  $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $tkn)))
  $header = @{Authorization = ("Basic {0}" -f $base64AuthInfo) }
  return $header  
}

function GetSourceVariableGroup ($src) {
  $org = $src.organization
  $proj = $src.project
  $tkn = $src.pat
  $url = "https://dev.azure.com/$org/$proj/_apis/distributedtask/variablegroups/" + "$VarGroupIdsrc" + "?api-version=5.0-preview.1"
  Write-Host "Url source : $url"
  $header = authOf $tkn
  $data = Invoke-RestMethod -Uri $url -Headers $header -Method 'Get' -ContentType "application/json" | ConvertTo-Json
  $obj = ConvertFrom-Json $data
  $obj.name = $obj.name + "-copy"
  $body = ConvertTo-Json $obj
  
  CreateVarGroupOnNewProject $body $destination
}

function CreateVarGroupOnNewProject($body, $destination) {
  $org = $destination.organization
  $proj = $destination.project
  $tkn = $destination.pat
  $header = authOf $tkn
  $urldest = "https://dev.azure.com/$org/$proj/_apis/distributedtask/variablegroups?api-version=5.0-preview.1"
  Write-Host "Url dest : $urldest"
  Invoke-RestMethod -Uri $urldest -Headers $header -ContentType "application/json" -Method post -Body $body  
}
if (-not ([string]::IsNullOrEmpty($VarGroupIdsrc))) {
  GetSourceVariableGroup $source
  return $VarGroupId
} 
else {
  Write-Output "Variable Name does not exist"
}



 