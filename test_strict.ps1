$imei1 = "862624055623767"
$target1 = "dA5nzSYa"
$imei2 = "862624056036563"
$target2 = "fG2srAKC"

$charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

function Test-FormulaStrict {
    for ($a = 0; $a -le 10; $a++) {
        for ($b = 0; $b -le 5; $b++) {
            for ($c = 0; $c -le 5; $c++) {
                for ($op1 = 0; $op1 -le 1; $op1++) {
                    for ($op2 = 0; $op2 -le 1; $op2++) {
                        foreach ($base in @(52, 62)) {
                            
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
                                        else { $term1 = ([int][char]$dataStr[$idx] - 48) }
                                        
                                        if ($op2 -eq 0) { $seed = $seed + $term1 * $product }
                                        else { $seed = $seed + $term1 + $product }
                                    }
                                    while ($seed -gt 0xffffff) { $seed = -bnot $seed -band 0xffffff }
                                    
                                    $m = $seed % $base
                                    $targetChar = $test.t[$i]
                                    $expectedM = $charset.IndexOf($targetChar)
                                    
                                    # If charset is 52, the original code skips ambiguous characters!
                                    # Wait, let's just check if the char from standard charset matches.
                                    # We'll re-implement the exact alphabetChar
                                    
                                    if ($base -eq 62) {
                                        $ch = $charset[$m]
                                    } else {
                                        if ($m -lt 10) { $ch = [char](48 + $m) }
                                        elseif ($m -lt 36) { $ch = [char](55 + $m) }
                                        else { $ch = [char](61 + $m) }
                                    }
                                    
                                    if ($ch -ne $targetChar) {
                                        $valid = $false
                                        break
                                    }
                                }
                                if (-not $valid) { break }
                            }
                            
                            if ($valid) {
                                Write-Host "STRICT MATCH FOUND! a=$a, b=$b, c=$c, op1=$op1, op2=$op2, base=$base"
                            }
                        }
                    }
                }
            }
        }
    }
}
Write-Host "Strict searching..."
Test-FormulaStrict
Write-Host "Done."
