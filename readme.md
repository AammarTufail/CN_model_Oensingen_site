# CN-Model Data preparation for 2004-2023 Oensingen Site, Switzerland

## Site information
- **Site Name**: Oensingen
- **Site Description**: This site was part of the CarboEuropeIP project (EU FP6) and the GHG-Europe project (EU FP7). Eddy covariance flux measurements started in December 2003. The soil type is an eutri-stagnic cambisol. The site is located at 452 m and is managed as a typical intensive crop rotation under the Swiss Integrated Pest Management regime (IP Suisse). The tower coordinates are: `47°17’11.1″` N and `7°44’01.5″` E; WGS84 `47.286417`, `7.73375`. During the CarboEuropeIP project, colleagues from Agroscope operated the Oensingen Grassland site nearby.
- **Site Location**: 
  - Altitude: 452 m a.s.l.
  - Site name: Oensingen, Canton of Solothurn, Switzerland
  - Land cover (IGBP land classification): Cropland
  - Land use: Typical intensive crop rotation under the Swiss Integrated Pest Management regime (IP Suisse).
  - Coordinates: 47°17’11.1″ N / 7°44’01.5″ E (47.286417, 7.733750) ([Google Maps](https://www.google.com/maps/place/47%C2%B017'11.1%22N+7%C2%B044'01.5%22E/@47.285881,7.7317792,1101m/data=!3m1!1e3!4m5!3m4!1s0x0:0x0!8m2!3d47.2864167!4d7.73375))
  - Location description: Oensingen is located at the southern edge of the bottom of the Jura Mountains.
  - FLUXNET ID: CH-Oe2 ([link](https://fluxnet.org/sites/siteinfo/CH-Oe2))

All related site information can be found in the [Swiss Fluxnet Site](https://www.swissfluxnet.ethz.ch/index.php/sites/site-info-ch-oe2/#Site_Description).

## Data Download

> Data was downloaded from the [Fluxnet Archive Product from Oensingen crop 2004–2023](https://meta.icos-cp.eu/objects/39gLjDLg85pGQzLxDnzjtRU1) and is available in the [data](./data/FLX_CH-Oe2_FLUXNET2015_FULLSET_2004-2023_1-3/) folder of this repository.
- **Data Type**: Eddy covariance flux measurements
- **Data Period**: 2004–2023
- **Data Source**: [Fluxnet Archive Product from Oensingen crop 2004–2023](https://meta.icos-cp.eu/objects/39gLjDLg85pGQzLxDnzjtRU1)
- **Citation:** Buchmann, N., Hortnagl, L., Keller, S., Turco, F. (2024). Fluxnet Archive Product from Oensingen crop, 2004–2023, Miscellaneous, https://hdl.handle.net/11676/39gLjDLg85pGQzLxDnzjtRU1

> The dataset contain the following naming convention:
- [`FLX_CH-Oe2_FLUXNET2015_FULLSET_HH_2004-2023_1-3.csv`](./data/FLX_CH-Oe2_FLUXNET2015_FULLSET_2004-2023_1-3/FLX_CH-Oe2_FLUXNET2015_FULLSET_HH_2004-2023_1-3.csv): Full dataset with all available variables measured at the Oensingen site after every half hour.
- [`FLX_CH-Oe2_FLUXNET2015_FULLSET_DD_2004-2023_1-3.csv`](./data/FLX_CH-Oe2_FLUXNET2015_FULLSET_2004-2023_1-3/FLX_CH-Oe2_FLUXNET2015_FULLSET_DD_2004-2023_1-3.csv): Full dataset with all available variables measured at the Oensingen site after every day.
- [`FLX_CH-Oe2_FLUXNET2015_FULLSET_WW_2004-2023_1-3.csv`](./data/FLX_CH-Oe2_FLUXNET2015_FULLSET_2004-2023_1-3/FLX_CH-Oe2_FLUXNET2015_FULLSET_WW_2004-2023_1-3.csv): Full dataset with all available variables measured at the Oensingen site after every week.
- [`FLX_CH-Oe2_FLUXNET2015_FULLSET_MM_2004-2023_1-3.csv`](./data/FLX_CH-Oe2_FLUXNET2015_FULLSET_2004-2023_1-3/FLX_CH-Oe2_FLUXNET2015_FULLSET_MM_2004-2023_1-3.csv): Full dataset with all available variables measured at the Oensingen site after every month.
- [`FLX_CH-Oe2_FLUXNET2015_FULLSET_YY_2004-2023_1-3.csv`](./data/FLX_CH-Oe2_FLUXNET2015_FULLSET_2004-2023_1-3/FLX_CH-Oe2_FLUXNET2015_FULLSET_YY_2004-2023_1-3.csv): Full dataset with all available variables measured at the Oensingen site after every year.
- Variable Abbreviations can be found in this file: [`Variable Abbreviations.csv`](./data/FLX_CH-Oe2_FLUXNET2015_FULLSET_2004-2023_1-3/Variable%20Abbreviations.csv).

## Installation of R, R studio and R packages

- R can be installed from [R Cran website](https://cran.r-project.org/).
- Rstudio can be downloaded and installed from this website: [RStudio Download](https://posit.co/download/rstudio-desktop/).

After installing R and Rstudio, please install the following software:
- gfortran (GNU Fortran Compiler) is required for the `rsofun` package. It can be installed from [Rtools](https://cran.r-project.org/bin/windows/Rtools/) for Windows or using the package manager for Linux and MacOS.
- Read this for MacOS installation: [Installing Rtools on MacOS](https://mac.r-project.org/tools/).
- For Macbook install gfortran using [gfortran](https://github.com/fxcoudert/gfortran-for-macOS/releases).
- Install gcc (GNU Compiler Collection) using Homebrew on MacOS:
```bash
brew install gcc
```
- Also install X-code in Macbook as follows:
```bash
sudo xcode-select --install
```

<details>
<summary><span style="color:rgb(42, 226, 42); font-size: 1.1em;">important information to install on macbook.</span></summary>

# Installation

Since the standard solution didn’t work, let’s systematically debug and solve the issue step-by-step. The problem arises specifically because R on ARM-based Macs (like your M4 MacBook) needs explicit paths to the Fortran compiler libraries.

⸻

✅ Step 1: Confirm paths

Run the following commands in your Mac terminal to confirm paths:

which gfortran
gfortran --version
brew --prefix gcc

This should output something like:

/opt/homebrew/bin/gfortran
GNU Fortran (Homebrew GCC 14.2.0) 14.2.0
...
/opt/homebrew/opt/gcc

Make sure you see these outputs correctly.

⸻

✅ Step 2: Verify Fortran libraries location

Check if your gfortran libraries are properly installed and accessible:

ls /opt/homebrew/lib/gcc/current

You should see files such as:

libgfortran.dylib libquadmath.dylib libgcc_s.dylib

If you see these, your Fortran libraries are correctly installed.

⸻

✅ Step 3: Explicitly Configure R for compilation

Now, explicitly configure R to use the correct paths. Open Terminal and run:

mkdir -p ~/.R
nano ~/.R/Makevars

Insert exactly this (replace the path if different):

FC=/usr/local/bin/gfortran
FLIBS=-L/opt/homebrew/lib/gcc/current -lgfortran -lquadmath -lm
F77=/usr/local/bin/gfortran

Save (Ctrl+O then Enter, then Ctrl+X to exit).

⸻

✅ Step 4: Adjust PATH for R environment

In RStudio (or R console), before installing, explicitly set the library path environment variables directly in R session:

Sys.setenv(PATH = paste("/usr/local/bin/gfortran", Sys.getenv("PATH"), sep=":"))
Sys.setenv(FC = "/usr/local/bin/gfortran")
Sys.setenv(FLIBS = "-L/opt/homebrew/lib/gcc/current -lgfortran -lquadmath -lm")



⸻

✅ Step 5: Install package with modified settings

Now, run again in your R session:

remotes::install_github("stineb/rsofun")

This explicitly instructs R exactly where your Fortran libraries are, overcoming the linking issue.

⸻

✅ Step 6 (If STILL facing issues): Link libraries manually (rarely needed)

If the above still fails, manually create symbolic links:

sudo mkdir -p /opt/gfortran/lib
sudo ln -s /opt/homebrew/lib/gcc/current/libgfortran.dylib /opt/gfortran/lib/
sudo ln -s /opt/homebrew/lib/gcc/current/libquadmath.dylib /opt/gfortran/lib/

This addresses your original error message:

ld: library 'gfortran' not found



⸻

✅ Finally: Verify successful installation

After installation, test loading the library:

library(rsofun)



⸻

🚩 Summary of what’s causing the error:
	•	Your ARM-based M-series MacBook expects gfortran libraries in a specific location (/opt/gfortran/lib/...). However, Homebrew installs them in /opt/homebrew/....
	•	Explicitly specifying compiler (FC) and linker flags (FLIBS) in .R/Makevars or via environment variables tells R exactly where to find these libraries.

Following the above steps carefully will solve your issue.

</details>


After that, here is the [installation script](./scripts/00_installation.R).

<details>
<summary><span style="color:rgb(42, 226, 42); font-size: 1.1em;">Click to expand R code for installation of required packages.</span></summary>

```r
# required libraries 
install.packages(c("dplyr", "tidyr", "ggplot2", "patchwork", "cowplot", "visdat", 
                   "here", "lubridate", "readr", "naniar", "purrr", "remotes"))
remotes::install_github("stineb/rsofun", ref = "cnmodel_ntransform_full", force = TRUE, clean = TRUE)
```

</details>


## Data preparation

- Before preparing data, here is the example drivers data file that you need to prepare for the CN-Model. 
- The CN-Model requires specific variables in a structured format. 
- Here is how you can get the information about forcing data:

```r
# this command will give you the information about the forcing data and validation data variables required for the CN-Model:
?rsofun::p_model_drivers
?rsofun::p_model_validation

# these commands will give you exact datasets and how it looked like:
rsofun::p_model_drivers
rsofun::p_model_validation
```

Below is the description of the required variables and their types.

We need to prepare following data for the CN-Model:
| Variable      | Type                       | Description                                                                                   |
|---------------|----------------------------|-----------------------------------------------------------------------------------------------|
| **sitename**   | character string           | CH-Oe2 (Name of the site)                                                                     |
| **forcing**       | **tibble**                     | **Daily Time series of forcing climate data including variables** below                                 |
| date          | Date (YYYY-MM-DD)          | Date of the observation                                                                       |
| temp          | numeric (°C)               | Daytime average air temperature                                                               |
| vpd           | numeric (Pa)               | Daytime average vapour pressure deficit                                                       |
| ppfd          | numeric (mol m⁻² s⁻¹)      | Photosynthetic photon flux density; if all NA, calculated by SPLASH model                     |
| netrad        | numeric (W m⁻²)            | Net radiation; if all NA, calculated by SPLASH model                                          |
| patm          | numeric (Pa)               | Atmospheric pressure                                                                          |
| snow          | numeric (mm s⁻¹)           | Snow in water equivalents                                                                     |
| rain          | numeric (mm s⁻¹)           | Rain as precipitation in liquid form                                                          |
| tmin          | numeric (°C)               | Daily minimum air temperature                                                                 |
| tmax          | numeric (°C)               | Daily maximum air temperature                                                                 |
| fapar         | numeric (0-1)              | Fraction of photosynthetic active radiation                                                   |
| co2           | numeric                    | Atmospheric CO₂ concentration                                                                 |
| ccov          | numeric (%)                | Cloud coverage; used when PPFD or net radiation not prescribed                                |
| **params_siml**   | **tibble**                     | **Simulation parameters**                                                                         |
| spinup        | logical                    | Indicates whether this simulation does spin-up                                                |
| spinupyears   | integer                    | Number of spin-up years                                                                       |
| recycle       | integer (days)             | Length of standard recycling period                                                           |
| outdt         | integer                    | Output periodicity                                                                            |
| ltre          | logical                    | TRUE if evergreen tree                                                                        |
| ltne          | logical                    | TRUE if evergreen tree and N-fixing                                                           |
| ltrd          | logical                    | TRUE if deciduous tree                                                                        |
| ltnd          | logical                    | TRUE if deciduous tree and N-fixing                                                           |
| lgr3          | logical                    | TRUE if grass with C3 photosynthetic pathway                                                  |
| lgn3          | logical                    | TRUE if grass with C3 photosynthetic pathway and N-fixing                                     |
| lgr4          | logical                    | TRUE if grass with C4 photosynthetic pathway                                                  |
| **site_info**     | **tibble**                     | **Site meta information**                                                                         |
| lon           | numeric (degrees east)     | Longitude of the site location                                                                |
| lat           | numeric (degrees north)    | Latitude of the site location                                                                 |
| elv           | numeric (m)                | Elevation of the site location                                                                |
| whc           | numeric (mm)               | Rooting zone water holding capacity                                                           |


### Forcing data preparation

The forcing data is prepared from the original dataset by extracting the relevant variables based on the daily measurement file or the half-hourly measurement file. The data is then aggregated to daily values in case of the half-hourly measurement file. 

> We will be using the half-hourly measurement file for the temperature data preparation.

#### temp, tmin and tmax

The temperature data is prepared by extracting the relevant variables from the half-hourly measurement file. 
- `TA_F` is used which is `Air temperature, consolidated from TA_F_MDS and TA_ERA. TA_F_MDS used if TA_F_MDS_QC is 0 or 1, otherwise TA_ERA is used.`
The data is then aggregated to daily values by taking the mean of the half-hourly values for `temp`, and the minimum and maximum values for `tmin` and `tmax`.

Here is the [script](./scripts/01_temp_tmin_tmax.R) to prepare the temperature data.

#### vpd

`vpd` (Daytime average Vapour Pressure Deficit) can be extracted using this [script](./scripts/02_vpd.R).

#### ppfd

- ICOS data contains ppfd as `PPFD_IN, PPFD_IN_QC, PPFD_DIF, PPFD_DIF_QC`, however, the the values are not consistent and have many missing or anomalous values as extracted by this [script](./scripts/03a_ppfd.ipynb).
- We will calculate the `ppfd` using the [SPLASH model](https://pyrealm.readthedocs.io/en/latest/users/splash.html#), which is a part of the `pyrealm` package. The SPLASH model will calculate the photosynthetic photon flux density (PPFD) based on the available variables and site information, we will use `SW_IN_F` shortwave radiation data in order to get accurate values. Here is the [script](./scripts/03b_ppfd_SPLASH.ipynb) to prepare the ppfd data.

1. First create a conda environment with the required packages:
```bash
conda create -n pyrealm_env python=3.11 -y
conda activate pyrealm_env
pip install pyrealm pandas matplotlib seaborn
#if using jupyter notebook, install the kernel
pip install ipykernel
```

2. Then run the [script](./scripts/03b_ppfd_SPLASH.py) to prepare the ppfd data:
```bash
python scripts/03b_ppfd_SPLASH.py
```

#### netrad

Net Radiation (`netrad`) can be calculated using SW_IN (Solar Radiation) and LW_IN (Longwave Radiation) data. The net radiation is the sum of the shortwave and longwave radiation minus the reflected shortwave radiation.

The net radiation can be calculated using the following formula:
```r
netrad = SW_IN_F - SW_OUT_F + LW_IN_F - LW_OUT_F
```

Here is the [script](./scripts/04_netrad.ipynb) to prepare the net radiation data.

#### patm
Atmospheric Pressure (`patm`) can be extracted from the daily measurement file. The variable `PA_F` is used which is `Atmospheric pressure, which is in kpa.` The script also converted the pressure from kPa to Pa by multiplying the values by 1000 and saved both values in the same file.
Here is the [script](./scripts/05_pa.ipynb) to prepare the atmospheric pressure data.

#### fapar and lai

Fraction of Photosynthetically Active Radiation (`fapar`) and Leaf Area Index (`lai`) was downloaded using MODISTools package. The data is downloaded for the period of 2004-2023 and is available in the [FAPAR data](./data/01_data_prep/06a_fapar_2004-2023.csv) and [LAI data](./data/01_data_prep/06b_lai_2004-2023.csv) folders of this repository. The script to download the data is available in the [scripts](./scripts/06_fapar_lai.ipynb).
- The data for both FAPAR and LAI was in 8 days interval so it was carry forward to daily values using dplyr and tidyr packages in R. as mentioned in the script.
- Final FAPAR data is available in the [FAPAR data](./data/01_data_prep/06a2_daily_fapar_2004-2023.csv) and LAI data is available in the [LAI data](./data/01_data_prep/06b1_lai_daily_2004-2023.csv).

#### ccov 
Cloud Coverage (`ccov`) can be extracted from the daily measurement file. But in our case the data is not available, so we used era5 data to get the cloud coverage data. The data is downloaded for the period of 2004-2023 and is available in the [CCOV data](./data/01_data_prep/07_era5_cloud_cover_2004-2023.csv) of this repository. The script to download nc file from era5 where python3 is used to extract the cloud coverage data is available in the [scripts](./scripts/07a_ccov.ipynb). After downloading the data, it is converted to csv file using the [script (R)](./scripts/07b_ccov.ipynb).

#### rain
Rainfall (`rain`) can be extracted from the daily measurement file. The variable `P_F` is used which is `Precipitation, which is in mm.` The script to prepare the rainfall data is available in the [scripts](./scripts/08_rain.ipynb).

#### co2
Atmospheric CO₂ concentration (`co2`) can be extracted from the daily measurement file. The variable `CO2_F_MDS` is used which is `Atmospheric CO2 concentration, which is in CO2 mole fraction, gapfilled with MDS;	µmolCO2 mol-1`.

### Final Data Preparation for CN-Model
The final data preparation is done by merging all the prepared data into a single tibble. The tibble is then saved as an RDS file for further use in the CN-Model. The final data preparation script is available in the [scripts](./scripts/10_final_data_preparation.ipynb).

## Run CNmodel
The CN-Model can be run using the `rsofun` package. The package provides functions to run the CN-Model with the prepared data. The CN-Model requires the prepared data in the specific format as described above. The CN-Model was run using the following [script](./scripts/11_CN_model_run.R).

### Leap year error handling
The CN-Model was giving errors when it was run with leap year data, so I removed the leap year data from the forcing data. This is done by removing the rows where date contains "-02-29". The error handling is done.
