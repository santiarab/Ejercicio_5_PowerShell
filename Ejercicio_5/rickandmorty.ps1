<# --Todo--
.Synopsis
   Esto es una sinopsis corta
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
param (
   [Parameter(Mandatory = $false)]
   [Int[]]
   [ValidateScript({ $_ -gt 0 })]
   $id,

   [Parameter(Mandatory = $false)]
   [String[]]
   $nombre
)
if ( ( $null -eq $id -or $id.Length -eq 0) -and ($null -eq $nombre -or $nombre.Length -eq 0)) {
   # Pregunto si se envio almenos uno de los dos parametros
   Write-Output "No Cumple"
}
$FilePath = "$PWD\CharacterJson.json"

if (-not (Test-Path -Path $FilePath)) {
   # El archivo no existe, entonces crearlo
   Out-File -FilePath $FilePath
}
$url_base = "https://rickandmortyapi.com/api/character"
$character_json_list = Get-Content -Path $FilePath | Out-String
$json_list = $character_json_list | ForEach-Object { $_ | ConvertFrom-Json }

$character_json_list = New-Object System.Collections.ArrayList
foreach ($character in $json_list) {
   # Subo el json en la lista
   $character_json_list.Add($character) | Out-Null
}
#Buscar por ID
if ( !($null -eq $id -or $id.Length -eq 0 )) {
   foreach ($character in $id) {
      $character_json = $character_json_list | Where-Object { $_.id -eq $character }
      if ( $null -eq $character_json ) {
         $character_json = Invoke-WebRequest "$url_base/$character" | ConvertFrom-Json
         $character_json = $character_json | Select-Object `
         @{Name = 'id'; Expression = { $_.id } },
         @{Name = 'Name'; Expression = { $_.name } },
         @{Name = 'Status'; Expression = { $_.status } },
         @{Name = 'Species'; Expression = { $_.species } },
         @{Name = 'Type'; Expression = { $_.type } },
         @{Name = 'Gender'; Expression = { $_.gender } },
         @{Name = 'Origin'; Expression = { $_.origin.name } },
         @{Name = 'Location'; Expression = { $_.location.name } }
         $character_json_list.Add($character_json) | Out-Null
         Write-Output "Character info:"
         Write-Output $character_json
      }
      else {
         Write-Output "Character info:"
         Write-Output $character_json
      }   
   } 
}
$character_json_list | ConvertTo-Json | Out-File -FilePath $FilePath
