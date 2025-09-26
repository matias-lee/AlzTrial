
<!-- README.md is generated from README.Rmd. Please edit that file -->

# AlzTrial

<!-- badges: start -->

[![R-CMD-check](https://github.com/matias-lee/AlzTrial/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/matias-lee/AlzTrial/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/matias-lee/AlzTrial/graph/badge.svg)](https://app.codecov.io/gh/matias-lee/AlzTrial)
<!-- badges: end -->

The AlzTrial package provides a straightforward tool to plan the sample
size and budget for a two-endpoint clinical trial, modeled after a
hypothetical Alzheimer’s disease study. Given specific effect sizes,
standard deviations, and costs, the plan_alz_trial() function calculates
the required number of participants and the total estimated cost,
adhering to pre-set statistical power and error rates.

## Installation

You can install the development version of AlzTrial from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("matias-lee/AlzTrial")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(AlzTrial)
## basic example code
library(AlzTrial)

# Plan a trial with the specified parameters
my_plan <- plan_alz_trial(
  delta_cdr = 0.75,
  sd_cdr = 1.0,
  delta_hv = 2.0,
  sd_hv = 2.0,
  cost_baseline = 3000,
  cost_followup = 2000,
  cost_mri_per_scan = 5000
)

# Print the resulting plan
print(my_plan)
#> $inputs
#> $inputs$power
#> [1] 0.9
#> 
#> $inputs$fwer
#> [1] 0.05
#> 
#> $inputs$alpha_per_test
#> [1] 0.025
#> 
#> 
#> $sample_size
#> $sample_size$cdr_sb_required_n
#> [1] 90
#> 
#> $sample_size$hv_required_n
#> [1] 50
#> 
#> $sample_size$final_enrollment_n
#> [1] 90
#> 
#> $sample_size$mri_substudy_n
#> [1] 50
#> 
#> 
#> $cost_breakdown
#> $cost_breakdown$total_clinical_cost
#> [1] 450000
#> 
#> $cost_breakdown$total_mri_cost
#> [1] 5e+05
#> 
#> $cost_breakdown$total_trial_cost
#> [1] 950000
```
