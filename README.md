# Peer Skill Identification and Social Class: Evidence from a Referral Field Experiment

This repository contains the data cleaning, statistical analysis, and paper writing components for the research project examining peer productivity assessments and socioeconomic bias in referral networks.

## Project Overview

This project analyzes data from a lab-in-the-field experiment at a Colombian university testing how accurately peers identify productive others across cognitive and social skills. After interacting for an entire term (about 4 months) in small classrooms (average 26 students per class), we collected incentivized skill measures and peer referrals to evaluate assessment accuracy and potential social class barriers.

**Key Research Questions:** 
1. How accurately do peers identify productive others in cognitive versus social skills?
2. Do disadvantaged low-SES individuals face barriers in selection when peers assess productivity?

## Repository Structure

```
icfes-referrals-clean/
├── stata/
│   ├── 0_*.do              # Data cleaning and preparation
│   ├── 1_*.do              # Descriptive statistics
│   ├── 2_*.do              # Sample construction
│   ├── 3_*.do              # Main analysis setup
│   ├── ...                 # Additional analysis scripts (numbered sequentially)
│   └── f_*.do              # Figure generation scripts
├── figures/
│   └── *.png               # Output figures from analysis
├── slides/
│   └── internal/           # Presentations by duration
│       ├── 1min/           # 1-minute pitch (.tex, .pdf)
│       ├── 5min/           # 5-minute presentation (.tex, .pdf)
│       ├── 8min/           # 8-minute presentation (.tex, .pdf)
│       └── 1hour/          # Full seminar presentation (.tex, .pdf)
├── writing/
│   ├── manuscript.tex      # Main LaTeX manuscript
│   ├── manuscript.pdf      # Compiled research paper
│   └── *.bib               # Bibliography
├── LICENSE
└── README.md
```

**Note:** Raw experimental data is not included in this repository due to confidentiality requirements.

## Workflow Pipeline

This project follows a two-stage analysis pipeline: **Stata → LaTeX**

### 1. Statistical Analysis (Stata)

**Location:** `stata/`

**Input:** Experimental data (not included in repo)

**Script Naming Convention:**

| Prefix | Purpose | Description |
|--------|---------|-------------|
| `0_*`  | Cleaning | Raw data processing, variable creation, standardization |
| `1_*`  | Descriptives | Summary statistics, balance tables, sample characteristics |
| `2_*`  | Sample | Sample construction, merge operations |
| `3_*`  | Analysis | Main regression specifications, treatment effects |
| `...`  | Extended | Robustness checks, heterogeneity analysis |
| `f_*`  | Figures | Publication-ready visualizations |

**Main Analysis Steps:**
1. **Data Cleaning** (`0_*.do`)
   - Processes raw experimental data
   - Creates z-scores for skill measures (GPA, reading, math)
   - Merges individual and network-level variables
   - Outputs: `dataset_z.dta`

2. **Descriptive Analysis** (`1_*.do`)
   - Balance tables across treatment conditions
   - Summary statistics by SES and treatment
   - Network descriptives

3. **Main Regressions** (`3_*.do` and beyond)
   - Referral probability models
   - Skill identification accuracy
   - SES bias estimation
   - Treatment effect analysis

4. **Figure Generation** (`f_*.do`)
   - Creates all publication figures
   - Outputs to `figures/` directory

**Output:** 
- Analysis datasets (`.dta` files)
- `figures/*.png` - Statistical figures and plots
- Regression tables for manuscript

### 2. Paper Writing (LaTeX)

**Location:** `writing/`

**Main Files:**
- `manuscript.tex` - Complete manuscript including:
  - Introduction and literature review
  - Experimental design and procedures
  - Results and analysis
  - Discussion and conclusion
- Bibliography file (`.bib`) - References in BibTeX format
- Figure files (`.png`) imported from `figures/`

**Compilation:**
```bash
cd writing/
pdflatex manuscript.tex
bibtex manuscript
pdflatex manuscript.tex
pdflatex manuscript.tex
```

**Output:** `manuscript.pdf` - Final research paper

### 3. Presentations (LaTeX Beamer)

**Location:** `slides/internal/`

Presentations available in multiple formats for different time constraints:
- `1min/` - Elevator pitch
- `5min/` - Brief overview
- `8min/` - Conference presentation
- `1hour/` - Full seminar

Each folder contains `.tex` source and compiled `.pdf`.

## Getting Started

### Prerequisites

- **Stata 18** or higher with standard packages
  
- **LaTeX** distribution (TeX Live, MiKTeX, or MacTeX) with Beamer

### Running the Analysis

1. **Data Preparation**
   - Obtain experimental data (contact author)
   - Place data files in `stata/` directory

