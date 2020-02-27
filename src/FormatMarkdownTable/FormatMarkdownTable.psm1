# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
# https://github.com/microsoft/FormatPowerShellToMarkdownTable

<#
.SYNOPSIS
Formats the output as a Format-List style markdown table.

.DESCRIPTION
The Format-MarkdownTableListStyle cmdlet formats the output of a command as a Format-List style markdown table which each property is displayed on a separate col.

Markdown text will be copied to the clipboard.

.PARAMETER InputObject
Specifies the objects to be formatted. Enter a variable that contains the objects or type a command or expression that gets the objects.

.PARAMETER HideStandardOutput
Indicates that the cmdlet hides the standard Format-List style output.

.PARAMETER ShowMarkdown
Indicates that the cmdlet outputs the markdown text to the console.

.PARAMETER DoNotCopyToClipboard
Indicates the the cmdlet does not copy the markdown text to the clipboard.

.PARAMETER Property
Specifies the object properties that appear in the display and the order in which they appear. Wildcards are permitted.

If you omit this parameter, the properties that appear in the display depend on the object being displayed. The parameter name "Property" is optional.

.EXAMPLE
Get-Process notepad | Format-MarkdownTableListStyle

.EXAMPLE
Get-Process notepad | fml Name,Path

.NOTES
You can also refer to Format-MarkdownTableListStyle by its built-in alias, FML.
#>#
function Format-MarkdownTableListStyle {
    [CmdletBinding()]
    [Alias("fml")]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]
        $InputObject,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]
        $HideStandardOutput,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]
        $ShowMarkdown,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]
        $DoNotCopyToClipboard,

        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $false)]
        [string[]]
        $Property = @()
    )
    
    Begin {
        if ($null -ne $InputObject -and $InputObject.GetType().BaseType -eq [System.Array]) {
            Write-Error "InputObject must not be System.Array. Don't use InputObject, but use the pipeline to pass the array object."
            $NeedToReturn = $true
            return
        }

        $LastCommandLine = (Get-PSCallStack)[1].Position.Text

        $Result = ""

        $TempOutputList = New-Object System.Collections.Generic.List[object]
    }

    Process {
        if ($NeedToReturn) { return }

        $CurrentObject = $null

        if ($_ -eq $null) {
            if (($Property.Length -eq 0) -or ($Property.Length -eq 1 -and $Property[0] -eq "")) {
                $Property = @("*")
            }

            $CurrentObject = $InputObject | Select-Object -Property $Property
        }
        else {
            if (($Property.Length -eq 0) -or ($Property.Length -eq 1 -and $Property[0] -eq "")) {
                $Property = @("*")
            }

            $CurrentObject = $_ | Select-Object -Property $Property
        }

        $Props = $CurrentObject | Get-Member -Name $Property -MemberType Property, NoteProperty

        $Output = "|Property|Value|`r`n"
        $Output += "|:--|:--|`r`n"

        $TempOutput = New-Object PSCustomObject

        foreach ($Prop in $Props) {
            $EscapedPropName = EscapeMarkdown($Prop.Name)
            $EscapedPropValue = EscapeMarkdown($CurrentObject.($($Prop.Name)))
            $Output += "|$EscapedPropName|$EscapedPropValue`r`n"
            $TempOutput | Add-Member -MemberType NoteProperty $Prop.Name -Value $CurrentObject.($($Prop.Name))
        }

        $Output += "`r`n"

        $Result += $Output

        $TempOutputList.Add($TempOutput)
    }
    
    End {
        if ($NeedToReturn) { return }

        $ResultForConsole = $Result
        $Result = "**" + $LastCommandLine.Replace("*", "\*") + "**`r`n`r`n" + $Result

        if ($HideStandardOutput.IsPresent -eq $false) {
            $TempOutputList | Format-List *
        }

        if ($ShowMarkdown.IsPresent) {
            Write-Output $ResultForConsole
        }

        if ($DoNotCopyToClipboard.IsPresent -eq $false) {
            Set-Clipboard $Result
            Write-Warning "Markdown text has been copied to the clipboard."
        }
    }
}

<#
.SYNOPSIS
Formats the output as a Format-Table style markdown table.

