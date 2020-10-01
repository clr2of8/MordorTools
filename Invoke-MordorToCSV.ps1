function Invoke-MordorToCSV {


    Param(

        [Parameter(Mandatory = $true)]
        [string]
        $mordorDataUrl,

        [Parameter(Mandatory = $false)]
        [string]
        $outDir = [Environment]::GetFolderPath("Desktop"),


        [Parameter(Mandatory = $false)]
        [Switch]
        $All = $false

    )

    $filename = $mordorDataUrl.Substring($mordorDataUrl.LastIndexOf("/") + 1).TrimEnd(".zip")
    Write-Host -Fore Yellow "Converting '$filename' Mordor data to CSV"
    if (-not (Test-Path "$env:TEMP\$filename.zip")) {
        Invoke-WebRequest $mordorDataUrl -OutFile "$env:TEMP\$filename.zip"
    }
    Expand-Archive $env:TEMP\$filename.zip $env:TEMP\$filename -Force
    $tagsToKeep = ('Hostname', 'Channel', 'EventTime', 'EventID', 'Category')
    $json = Get-Content $env:TEMP\$filename\*.json | ConvertFrom-Json
    ForEach ($element in $json) {
        $element.psobject.properties.remove('Keywords')
        $element.psobject.properties.remove('tags')
        if (-not $All) {
            Foreach ($prop in $element.psobject.Properties) {
                if (-not ($tagsToKeep -contains $prop.Name)) {
                    $element.psobject.properties.remove($prop.Name)
                }
            }
        }
    }
    $outFile = Join-Path $outDir "$filename.csv"
    try {
    $json | ConvertTo-CSV -NoTypeInformation | Set-Content $outFile -Force
    } catch [System.IO.IOException] {
        Write-Host -Fore red "The file '$outFile' is being used by another process, perhaps Excel? Please close the file and try again."
        exit
    }
    Write-Host -Fore green "Done! CSV Data written to $outFile"
}

# Invoke-MordorToCSV "https://raw.githubusercontent.com/OTRF/mordor/master/datasets/small/windows/credential_access/host/empire_shell_reg_dump_sam.zip" -All
