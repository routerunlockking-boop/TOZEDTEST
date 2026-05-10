function generateFrom([string]$dataStr) {
    $len = $dataStr.Length
    $out = new-object char[] 8
    
    for ($i = 0; $i -lt 8; $i++) {
        $seed = 1
        for ($j = 0; $j -lt $len; $j++) {
            while ($seed -gt 0xffffff) { $seed = -bnot $seed -band 0xffffff }
            $idx = ($i + $j) % $len
            $product = (($i + 1) * ($j + 1)) -band 0xff
            $seed = $seed + [int][char]$dataStr[$idx] * $product
        }
        while ($seed -gt 0xffffff) { $seed = -bnot $seed -band 0xffffff }
        
        $m = $seed % 62
        if ($m -lt 10) { $ch = [char](48 + $m) }
        elseif ($m -lt 36) { $ch = [char](55 + $m) }
        else { $ch = [char](61 + $m) }
        
        $out[$i] = $ch
    }
    return -join $out
}

$imei1 = "862624055623767"
$imei2 = "862624056036563"

Write-Host "Base62 no-filter on IMEI 1:" (generateFrom $imei1)
Write-Host "Base62 no-filter on IMEI 2:" (generateFrom $imei2)

# Also test with MAC appended
$mac = "D842F7B23A8C"
Write-Host "Base62 no-filter on IMEI 1 + MAC:" (generateFrom "$imei1$mac")
Write-Host "Base62 no-filter on IMEI 1 + MAC lower:" (generateFrom "$imei1$($mac.ToLower())")
Write-Host "Base62 no-filter on MAC:" (generateFrom $mac)