.DESCRIPTION
The Format-MarkdownTableTableStyle cmdlet formats the output of a command as a Format-Table style markdown table which each property is displayed on a separate row.

Markdown text will be copied to the clipboard.

.PARAMETER InputObject
Specifies the objects to be formatted. Enter a variable that contains the objects or type a command or expression that gets the objects.

.PARAMETER HideStandardOutput
Indicates that the cmdlet hides the standard Format-Table style output.

.PARAMETER ShowMarkdown
Indicates that the cmdlet outputs the markdown text to the console.

.PARAMETER DoNotCopyToClipboard
Indicates the the cmdlet does not copy the markdown text to the clipboard.

.PARAMETER Property
Specifies the object properties that appear in the display and the order in which they appear. Wildcards are permitted.

If you omit this parameter, the properties that appear in the display depend on the object being displayed. The parameter name "Property" is optional.

.EXAMPLE
Get-Process notepad | Format-MarkdownTableTableStyle

.EXAMPLE
Get-Process notepad | fmt Name,Path

.NOTES
You can also refer to Format-MarkdownTableTableStyle by its built-in alias, FMT.
#>
function Format-MarkdownTableTableStyle {
    [CmdletBinding()]
    [Alias("fmt")]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]
        $InputObject,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]
        $HideStandardOutput,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]
        $ShowMarkdown,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]
        $DoNotCopyToClipboard,

        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $false)]
        [string[]]
        $Property = @()
    )
    
    Begin {
        ## Internal Function

        function UseAllProperty([object]$InputObject) {
            try {
                if ($null -eq $InputObject) {
                    return $true
                }
    
                $DataType = ($InputObject | Get-Member)[0].TypeName
    
                if ($DataType.StartsWith("Selected.")) {
                    return $true
                }            
                elseif ($DataType.StartsWith("Deserialized.")) {
                    $DataType = $DataType.Remove(0, 13)
                }
    
                $FormatData = Get-FormatData -TypeName $DataType -ErrorAction SilentlyContinue
    
                if ($null -eq $FormatData) {
                    return $true
                }
    
                return $false
            }
            catch {
                return $true
            }
        }
        
        if ($null -ne $InputObject -and $InputObject.GetType().BaseType -eq [System.Array]) {
            Write-Error "InputObject must not be System.Array. Don't use InputObject, but use the pipeline to pass the array object."
            $NeedToReturn = $true
            return
        }

        $LastCommandLine = (Get-PSCallStack)[1].Position.Text

        $Result = ""

        $HeadersForFormatTableStyle = New-Object System.Collections.Generic.List[string]
        $ContentsForFormatTableStyle = New-Object System.Collections.Generic.List[object]

        $TempOutputList = New-Object System.Collections.Generic.List[object]
    }

    Process {
        if ($NeedToReturn) { return }

        $CurrentObject = $null

        if ($_ -eq $null) {
            $CurrentObject = $InputObject
        }
        else {
            $CurrentObject = $_
        }

        if (($Property.Length -eq 0) -or ($Property.Length -eq 1 -and $Property[0] -eq "")) {
            if (UseAllProperty($CurrentObject)) {
                $Property = @("*")
                $CurrentObject = $CurrentObject | Select-Object -Property $Property
                $Props = $CurrentObject | Get-Member -Name $Property -MemberType Property, NoteProperty
            }
            else {
                $DataType = ($CurrentObject | Get-Member)[0].TypeName
        
                if ($DataType.StartsWith("Deserialized.")) {
                    $DataType = $DataType.Remove(0, 13)
                }
        
                $FormatData = Get-FormatData -TypeName $DataType -ErrorAction SilentlyContinue
                
                $TempPSObject = New-Object PSCustomObject

                $TempHeaderList = New-Object System.Collections.Generic.List[string]

                for ($i = 0; $i -lt $FormatData.FormatViewDefinition.Control.Headers.Count; $i++) {
                    $HeaderName = $FormatData.FormatViewDefinition.Control.Headers[$i].Label

                    if ($null -eq $HeaderName -or $HeaderName -eq "") {
                        $HeaderName = $FormatData.FormatViewDefinition.Control.Rows.Columns[$i].DisplayEntry.Value
                    }

                    $TempSelectedObject = $null

                    if ($FormatData.FormatViewDefinition.Control.Rows.Columns[$i].DisplayEntry.ValueType -eq "ScriptBlock") {
                        $TempSelectedObject = $CurrentObject | Select-Object @{
                            n = $HeaderName;
                            e = ([scriptblock]::Create($FormatData.FormatViewDefinition.Control.Rows.Columns[$i].DisplayEntry.Value))
                        }
                    }
                    else {
                        $PropertyName = $FormatData.FormatViewDefinition.Control.Rows.Columns[$i].DisplayEntry.Value

                        $TempSelectedObject = $CurrentObject | Select-Object @{
                            n = $HeaderName;
                            e = {$_.$($PropertyName)}
                        }
                    }

                    $Value = $TempSelectedObject.$($HeaderName)
                    $TempPSObject | Add-Member -MemberType NoteProperty $HeaderName -Value $Value
                    $TempHeaderList.Add($HeaderName)
                }
                
                $CurrentObject = $TempPSObject | Select-Object -Property $TempHeaderList
                $Props = $CurrentObject | Get-Member -Name $TempHeaderList -MemberType Property, NoteProperty
            }
        }
        else {
            $CurrentObject = $CurrentObject | Select-Object -Property $Property
            $Props = $CurrentObject | Get-Member -Name $Property -MemberType Property, NoteProperty
        }

        foreach ($Prop in $Props) {
            if ($HeadersForFormatTableStyle.Contains($Prop.Name) -eq $false) {
                $HeadersForFormatTableStyle.Add($Prop.Name)
            }
        }

        $ContentsForFormatTableStyle.Add($CurrentObject)
    }
    
    End {
        if ($NeedToReturn) { return }

        $HeaderRow = "|"
        $SeparatorRow = "|"
        $ContentRow = ""

        foreach ($Prop in $HeadersForFormatTableStyle) {
            $HeaderRow += "$(EscapeMarkdown($Prop))|"
            $SeparatorRow += ":--|"
            
        }

        foreach ($Content in $ContentsForFormatTableStyle) {
            $TempOutput = New-Object PSCustomObject
            $ContentRow += "|"

            foreach ($Prop in $HeadersForFormatTableStyle) {
                $ContentRow += "$(EscapeMarkdown($Content.($($Prop))))|"

                $TempOutput | Add-Member -MemberType NoteProperty $Prop -Value $Content.($($Prop))
            }
            
            $ContentRow += "`r`n"

            $TempOutputList.Add($TempOutput)
        }

        $Result = $HeaderRow + "`r`n" + $SeparatorRow + "`r`n" + $ContentRow

        $ResultForConsole = $Result
        $Result = "**" + $LastCommandLine.Replace("*", "\*") + "**`r`n`r`n" + $Result

        if ($HideStandardOutput.IsPresent -eq $false) {
            $TempOutputList | Format-Table * -AutoSize
        }

        if ($ShowMarkdown.IsPresent) {
            Write-Output $ResultForConsole
        }

        if ($DoNotCopyToClipboard.IsPresent -eq $false) {
            Set-Clipboard $Result
            Write-Warning "Markdown text has been copied to the clipboard."
        }
    }
}

function EscapeMarkdown([object]$InputObject) {
    $Temp = ""

    if ($null -eq $InputObject) {
        return ""
    }
    elseif ($InputObject.GetType().BaseType -eq [System.Array]) {
        $Temp = "{" + [System.String]::Join(", ", $InputObject) + "}"
    }
    elseif ($InputObject.GetType() -eq [System.Collections.ArrayList]) {
        $Temp = "{" + [System.String]::Join(", ", $InputObject.ToArray()) + "}"
    }
    elseif (Get-Member -InputObject $InputObject -Name ToString -MemberType Method) {
        $Temp = $InputObject.ToString()
    }
    else {
        $Temp = ""
    }

    return $Temp.Replace("*", "\*")
}

Export-ModuleMember -Function Format-MarkdownTableListStyle, Format-MarkdownTableTableStyle -Alias *