2. **Statistical Analysis**
   ```stata
   cd stata/
   
   // Run scripts in numerical order:
   do 0_cleaning.do      // Data cleaning
   do 1_descriptives.do  // Summary statistics
   do 2_sample.do        // Sample construction
   do 3_analysis.do      // Main regressions
   // ... continue with subsequent numbered scripts
   
   // Generate figures:
   do f_*.do             // All figure scripts
   ```

3. **Compile Paper**
   ```bash
   cd writing/
   pdflatex manuscript.tex
   bibtex manuscript
   pdflatex manuscript.tex
   pdflatex manuscript.tex
   ```
   Output: `manuscript.pdf`

## Data

### Raw Data Source

Data comes from a lab-in-the-field experiment conducted at a Colombian university. The experiment includes:
- 849 university students across multiple courses
- 4-month interaction period in small classrooms (avg. 26 students)
- Random assignment to Baseline or Quota treatment conditions
- Incentivized cognitive skill measures (Raven's test)
- Incentivized social skill measures
- Peer referral elicitation for both skill dimensions
- Administrative data (GPA, demographics, SES indicators)

**Raw data files:** Not included due to confidentiality

### Experimental Design

**Treatments:**
- **Baseline:** Pure performance incentives—referrals rewarded based solely on nominee's measured skill
- **Quota:** Additional incentives for identifying high-skilled peers from lower social classes

**Referral Structure:**
- Separate referrals for cognitive skill and social skill
- Nominees do not receive benefits (rules out nepotism/favoritism)
- Referrers paid based on nominee performance (reveals true beliefs)

### Cleaned Data Structure

**Analysis Dataset** (`.dta`):
- One row per participant-pair (network format)
- Variables include:

| Variable | Description |
|----------|-------------|
| `own_id` | Referrer identifier |
| `other_id` | Potential referee identifier |
| `treat` | Treatment assignment (0 = Baseline, 1 = Quota) |
| `tie` | Social tie indicator |
| `own_estrato` | Referrer SES (estrato) |
| `other_estrato` | Referee SES (estrato) |
| `z_own_gpa` | Referrer GPA (z-score) |
| `z_other_gpa` | Referee GPA (z-score) |
| `z_own_score_reading` | Referrer reading score (z-score) |
| `z_other_score_reading` | Referee reading score (z-score) |
| `z_own_score_math` | Referrer math score (z-score) |
| `z_other_score_math` | Referee math score (z-score) |
| `cognitive_referral` | Referred for cognitive skill (binary) |
| `social_referral` | Referred for social skill (binary) |

## Project Navigation Guide

### For Replication
1. Review experimental design section in `manuscript.pdf`
2. Examine data cleaning: `stata/0_*.do` scripts
3. Follow analysis pipeline: Numbered Stata do-files in sequence
4. Check results presentation: `writing/manuscript.tex`

### For Understanding Results
1. Read the paper: `writing/manuscript.pdf`
2. Examine main regression outputs from analysis scripts
3. Review figures: `figures/` directory
4. Check presentations: `slides/internal/` for visual summaries

### For Extending the Analysis
- **Alternative specifications:** Modify regression do-files
- **New figures:** Add scripts to `stata/` following `f_*.do` pattern
- **Additional analyses:** Create new do-files following numbering convention
- **Manuscript edits:** Modify `writing/manuscript.tex`

## Key Findings

From `manuscript.pdf`:

1. **Skill-dependent screening accuracy:** Peers successfully identify cognitive skills but struggle to assess social skills under pure performance incentives

2. **Proxy reliance:** When uncertain about skills, peers rely on observable proxies like academic performance (GPA) for both skill dimensions

3. **Referral overlap:** High rates of common referrals for both skills, exceeding actual overlap in productivity across dimensions

4. **Limited SES bias:** Bias against low-SES peers found only in unique cognitive skill referrals (affecting ~50% of cognitive referrals overall)

5. **Effective quota treatment:** Targeted incentives successfully mitigate bias for the affected subset without compromising productivity

6. **No efficiency-equity tradeoff:** Quota treatment increases low-SES referrals while maintaining referred productivity levels

## Citation

If you use this code or data, please cite:

```bibtex
@unpublished{tuncer2025referrals,
  title={Peer Skill Identification and Social Class: Evidence from a Referral Field Experiment},
  author={Munoz, Manuel and Reuben, Ernesto and Tuncer, Reha},
  year={2025},
  note={Working paper}
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Reha Tuncer  
reha.tuncer@gmail.com

## Acknowledgments

This research was conducted at a Colombian university with support from collaborating institutions. The author is grateful to supervisors, colleagues, and study participants. See paper acknowledgments for complete details.

---

**Repository Status:** Active  
**Last Updated:** February 2026