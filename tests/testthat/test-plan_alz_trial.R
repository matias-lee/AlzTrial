# This line is a special comment that testthat uses.
# It tells testthat that this file contains tests for plan_alz_trial.R.
test_that("calculations match the original SAP scenario", {
  # Run the function with the known inputs from your SAP
  plan <- plan_alz_trial(
    delta_cdr = 0.75, sd_cdr = 1.0,
    delta_hv = 2.0, sd_hv = 2.0,
    cost_baseline = 3000, cost_followup = 2000, cost_mri_per_scan = 5000
  )

  # Use expect_equal() to check if the output is what we expect
  expect_equal(plan$sample_size$cdr_sb_required_n, 90)
  expect_equal(plan$sample_size$hv_required_n, 50)
  expect_equal(plan$sample_size$final_enrollment_n, 90) # max(90, 50)
  expect_equal(plan$cost_breakdown$total_trial_cost, 950000)
})


test_that("cost and N logic is correct when HV requires more subjects", {
  # Create a new scenario where the CDR-SB is easier to detect (needs fewer people)
  plan <- plan_alz_trial(
    delta_cdr = 1.5, sd_cdr = 1.0, # Made delta_cdr larger
    delta_hv = 2.0, sd_hv = 2.0,
    cost_baseline = 3000, cost_followup = 2000, cost_mri_per_scan = 5000
  )

  # Check the new expected outputs
  expect_equal(plan$sample_size$cdr_sb_required_n, 24)
  expect_equal(plan$sample_size$hv_required_n, 50)
  expect_equal(plan$sample_size$final_enrollment_n, 50) # max(24, 50) should now be 50

  # Recalculate the expected cost for this new scenario
  # Cost = (50 * 5000) + (50 * 2 * 5000) = 250000 + 500000 = 750000
  expect_equal(plan$cost_breakdown$total_trial_cost, 750000)
})

test_that("N logic is correct when delta_hv is smaller (harder to detect)", {
  # Making delta_hv smaller should increase the required N for that endpoint
  plan <- plan_alz_trial(
    delta_cdr = 0.75, sd_cdr = 1.0,
    delta_hv = 1.5, sd_hv = 2.0, # delta_hv is now 1.5 instead of 2.0
    cost_baseline = 3000, cost_followup = 2000, cost_mri_per_scan = 5000
  )

  # N for CDR-SB is still 90, but N for HV is now 88
  expect_equal(plan$sample_size$cdr_sb_required_n, 90)
  expect_equal(plan$sample_size$hv_required_n, 90)
  # Final enrollment is still driven by the CDR-SB endpoint
  expect_equal(plan$sample_size$final_enrollment_n, 90)
})

test_that("cost calculation updates correctly with new costs", {
  # Use original SAP inputs but double the MRI cost
  plan <- plan_alz_trial(
    delta_cdr = 0.75, sd_cdr = 1.0,
    delta_hv = 2.0, sd_hv = 2.0,
    cost_baseline = 3000, cost_followup = 2000,
    cost_mri_per_scan = 10000 # MRI cost is now $10,000
  )

  # Sample sizes should be unchanged
  expect_equal(plan$sample_size$final_enrollment_n, 90)
  expect_equal(plan$sample_size$mri_substudy_n, 50)

  # Check that the final cost reflects the new MRI price
  # New Cost = (90 * 5000) + (50 * 2 * 10000) = 450000 + 1000000 = 1450000
  expect_equal(plan$cost_breakdown$total_trial_cost, 1450000)
})

test_that("function stops with an error for negative costs", {
  # expect_error() checks that your function correctly throws an error
  # The second argument checks that the error message contains this specific text
  expect_error(
    plan_alz_trial(
      delta_cdr = 0.75, sd_cdr = 1.0,
      delta_hv = 2.0, sd_hv = 2.0,
      cost_baseline = -100, # Invalid negative cost
      cost_followup = 2000,
      cost_mri_per_scan = 5000
    ),
    "All cost inputs must be non-negative"
  )
})
