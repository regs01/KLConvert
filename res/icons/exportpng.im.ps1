# MIT
# coth
# https://github.com/regs01

[String[]] $Filters = "Bartlett", "Blackman", "Bohman", "Box", "Catrom", "Cosine", "Cubic", "Gaussian", "Hamming", "Hann", "Hermite", "Jinc", "Kaiser", "Lagrange", "Lanczos", "Lanczos2", "Lanczos2Sharp", "LanczosRadius", "LanczosSharp", "Mitchell", "Parzen", "Point", "Quadratic", "Robidoux", "RobidouxSharp", "Sinc", "SincFast", "Spline", "CubicSpline", "Triangle", "Welch"
[Int[]] $Sizes100 = 16, 32, 64, 256
[Int[]] $Sizes150 = 24, 48
$SizesAll = $($Sizes100; $Sizes150)
$SizesAll = $SizesAll | Sort-Object -Descending
$DirectoryPNG = "./png"
$FilenameBases = "klconvert3.2-light", "klconvert3.2-grey", "klconvert3.2-dark", "klconvert3.2-dark2", "klconvert3.2-color"


if ( !(Test-Path -Path $DirectoryPNG) ) {
  mkdir "$DirectoryPNG"
}

function Make-Magick-PNG {
  param ( [int] $size, [String] $FilenameBase, [String] $InputFilename )

  $OutputFilename = "${DirectoryPNG}/${FilenameBase}-$size.png"
  Write-Host "Making $OutputFilename..."
  $Arguments = "-background none $InputFilename -filter Box -resize ${size}x${size} ${OutputFilename}"
  Start-Process "magick" -ArgumentList $Arguments -NoNewWindow -Wait

}

# foreach ($filter in $Filters) {

foreach ($FilenameBase in $FilenameBases) {

  $InputFilename = "${FilenameBase}-100.svg"
  foreach ($size in $Sizes100) {
    Make-Magick-PNG $size $FilenameBase $InputFilename
  }

  $InputFilename = "${FilenameBase}-150.svg"
  foreach ($size in $Sizes150) {
    Make-Magick-PNG $size $FilenameBase $InputFilename
  }

  $FilelistPNG = ""
  foreach ($size in $SizesAll) {
    $FilelistPNG += " ${DirectoryPNG}/${FilenameBase}-${size}.png"
  }
  $FilelistPNG = $FilelistPNG.Trim()
  $FilelistPNGArray = $FilelistPNG -split "\s+"
  $FilenameICO = "${FilenameBase}.ico"

  Write-Host "Making $FilenameICO..."
  $Arguments = $($FilelistPNGArray; "-compress"; "Zip"; "$FilenameICO")
  Start-Process "magick" -ArgumentList $Arguments -NoNewWindow -Wait

}

# }









