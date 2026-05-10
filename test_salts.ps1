$imei1 = "862624055623767"
$target1 = "dA5nzSYa"
$imei2 = "862624056036563"
$target2 = "fG2srAKC"

function alphabetChar($m) {
    if ($m -lt 10) { return [char](48 + $m) }
    if ($m -lt 36) { return [char](55 + $m) }
    return [char](61 + $m)
}

function generateFrom([string]$dataStr, [bool]$filterAmbiguous, [int]$base) {
    $len = $dataStr.Length
    $out = new-object char[] 8
    $AMBIGUOUS = "1ILil"
    
    for ($i = 0; $i -lt 8; $i++) {
        $seed = 1
        for ($j = 0; $j -lt $len; $j++) {
            while ($seed -gt 0xffffff) { $seed = -bnot $seed -band 0xffffff }
            $idx = ($i + $j) % $len
            $product = (($i + 1) * ($j + 1)) -band 0xff
            $seed = $seed + [int][char]$dataStr[$idx] * $product
        }
        while ($seed -gt 0xffffff) { $seed = -bnot $seed -band 0xffffff }
        
        $m = $seed % $base
        $ch = alphabetChar $m
        if ($filterAmbiguous -and $AMBIGUOUS.Contains($ch)) {
            $ch = [char]([int]$ch + 1)
        }
        $out[$i] = $ch
    }
    return -join $out
}

$salts = @("", "S50", "Dialog", "ZLT", "Tozed", "admin", "operator", "password", "1234", "0000", "50", "s50", "DIALOG", "router", "web")

foreach ($salt in $salts) {
    foreach ($filter in @($true, $false)) {
        foreach ($base in @(52, 62)) {
            $r1 = generateFrom "$imei1$salt" $filter $base
            $r2 = generateFrom "$imei2$salt" $filter $base
            
            $r1_pre = generateFrom "$salt$imei1" $filter $base
            $r2_pre = generateFrom "$salt$imei2" $filter $base
            
            if ($r1 -eq $target1 -or $r1_pre -eq $target1) {
                Write-Host "FOUND SALT: $salt with filter=$filter base=$base"
            }
        }
    }
}
Write-Host "Salt check complete."
