#
#   Retrieve the git log history between two commit IDs (start, end).  These commits are assumed to be linear between
#   each other and inclusive.
#
Function Get-GitLog
{
<#
.Synopsis
    Returns the Git log history in a structured PowerShell object between two commit IDs.
.Description
    Returns the Git log history in a structured PowerShell object between two commit IDs.
.Parameter StartCommit
    The starting commit ID.
.Parameter EndCommit
    The ending commit ID.
.Example
    Get-GitLog -StartCommit <rev1> -EndCommit <rev2>
#>

[CmdletBinding(
    SupportsShouldProcess=$False,
    SupportsTransactions=$False,
    ConfirmImpact="Low",
    DefaultParameterSetName="")]
param(
    [Parameter(Position=0, Mandatory=$true)]
    [string] $StartCommit,

    [Parameter(Position=1, Mandatory=$true)]
    [string] $EndCommit
)

BEGIN {}

PROCESS {
    $history = @();
    $beginRecordSeparator = "@@*@@";
    $endFormatLineSeparator = "**^**";
    $columnSeparator = "##^##";
    $newLineSeparator = "^^*^^";
    $gitCmdFormat = "$beginRecordSeparator %an $columnSeparator %H $columnSeparator %h $columnSeparator %ad $columnSeparator %s $endFormatLineSeparator";

    $result = git log --decorate --pretty=format:"$gitCmdFormat" $StartCommit^..$EndCommit
    $results = $result.Split($beginRecordSeparator, [StringSplitOptions]::RemoveEmptyEntries);

    $results | % {
        #
        #   Skip null or empty lines
        #
        $line = $_.Trim();
        if (($line -eq $null) -or ($line -eq "")) {
            return;
        }

        #
        #   Split the line based on the column separator
        #
        $record = $line.Split($columnSeparator, [StringSplitOptions]::RemoveEmptyEntries);
        if ($record.Length -eq 0) {
            return;
        }

        #
        #   Construct the history object
        #
        $history += @{
            AuthorName = $record[0].Trim();
            CommitHash = $record[1].Trim();
            AbbreviatedCommitHash = $record[2].Trim();
            AuthorDate = $record[3].Trim();
            Subject = $record[4].Trim();
        }    
    }
    return $history;
}

END {}

}
