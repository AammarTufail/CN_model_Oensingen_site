# Load packages without warnings and messages
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(patchwork)
  library(cowplot)
  library(visdat)
  library(here)
  library(lubridate)
  library(readr)
  library(naniar)
  library(purrr)
})

# install CN-model
devtools::install_github(
  "stineb/rsofun@v1.0_cnmodel",
  ref = "cnmodel",
  upgrade = "never",
  force = TRUE
)
library(rsofun)

# load drivers data
drivers <- readRDS(here::here("data/CH-Oe2_2004-2023_final_ready_for_CNmodel_run_19082025.rds"))
colnames(drivers$forcing[[1]])
str(drivers$forcing[[1]])

# check drivers consistency with FluxDataKit
# drivers_fdk <- read_rds("data/FLX_CH-Oe2_FLUXNET2015_FULLSET_2004-2023_1-3/rsofun_driver_data_v3.4.2.rds") # muhammad's
drivers_fdk <- read_rds("~/data_2/FluxDataKit/v3.4/zenodo_upload/rsofun_driver_data_v3.4.2.rds") # beni's

drivers_fdk <- drivers_fdk |> 
  filter(sitename == "CH-Oe2") 

tmp <- filter(drivers_fdk, sitename == "CH-Oe2")$forcing[[1]] |> 
  right_join(
    filter(drivers, sitename == "CH-Oe2")$forcing[[1]],
    by = join_by(date),
    suffix = c("_fdk", "_muh")
    )

