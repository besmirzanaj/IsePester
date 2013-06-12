function Add-PesterMenu {

    $sb = {
    
        if(!$psISE.CurrentFile.IsUntitled) {
            $psISE.CurrentFile.Save()

            $fileName = $psISE.CurrentFile.FullPath
            
            if($filename -notmatch '\.tests\.') {
    
                $parts = $filename -split '\.'    
                $testFilename = "{0}.tests.ps1" -f ($parts[0..($parts.Count-2)] -join '.')
   
                Write-Debug $testFilename
    
                if(Test-Path $testFilename) {
                  $filename = $testFilename
                }

                Write-Debug $filename
            }

        } else {            
            $fileName = [io.path]::GetTempFileName().Replace(".tmp", ".tests.ps1")
            $psISE.CurrentFile.Editor.Text | Set-Content -Path $fileName 
        }

        Import-Module Pester

        cls

        Write-Debug $fileName
        Invoke-Pester -relative_path $fileName

        if(!$psISE.CurrentFile.IsSaved) { Remove-Item $fileName -Force -ErrorAction SilentlyContinue }
    }
    
    Remove-PesterMenu
    [void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("_Pester", $sb, "CTRL+F5") 
}

function Get-PesterMenu {

    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus | 
        Where {$_.DisplayName -Match "pester"}
}

function Remove-PesterMenu {

    $menu = Get-PesterMenu
    if($menu) {
        [void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Remove($menu)
    }
}

Add-PesterMenu