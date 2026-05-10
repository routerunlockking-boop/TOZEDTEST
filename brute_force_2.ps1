$imei1 = "862624055623767"
$target1 = "dA5nzSYa"
$imei2 = "862624056036563"
$target2 = "fG2srAKC"

$AMBIGUOUS = "1ILil"

function get-alphabetChar([int]$m) {
    if ($m -lt 10) { return 48 + $m }
    elseif ($m -lt 36) { return 55 + $m }
    else { return 61 + $m }
}

function testParams($a, $b, $c, $op1, $op2, $base, $initSeed, $mult1, $mult2) {
    function generate($dataStr) {
        $len = $dataStr.Length
        $out = New-Object char[] 8
        for ($i = 0; $i -lt 8; $i++) {
            $seed = $initSeed
            for ($j = 0; $j -lt $len; $j++) {
                while ($seed -gt 0xffffff) { $seed = (-bnot $seed) -band 0xffffff }
                $idx = ($i + $j + $a) % $len
                $product = (($i + $mult1) * ($j + $mult2)) -band 0xff
                
                $term1 = [int][char]$dataStr[$idx]
                if ($op1 -eq 1) { $term1 = $term1 - 48 }
                elseif ($op1 -eq 2) { $term1 = $term1 * $product }

                if ($op2 -eq 0) { $seed = $seed + $term1 * $product }
                elseif ($op2 -eq 1) { $seed = $seed + $term1 + $product }
                elseif ($op2 -eq 2) { $seed = $seed * $term1 + $product }
                elseif ($op2 -eq 3) { $seed = ($seed -bxor $term1) + $product }
            }
            while ($seed -gt 0xffffff) { $seed = (-bnot $seed) -band 0xffffff }
            
            $m = $seed % $base
            $ch = get-alphabetChar $m
            if ($base -eq 52) {
                if ($AMBIGUOUS.Contains([char]$ch)) { $ch += 1 }
            }
            $out[$i] = [char]$ch
        }
        return [string]::new($out)
    }

    if ((generate $imei1) -eq $target1) {
        if ((generate $imei2) -eq $target2) {
            Write-Host "MATCH FOUND! a=$a, op1=$op1, op2=$op2, base=$base, initSeed=$initSeed, mult1=$mult1, mult2=$mult2"
            return $true
        }
    }
    return $false
}

Write-Host "Starting brute force..."
$count = 0
foreach ($initSeed in @(0, 1, 2, 0xffffff)) {
    foreach ($base in @(52, 62)) {
        foreach ($mult1 in @(0, 1, 2)) {
            foreach ($mult2 in @(0, 1, 2)) {
                foreach ($a in @(0, 1)) {
                    foreach ($op1 in @(0, 1, 2)) {
                        foreach ($op2 in @(0, 1, 2, 3)) {
                            testParams $a 0 0 $op1 $op2 $base $initSeed $mult1 $mult2
                            $count++
                        }
                    }
                }
            }
        }
    }
}
Write-Host "Finished $count tests."
