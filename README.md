# Controls for non-independence should reflect the data-generating process

## Getting Started

### Installing

To run this code, you will need to install [R v4.4.2](https://www.r-project.org/)
and the following R packages:

```r
install.packages(c("crew", "brms", "Matrix", "rstan", "targets",
                   "tarchetypes", "tidyverse"))
```

This installation should take no longer than a few minutes on a standard laptop.
For information on all necessary package versions, see `sessionInfo.txt`. This
code has been tested on Windows 11 Enterprise 24H2 (64-bit).

### Demo

To run a small demo of this code:

1. Set the working directory to this code repository on your local machine
2. Load the `targets` package with `library(targets)`
3. Run `tar_make(cors)`

This demo should take no longer than one minute to run on a standard laptop. The
demo will load the data and calculate the correlation matrix between all
proximity matrices. The correlation matrix can then be viewed with
`tar_read(cors)`.

### Instructions for use

To run the pipeline in full and reproduce the manuscript:

1. Set the working directory to this code repository on your local machine
2. Load the `targets` package with `library(targets)`
3. Run the full pipeline with `tar_make()`

The full pipeline will take around 14 hours if run in series. This runtime can
be sped up by modifying the `_targets.R` file to run the pipeline in parallel
across multiple cores (see [here](https://books.ropensci.org/targets/crew.html)
for more information).

## Help

Any issues, please email scott.claessens@gmail.com.

## Authors

Scott Claessens, scott.claessens@gmail.com
