# FormatMarkdownTable PowerShell Module

FormatMarkdownTable is a PowerShell module which contains Format-MarkdownTableListStyle cmdlet and Format-MarkdownTableTableStyle cmdlet.

## Example

```powershell
Get-ChildItem c:\ | Format-MarkdownTableListStyle Name, LastWriteTime, Mode
```

This example returns a summary of the child items in C drive, and markdown text will be copied to the clipboard. Each property is displayed on a separate row.

```powershell
Get-ChildItem c:\ | Format-MarkdownTable Name, LastWriteTime, Mode -FormatTableStyle
```

This example returns a summary of the child items in C drive, and markdown text will be copied to the clipboard. Each property is displayed on a separate col.

## Alias

You can also refer to Format-MarkdownTableListStyle by its built-in alias, FML.

You can also refer to Format-MarkdownTableTableStyle by its built-in alias, FMT.

## Switch

```powershell
Get-ChildItem c:\ | fml Name, LastWriteTime, Mode -HideStandardOutput
```

HideStandardOutput indicates that the cmdlet hides the standard output.

```powershell
Get-ChildItem c:\ | fml Name, LastWriteTime, Mode -HideStandardOutput -ShowMarkdown
```

ShowMarkdown indicates that the cmdlet outputs the markdown text to the console.

```powershell
Get-ChildItem c:\ | fml Name, LastWriteTime, Mode -HideStandardOutput -ShowMarkdown -DoNotCopyToClipboard
```

DoNotCopyToClipboard indicates the the cmdlet does not copy the markdown text to the clipboard.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
