#' Plan an Alzheimer's Clinical Trial
#'
#' @description
#' Calculates required sample sizes and total cost for a two-endpoint
#' Alzheimer's trial based on user-defined clinical, cost, and statistical
#' parameters.
#'
#' @param delta_cdr The clinically meaningful difference to detect for the CDR-Sum of Boxes endpoint.
#' @param sd_cdr The standard deviation for the CDR-Sum of Boxes endpoint.
#' @param delta_hv The clinically meaningful difference to detect for the hippocampal volume endpoint (percent change).
#' @param sd_hv The standard deviation for the hippocampal volume endpoint.
#' @param cost_baseline The cost in USD for the baseline visit per participant.
#' @param cost_followup The cost in USD for the follow-up visit per participant.
#' @param cost_mri_per_scan The cost in USD for a single MRI scan.
#' @param power The desired statistical power, typically 0.80 or 0.90. Defaults to 0.90.
#' @param fwer The desired family-wise error rate, typically 0.05. Defaults to 0.05.
#' @param num_endpoints The number of primary/secondary endpoints being tested. Used for Bonferroni correction. Defaults to 2.
#'
#' @return A nested list containing three main elements:
#' \itemize{
#'   \item \strong{inputs}: A list of the core statistical parameters used in the calculation.
#'   \item \strong{sample_size}: A list detailing the required N for each endpoint, the final total enrollment, and the MRI substudy size.
#'   \item \strong{cost_breakdown}: A list detailing the total clinical, MRI, and overall trial costs.
#' }
#' #' @importFrom stats qnorm
#'
#' @export
#'
#' @examples
#' # Plan a trial using the parameters from the motivating example SAP
#' plan_alz_trial(
#'   delta_cdr = 0.75,
#'   sd_cdr = 1.0,
#'   delta_hv = 2.0,
#'   sd_hv = 2.0,
#'   cost_baseline = 3000,
#'   cost_followup = 2000,
#'   cost_mri_per_scan = 5000
#' )


plan_alz_trial <- function(
    # CDR-SB (Primary Endpoint) Parameters
  delta_cdr,
  sd_cdr,

  # Hippocampal Volume (Secondary Endpoint) Parameters
  delta_hv,
  sd_hv,

  # Cost Parameters
  cost_baseline,
  cost_followup,
  cost_mri_per_scan,

  # Statistical Parameters (with default values)
  power = 0.90,
  fwer = 0.05,
  num_endpoints = 2
) {

  ## NEW: Input validation block
  if (cost_baseline < 0 || cost_followup < 0 || cost_mri_per_scan < 0) {
    stop("All cost inputs must be non-negative values.")
  }

  ## STEP 1: Define a helper function to calculate sample size per arm
  calculate_n_per_arm <- function(power, alpha, sd, delta) {
    z_alpha <- qnorm(1 - alpha / 2)
    z_beta <- qnorm(power)
    n_per_arm <- 2 * ((z_alpha + z_beta) * sd / delta)^2
    return(ceiling(n_per_arm))
  }

  ## STEP 2: Set statistical constraints
  alpha_per_test <- fwer / num_endpoints

  ## STEP 3: Calculate total sample size for each endpoint
  n_cdr_total <- 2 * calculate_n_per_arm(power, alpha_per_test, sd_cdr, delta_cdr)
  n_hv_total <- 2 * calculate_n_per_arm(power, alpha_per_test, sd_hv, delta_hv)

  ## STEP 4: Determine the final study size
  N_total_enrollment <- max(n_cdr_total, n_hv_total)
  M_total_mri <- n_hv_total

  ## STEP 5: Calculate the total trial cost
  cost_clinical_per_subject <- cost_baseline + cost_followup
  total_clinical_cost <- N_total_enrollment * cost_clinical_per_subject
  total_mri_cost <- M_total_mri * 2 * cost_mri_per_scan
  total_trial_cost <- total_clinical_cost + total_mri_cost

  ## STEP 6: Assemble and return the results in a structured list
  results <- list(
    inputs = list(
      power = power,
      fwer = fwer,
      alpha_per_test = alpha_per_test
    ),
    sample_size = list(
      cdr_sb_required_n = n_cdr_total,
      hv_required_n = n_hv_total,
      final_enrollment_n = N_total_enrollment,
      mri_substudy_n = M_total_mri
    ),
    cost_breakdown = list(
      total_clinical_cost = total_clinical_cost,
      total_mri_cost = total_mri_cost,
      total_trial_cost = total_trial_cost
    )
  )

  return(results)
}
