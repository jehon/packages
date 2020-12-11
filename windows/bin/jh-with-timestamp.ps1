
Param([String]$path)

# Thanks to https://stackoverflow.com/a/1954384/1954789

$dirName  = [io.path]::GetDirectoryName($path)
if ($dirName) {
    $dirName = $dirName + '\'
}
$filename = [io.path]::GetFileNameWithoutExtension($path)
$ext      = [io.path]::GetExtension($path)
$ts       = get-date -Format "yyyy-MM-dd hh-mm-ss"
$newName  = "$filename-$ts$ext"

echo "In: '$dirName'"
echo "From: $filename$ext"
echo "To:   $newName"
echo "Rename-Item" "$path" "$dirName$newName"
Copy-Item "$path" "$dirName$newName"

pause
