#Requires -Version 3
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$scriptDir = Split-Path -LiteralPath $PSCommandPath
$startingLoc = Get-Location
Set-Location $scriptDir
$startingDir = [System.Environment]::CurrentDirectory
[System.Environment]::CurrentDirectory = $scriptDir

try {
    $xml = [xml](Get-Content ServerlessAngularTemplate.csproj)
    $properties = $xml.Project.PropertyGroup
    Write-Output $properties
    If($IsMacOS) {
        Import-Module AWSPowerShell.NetCore
    } Else {
        Import-Module AWSPowerShell
    }
    Get-AWSPowerShellVersion
    $apiURL = Get-CFNStack -Region $properties.DefaultAWSRegion -StackName $properties.StackName | Select-Object -ExpandProperty "Outputs" | Select-Object OutputKey, OutputValue | Where-Object {$_.OutputKey -Match "ApiURL"} | Select-Object -ExpandProperty OutputValue  
    $ngEnvFilePath = Join-Path -Path ClientApp -ChildPath $(Join-Path -Path "src" -ChildPath $(Join-Path -Path "environments" -ChildPath "environment.prod.ts"))
    Write-Output $apiURL
    Write-Output "Evaluating your environment.prod.ts file found here:"
    Write-Output $ngEnvFilePath
    Write-Output "Your environment.prod.ts file is only altered if the apiUrl is empty."
    Write-Output "This build step will not overwrite an existing value for apiUrl."
    $ngEnvFile = Get-Content $ngEnvFilePath
    $replacementNgEnvFile = $ngEnvFile.Replace("apiUrl: ''", "apiUrl: '$apiURL'")
    Write-Output $replacementNgEnvFile
    Out-File -FilePath $ngEnvFilePath -InputObject $replacementNgEnvFile
    Write-Output "Checking if Node.js is installed on this machine..."
    Start-Process node -ArgumentList @('--version') -Wait
    Start-Process -WorkingDirectory $properties.SpaRoot npm -ArgumentList @('install') -Wait -NoNewWindow
    Start-Process -WorkingDirectory $properties.SpaRoot npm -ArgumentList @('run build -- --prod') -Wait -NoNewWindow
    $bucketError = ""
    try {
        New-S3Bucket -BucketName $properties.S3BucketName -PublicReadOnly -Region $properties.DefaultAWSRegion  
    }
    catch {
        $bucketError = $_ | Out-String
    }
    if ($bucketError -and -not $bucketError.Contains("you already own it")) {
        Write-Output "found error"
        throw $error
    }
    else {
        Write-S3BucketWebsite -BucketName $properties.S3BucketName -WebsiteConfiguration_IndexDocumentSuffix index.html -WebsiteConfiguration_ErrorDocument index.html         
        Write-Output "Removing previous files from this S3 Bucket..."
        Get-S3Object -BucketName $properties.S3BucketName | Remove-S3Object -Force
    
        foreach ($f in (Get-ChildItem ClientApp/dist)) {
            Write-Output "Uploading $f to S3 Bucket..."
            Write-S3Object -BucketName $properties.S3BucketName  -File (Join-Path $properties.SpaRoot -ChildPath $(Join-Path "dist" -ChildPath $f)) -PublicReadOnly
            Write-Output "$f successfully uploaded."
        }
        $locationObj = Get-S3BucketLocation -BucketName $properties.S3BucketName
        $location = $locationObj.Value
        Write-Output $location
        if(!$locationObj.Value) {
            $location = "us-east-1"
        }
        Write-Output "View your site: http://$($properties.S3BucketName).s3-website.$location.amazonaws.com"
        Write-Output "Finished building."
    }
}
finally {
    Set-Location $startingLoc
    [System.Environment]::CurrentDirectory = $startingDir
    Write-Output "Done. Elapsed time: $($stopwatch.Elapsed)"
}