# temperature: correct units, but inconsistent values - not our problem...
# xxx beni: note that in rsofun_driver_data_v3.4.2.rds, 'temp' is daytime temperature.
tmp |> 
  ggplot(aes(temp_fdk, temp_muh)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dotted")

# vpd: ok, but quite large differences
tmp |> 
  ggplot(aes(vpd_fdk, vpd_muh)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dotted")

# ppfd: looks good
tmp |> 
  ggplot(aes(ppfd_fdk, ppfd_muh)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dotted")

# fapar: quite some differences but acceptable
tmp |> 
  ggplot(aes(fapar_fdk, fapar_muh)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dotted")

tmp |> 
  ggplot() +
  geom_line(aes(date, fapar_muh), color = "red") +
  geom_line(aes(date, fapar_fdk)) +
  xlim(as.Date("2004-01-01"), as.Date("2008-01-01"))

# Check date range and completeness of forcing data
forcing_data <- drivers$forcing[[1]]
date_range <- range(forcing_data$date)
cat("Date range:", as.character(date_range[1]), "to", as.character(date_range[2]), "\n")

# Check if years are complete
years_in_data <- year(forcing_data$date)
unique_years <- unique(years_in_data)
cat("Years in data:", paste(unique_years, collapse = ", "), "\n")

# Check completeness of each year
year_completeness <- forcing_data %>%
  mutate(year = year(date)) %>%
  group_by(year) %>%
  summarise(
    n_days = n(),
    start_date = min(date),
    end_date = max(date),
    is_leap = leap_year(year[1]),
    expected_days = ifelse(is_leap, 366, 365),
    complete = n_days == expected_days,
    .groups = 'drop'
  )

print(year_completeness)

# Identify incomplete years
incomplete_years <- year_completeness$year[!year_completeness$complete]
if(length(incomplete_years) > 0) {
  cat("Incomplete years found:", paste(incomplete_years, collapse = ", "), "\n")
} else {
  cat("All years are complete\n")
}

# xxx beni: incompleteness because 29 Februar values of leap years are dropped 
# from forcing. They are omitted anyways within rsofun as the model works with 
# fixed 365-day years. Hence, don't worry about incompleteness.

# check the data patterns in the forcing data
vis_dat(drivers$forcing[[1]], warn_large_data = TRUE)

# Plot all columns in the forcing data with different colors
plot_forcing <- drivers$forcing[[1]] %>%
  select(date, everything()) %>%
  pivot_longer(cols = -date, names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = date, y = value, color = variable)) +
  # highlight the area from 2021 to 2023
  geom_rect(aes(xmin = as.Date("2021-01-01"), xmax = as.Date("2023-12-31"), ymin = -Inf, ymax = Inf), 
            fill = "#bde2ef", alpha = 0.2, color = NA) +
  geom_line(linewidth = 0.3) +
  facet_wrap(~variable, scales = "free_y", ncol = 3) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 years") +
  scale_color_viridis_d() +  # Use viridis color palette for different colors
  labs(title = "Forcing Data Variables Over Time",
       x = "Year",
       y = "Value") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.text = element_text(size = 8),
        panel.grid.minor = element_blank(),
        legend.position = "none")  # Hide legend since colors are redundant with facets

# Save the plot
ggsave(here::here("fig/forcing_data_variables.pdf"), plot_forcing, width = 20, height = 10, dpi = 300, bg = "white")
plot_forcing

# Check for missing values in the drivers object in forcing data
### check for missing values in the data----------------
miss_plot <- drivers |>
  select(sitename, forcing) |>
  unnest(forcing) |>
  vis_miss(warn_large_data = FALSE)

ggsave(here::here("fig/01_vis_miss_drivers.pdf"), miss_plot, width = 10, height = 6)
miss_plot

## Run CNmodel
# Define model parameters taken from p model script and other scripts
pars <- list(
  # Paramteres taken from P-model
  kphio = 0.045,             # setup ORG in Stocker et al. 2020 GMD  #typical ranges: 0.04-0.1 #lma / fapar / gpp / leaf c / cturnover / Vcmax 
  kphio_par_a = 0.0,        # set to zero to disable temperature-dependence of kphio
  kphio_par_b = 1.0,
  soilm_thetastar = 0.6 * 240,  # to recover old setup with soil moisture stress
  soilm_betao = 0.0,
  beta_unitcostratio = 146.0,
  rd_to_vcmax = 0.014,      # value from Atkin et al. 2015 for C3 herbaceous # cturnover / Vcmax
  tau_acclim = 30.0,
  kc_jmax = 0.41,
  
  # Plant
  f_nretain = 0.500000, #0.5 # cturnover
  fpc_tree_max = 0.8000000, #typical range: 0.8-0.95. #fapar / c leaf
  growtheff = 0.6000000, #0.45  #typical range: 0.3-0.7 #lma / c leaf / cturnover
  r_root = 2*0.913000,
  r_sapw = 2*0.044000,
  exurate = 0.003000,
  
  k_decay_leaf = 1.90000, #1.90000, #typical range: 0.5 - 2.0 # cleaf / cturnover
  k_decay_root = 1.90000, # cturnover
  k_decay_labl = 1.90000, #1.90000, #typical range: 0.5 - 2.0 # cleaf / cturnover
  k_decay_sapw = 1.90000, # cturnover
  
  r_cton_root = 37.0000, # cturnover
  r_cton_wood = 100.000, # cturnover
  r_cton_seed = 15.0000, # cturnover
  nv_vcmax25 = 5000, #0.02 * 13681.77, # see ln_cn_review/vignettes/analysis_leafn_vcmax_field.Rmd, l.695; previously: 5000.0, #lma / Vcmax
  ncw_min = 0.056, #0.08 * 1.116222, # see ln_cn_review/vignettes/analysis_leafn_vcmax_field.Rmd, l.691; previously used: 0.056, #lma
  r_n_cw_v = 0.05, #0.1, # assumed that LMA is independent of Vcmax25; previously: 0.1, #lma /Vcmax #typical range: 0.05-0.2 
  r_ctostructn_leaf = 30.0000, #1.3 * 45.84125, # see ln_cn_review/vignettes/analysis_leafn_vcmax_field.Rmd, l.699; previously used: 80.0000, #typical range: 40-80 #lma / fapar / cleaf 
  kbeer = 0.350000, #0.400000 #fapar #typical range: 0.3-0.8
  
  # Phenology (should be PFT-specific)
  gddbase = 5.0, #typical range: 5-10 #c leaf 
  ramp = 0.0,
  phentype = 2.0,
  
  # Soil physics (should be derived from params_soil, fsand, fclay, forg, fgravel)
  perc_k1 = 5.0,
  thdiff_wp = 0.2,
  thdiff_whc15 = 0.8,
  thdiff_fc = 0.4,
  forg = 0.01,
  wbwp = 0.029,
  por = 0.421,
  fsand = 0.82,
  fclay = 0.06,
  fsilt = 0.12,
  
  # Water and energy balance
  kA = 107,
  kalb_sw = 0.17,
  kalb_vis = 0.03,
  kb = 0.20,
  kc = 0.25,
  kCw = 1.05,
  kd = 0.50,
  ke = 0.0167,
  keps = 23.44,
  kWm = 220.0,
  kw = 0.26,
  komega = 283.0,
  maxmeltrate = 3.0,
  
  # Soil BGC
  klitt_af10 = 1.2,
  klitt_as10 = 0.35,
  klitt_bg10 = 0.35,
  kexu10 = 50.0,
  ksoil_fs10 = 0.021,
  ksoil_sl10 = 7.0e-04,
  ntoc_crit1 = 0.45,
  ntoc_crit2 = 0.76,
  cton_microb = 10.0,
  cton_soil = 9.77,
  fastfrac = 0.985,
  
  # N uptake
  eff_nup = 0.0001000,
  minimumcostfix = 1.000000,
  fixoptimum = 25.15000,
  a_param_fix = -3.62000,
  b_param_fix = 0.270000,
  
  # Inorganic N transformations (re-interpreted for simple ntransform model)
  maxnitr =  0.00005,
  
  # Inorganic N transformations for full ntransform model (not used in simple model)
  non = 0.01,
  n2on = 0.0005,
  kn = 83.0,
  kdoc = 17.0,
  docmax = 1.0,
  dnitr2n2o = 0.01,
  
  # Additional parameters - previously forgotten
  frac_leaf = 0.4,         # after wood allocation  #typical range: 0.4-0.8 #lma / fapar / c leaf / cturnover
  frac_wood = 0,           # highest priority in allocation  #typical range: 0-0.6 #lma / cleaf 
  frac_avl_labl = 0.1, #0.1   #typical range: 0.1-0.3 # c leaf 
  
  # for development
  tmppar = 9999,
  
  # simple N uptake module parameters
  nuptake_kc = 600,
  nuptake_kv = 5,
  nuptake_vmax = 0.3 #0.3 #typical range: 0.1-0.3 # cleaf / cturnover
)

# make dir
if (!dir.exists(here::here("output"))) {
  dir.create(here::here("output"))
}
if (!dir.exists(here::here("out"))) {
  dir.create(here::here("out"))
}

# Function to run the model and save the output
cnmodel_run_save <- function(drivers, pars, save_path, file_basename) {
  output_04_23 <- runread_cnmodel_f(drivers = drivers, 
                                    par = pars,
                                    ncores = 12,
                                    makecheck = FALSE,  # Set to FALSE to avoid strict checks
                                    parallel = FALSE
  )
  rds_filename <- paste0(file_basename, ".rds")
  if (!dir.exists(save_path)) {
    stop("Directory does not exist: ", save_path)
  }
  saveRDS(output_04_23, file = file.path(save_path, rds_filename))
  message("Model output saved: ", file.path(save_path, rds_filename))
  invisible(output_04_23)
}
# Example usage:
# Run the model with filtered data (complete years only)
cnmodel_run_save(drivers, pars, here::here("output"), "output_04_23")

# Read the output
output_04_23 <- readRDS(here::here("output/output_04_23.rds"))

# plot output results
# Plot GPP over time
plot_gpp <- ggplot(output_04_23$data[[1]], aes(x = date, y = gpp)) +
  geom_line(color = "#03191b") +
  labs(title = "GPP Over Time",
       x = "Date",
       y = expression(paste("GPP (gC m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the GPP plot
ggsave(here::here("output/gpp_plot.pdf"), plot_gpp, width = 14, height = 4, dpi = 300, bg = "white")
plot_gpp

# Plot NPP over time
plot_npp <- ggplot(output_04_23$data[[1]], aes(x = date, y = npp)) +
  geom_line(color = "#03191b") +
  labs(title = "NPP Over Time",
       x = "Date",
       y = expression(paste("NPP (gC m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the NPP plot
ggsave(here::here("output/npp_plot.pdf"), plot_npp, width = 14, height = 4, dpi = 300, bg = "white")
plot_npp


# Plot EN2O over time
plot_en2o <- ggplot(output_04_23$data[[1]], aes(x = date, y = en2o)) +
  geom_line(color = "#03191b") +
  labs(title = "EN2O Over Time",
       x = "Date",
       y = expression(paste("EN2O (gN m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the EN2O plot
ggsave(here::here("output/en2o_plot.pdf"), plot_en2o, width = 14, height = 4, dpi = 300, bg = "white")
plot_en2o

# Plot ENLeach over time
plot_enleach <- ggplot(output_04_23$data[[1]], aes(x = date, y = enleach)) +
  geom_line(color = "#03191b") +
  labs(title = "ENLeach Over Time",
       x = "Date",
       y = expression(paste("ENLeach (gN m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the ENLeach plot
ggsave(here::here("output/enleach_plot.pdf"), plot_enleach, width = 14, height = 4, dpi = 300, bg = "white")
plot_enleach

# Plot NPP over time
plot_npp <- ggplot(output_04_23$data[[1]], aes(x = date, y = npp)) +
  geom_line(color = "#03191b") +
  labs(title = "NPP Over Time",
       x = "Date",
       y = expression(paste("NPP (gC m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the NPP plot
ggsave(here::here("output/npp_plot.pdf"), plot_npp, width = 14, height = 4, dpi = 300, bg = "white")
plot_npp

# Plot NUP over time
plot_nup <- ggplot(output_04_23$data[[1]], aes(x = date, y = nup)) +
  geom_line(color = "#03191b") +
  labs(title = "NUP Over Time",
       x = "Date",
       y = expression(paste("NUP (gN m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the NUP plot
ggsave(here::here("output/nup_plot.pdf"), plot_nup, width = 14, height = 4, dpi = 300, bg = "white")
plot_nup

# Plot NLOSS over time
plot_nloss <- ggplot(output_04_23$data[[1]], aes(x = date, y = nloss)) +
  geom_line(color = "#03191b") +
  labs(title = "NLOSS Over Time",
       x = "Date",
       y = expression(paste("NLOSS (gN m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the NLOSS plot
ggsave(here::here("output/nloss_plot.pdf"), plot_nloss, width = 14, height = 4, dpi = 300, bg = "white")
plot_nloss

# Plot NLABL over time
plot_nlabl <- ggplot(output_04_23$data[[1]], aes(x = date, y = nlabl)) +
  geom_line(color = "#03191b") +
  labs(title = "NLABL Over Time",
       x = "Date",
       y = expression(paste("NLABL (gN m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the NLABL plot
ggsave(here::here("output/nlabl_plot.pdf"), plot_nlabl, width = 14, height = 4, dpi = 300, bg = "white")
plot_nlabl

# Plot NLEAF over time
plot_nleaf <- ggplot(output_04_23$data[[1]], aes(x = date, y = nleaf)) +
  geom_line(color = "#03191b") +
  labs(title = "NLEAF Over Time",
       x = "Date",
       y = expression(paste("NLEAF (gN m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the NLEAF plot
ggsave(here::here("output/nleaf_plot.pdf"), plot_nleaf, width = 14, height = 4, dpi = 300, bg = "white")
plot_nleaf

# Plot NROOT over time
plot_nroot <- ggplot(output_04_23$data[[1]], aes(x = date, y = nroot)) +
  geom_line(color = "#03191b") +
  labs(title = "NROOT Over Time",
       x = "Date",
       y = expression(paste("NROOT (gN m"^-2, " day"^-1, ")"))) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line())

# Save the NROOT plot
ggsave(here::here("output/nroot_plot.pdf"), plot_nroot, width = 14, height = 4, dpi = 300, bg = "white")
plot_nroot

# Combine all plots into a single figure
combined_plot <- (plot_en2o + plot_enleach + plot_npp + plot_nup) /
  (plot_nloss + plot_nlabl + plot_nleaf + plot_nroot) +
  plot_layout(ncol = 1) +
  plot_annotation(title = "Model Outputs Over Time",
                  subtitle = "EN2O, ENLeach, NPP, NUP, NLOSS, NLABL, NLEAF, NROOT",
                  caption = "Data from CN model run") &
  theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 14),
        plot.caption = element_text(hjust = 0.5, size = 10))

# Save the combined plot
ggsave(here::here("output/combined_model_outputs.pdf"), combined_plot, width = 16, height = 12, dpi = 300, bg = "white")
combined_plot


