# BatUAV_app
An application for combining UAV telemetry and time stamped audio files (bat recordings)

# Running the app

Download a copy of this repository to your computer and in R navigate in to the project directory. Then run

```r
library(shiny)
library(devtools)

# Only run this line the first time
install_github(repo = 'AugustT/BatUAV')

library(BatUAV)
runApp()
```
