$imei1 = "862624055623767"
$target1 = "dA5nzSYa"

$imei2 = "862624056036563"
$target2 = "fG2srAKC"

# Charset we can map from
$charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

function Test-Formula {
    param([int]$a, [int]$b, [int]$c, [int]$op1, [int]$op2, [int]$base)
    
    $map = @{}
    $valid = $true
    
    foreach ($test in @( @{i=$imei1; t=$target1}, @{i=$imei2; t=$target2} )) {
        $dataStr = $test.i
        $len = $dataStr.Length
        
        for ($i = 0; $i -lt 8; $i++) {
            $seed = 1
            for ($j = 0; $j -lt $len; $j++) {
                while ($seed -gt 0xffffff) { $seed = -bnot $seed -band 0xffffff }
                $idx = ($i + $j + $a) % $len
                $product = (($i + $b) * ($j + $c)) -band 0xff
                
                if ($op1 -eq 0) { $term1 = [int][char]$dataStr[$idx] }
                elseif ($op1 -eq 1) { $term1 = ([int][char]$dataStr[$idx] - 48) }
                else { $term1 = [int][char]$dataStr[$idx] * $product }
                
                if ($op2 -eq 0) { $seed = $seed + $term1 * $product }
                elseif ($op2 -eq 1) { $seed = $seed + $term1 + $product }
                elseif ($op2 -eq 2) { $seed = $seed * $term1 + $product }
                elseif ($op2 -eq 3) { $seed = ($seed -bxor $term1) + $product }
            }
            while ($seed -gt 0xffffff) { $seed = -bnot $seed -band 0xffffff }
            
            $m = $seed % $base
            $targetChar = $test.t[$i]
            
            if ($map.ContainsKey($m) -and $map[$m] -ne $targetChar) {
                $valid = $false
                break
            }
            $map[$m] = $targetChar
        }
        if (-not $valid) { break }
    }
    
    if ($valid) {
        Write-Host "MATCH FOUND! a=$a, b=$b, c=$c, op1=$op1, op2=$op2, base=$base"
        foreach ($k in $map.Keys) {
            Write-Host "  $k -> $($map[$k])"
        }
    }
}

Write-Host "Searching..."
for ($a = 0; $a -le 2; $a++) {
    for ($b = 0; $b -le 2; $b++) {
        for ($c = 0; $c -le 2; $c++) {
            for ($op1 = 0; $op1 -le 2; $op1++) {
                for ($op2 = 0; $op2 -le 3; $op2++) {
                    foreach ($base in @(52, 62, 64, 256)) {
                        Test-Formula -a $a -b $b -c $c -op1 $op1 -op2 $op2 -base $base
                    }
                }
            }
        }
    }
}
Write-Host "Done searching."
