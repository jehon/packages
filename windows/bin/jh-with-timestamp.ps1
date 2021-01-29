
Param([String]$path)

$backupDir = "$HOME\OneDrive - NSI IT Software & Services (NSISABE)\Documents\Backups"

# Thanks to https://stackoverflow.com/a/1954384/1954789

$dirName  = [io.path]::GetDirectoryName($path)
if ($dirName) {
    $dirName = $dirName + '\'
}
$filename = [io.path]::GetFileNameWithoutExtension($path)
$ext      = [io.path]::GetExtension($path)
$ts       = get-date -Format "yyyy-MM-dd hh-mm-ss"
$newName  = "$filename-$ts$ext"

echo "In:         $dirName"
echo "From:       $filename$ext"
echo "To:         $newName"
echo "Backup dir: $backupDir"
echo "Copy to" "$path" "$backupDir$newName"
Copy-Item "$path" "$backupDir\$newName"

pause
