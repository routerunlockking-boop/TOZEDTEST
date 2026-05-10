$imei1 = "862624055623767"
$imei2 = "862624056036563"
$targetBytes1 = [System.Convert]::FromBase64String('dA5nzSYa')
$targetBytes2 = [System.Convert]::FromBase64String('fG2srAKC')

function Check-Hash($hashAlg, $inputStr, $targetBytes) {
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($inputStr)
    $hash = $hashAlg.ComputeHash($bytes)
    
    $match = $true
    for ($i = 0; $i -lt 6; $i++) {
        if ($hash[$i] -ne $targetBytes[$i]) { $match = $false; break }
    }
    if ($match) { Write-Host "Match found! Algorithm: $($hashAlg.ToString()), Input: $inputStr" }
}

$md5 = [System.Security.Cryptography.MD5]::Create()
$sha1 = [System.Security.Cryptography.SHA1]::Create()
$sha256 = [System.Security.Cryptography.SHA256]::Create()

$inputs = @(
    $imei1,
    $imei2,
    "86262405",
    "5623767",
    "6036563",
    $imei1.Substring(0, 14),
    $imei2.Substring(0, 14)
)

foreach ($input in $inputs) {
    $tgt = if ($input -match "5623767") { $targetBytes1 } else { $targetBytes2 }
    Check-Hash $md5 $input $tgt
    Check-Hash $sha1 $input $tgt
    Check-Hash $sha256 $input $tgt
    
    # Try appending common salts
    foreach ($salt in @("admin", "Dialog", "ZLT", "Tozed", "S50", "operator")) {
        Check-Hash $md5 "$input$salt" $tgt
        Check-Hash $sha1 "$input$salt" $tgt
        Check-Hash $sha256 "$input$salt" $tgt
        
        Check-Hash $md5 "$salt$input" $tgt
        Check-Hash $sha1 "$salt$input" $tgt
        Check-Hash $sha256 "$salt$input" $tgt
    }
}
Write-Host "Hash test finished."
