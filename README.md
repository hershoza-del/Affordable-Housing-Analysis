# Affordable Housing Analysis

An analysis of **5,928 projects** in NYC's *Affordable Housing Production by Project* dataset (NYC HPD, via NYC Open Data).

## Disclaimers

- **Program and size are tangled together.** Homeowner Assistance projects are almost all 1-unit and 100% affordable, so they drive much of the "small projects are fully affordable" result. A next step is to rerun Q1 within each program.
- **With n = 5,928, almost every test is significant.** I report effect sizes (V, w, η², odds ratios) so the reader can judge how large each difference is.
- **Unit counts are not people or rents.** A "low-income" unit at 80% AMI can still rent for more than many low-income households can pay.
- **Preservation and new construction are counted together** In this dataset, so these numbers are not net new supply.
- **Not all values were taken into account** In this dataset, not all 5,928 projects listed every numerical value in a given numerical column. Any project that yielded no numerical value was taken into account as **0**.
- **MOST IMPORTANTLY:** Based on my discretion, not all categorical/numerical values from the original dataset were taken into account and therefore have been deleted. Also, the statistical results down below are solely based from this dataset.

## Approach

- **Python (pandas/matplotlib):** cleaned and rearranged the data and a chart for each question (charts can be found on my LinkedIn page)
- **SQL:** exploring and summarizing the data for each question
- **R:** running statistical tests for each question

## Data

| | |
|---|---|
| Source | [Affordable Housing Production by Project](https://data.cityofnewyork.us/d/hq68-rnsi), NYC Department of Housing Preservation and Development (HPD) |
| Coverage | Projects that started after January 1, 2014 and count toward the *Housing New York* / *Housing Our Neighbors* plans |
| Rows | 5,928 projects (none dropped; every project had at least 1 counted unit) |
| Key fields | units by income tier, total units, counted (affordable) units, program group, start date, extended-affordability flag |

## Findings

### Question 1: How much of each project is affordable?

| Project size | 100% affordable | Mixed-income |
|---|---|---|
| Small (1–10 units) | 74.5% | 25.5% |
| Medium (11–100 units) | 31.5% | 68.5% |
| Large (100+ units) | 60.5% | 39.5% |

**Statistical Tests**

| Test | Result | What it means |
|---|---|---|
| Spearman correlation (size vs. affordable share) | ρ = −0.34, p < 0.001 | Bigger projects have a smaller affordable share (moderate effect) |
| Chi-square (size group × fully affordable) | χ²(2) = 906.0, p < 0.001, Cramér's V = 0.39 | Size group and being 100% affordable are related (moderate to strong) |
| Logistic regression (fully affordable ~ log size) | b = −0.376, z = −25.7, p < 0.001; OR per doubling = 0.77 | Each time size doubles, the odds of being 100% affordable drop by about 23% |

**Key Takeaways**

- Projects fall into two groups: **100% affordable**, or **mixed-income at about 20–30% affordable**. Few projects land in between, which suggests developers aim at specific targets instead of choosing an affordable share freely.
- The 20–30% band matches the city's rules. Policies like Mandatory Inclusionary Housing (MIH) and the 421-a / Affordable New York tax break require developers to set aside about 20–30% of a building's floor area or units as affordable, income-restricted housing. Most mixed-income buildings set aside the minimum the rules require.
- Bigger projects tend to have a smaller affordable share. The relationship isn't a straight line, though, as the next point shows.
- **Medium projects (11–100 units) are the most likely to be mixed-income:** only 31.5% are fully affordable, compared with 74.5% of small projects and 60.5% of large projects.
  - Small projects are mostly 1-unit homeowner projects, which count as fully affordable.
  - Many large projects are 100% affordable buildings financed directly by the city.
  - Medium projects fall in between, where a lot of the mixed-income buildings are.

### Question 2: Which income levels receive the most units?

| Income tier | % of AMI (Area Median Income) | Share of affordable units |
|---|---|---|
| Extremely Low | 0–30% | 18.4% |
| Very Low | 31–50% | 27.1% |
| Low | 51–80% | **34.1%** |
| Moderate | 81–120% | 6.1% |
| Middle | 121–165% | 14.2% |

**Statistical Tests**

| Test | Result | What it means |
|---|---|---|
| Chi-square goodness-of-fit (are the 5 tiers equal?) | χ²(4) = 76,356, p < 0.001, Cohen's w = 0.49 | Units are not split evenly across tiers (medium to large effect) |
| Friedman test (tiers within each project) | χ²(4) = 2,814.5, p < 0.001 | Tier counts differ within the same projects |
| Paired Wilcoxon, Holm-adjusted | All 10 pairs p < 0.01 | Every pair of tiers differs; the closest pair is Extremely Low vs. Very Low (p = 0.002) |
| Chi-square (program × tier) | χ²(12) = 73,021, p < 0.001, Cramér's V = 0.28 | Each program has a different tier mix (small to moderate effect) |

**Key Takeaways**

- **Low income (51–80% AMI) gets the largest share at 34%. Moderate income gets the smallest at 6%.** "Low income" goes up to 80% of AMI, so the biggest group of units is not aimed at the city's poorest households.
- Extremely Low and Very Low together get about 45% of units. That's a large share, but it's still less than half.
- The mix depends on the program:
  - **Multifamily Finance** serves the lowest incomes most: 56% of its units go to Extremely Low or Very Low. These projects get direct city funding, which makes deeper affordability possible.
  - **Multifamily Incentives** (tax-incentive and inclusionary projects) puts **38% of its units in the Middle tier**, up to 165% of AMI. This fits 421-a options that allowed affordable units at up to 130% of AMI. A tax break alone covers less of the cost, so these projects lean toward higher incomes.

### Question 3: How do program groups differ in size?

| Program | Projects | Median affordable units |
|---|---|---|
| Multifamily Finance | 1,196 | 104 |
| Small Homes | 46 | 36 |
| Multifamily Incentives | 2,742 | 9 |
| Homeowner Assistance | 1,944 | 1 |

**Statistical Tests**

| Test | Result | What it means |
|---|---|---|
| Welch's ANOVA (log size ~ program) | F(3, 217.2) = 10,015, p < 0.001, η² = 0.73 | Program explains about 73% of the variation in project size (very large effect) |
| Tukey HSD (pairs of programs) | All 6 pairs p < 0.001 | Every program differs in size from every other program |
| Kruskal-Wallis (raw units) | χ²(3) = 4,653.2, p < 0.001 | Confirms the ANOVA result without assuming normality |
| Multiple regression (log size ~ program + start year + extended affordability) | R² = 0.73, F(5, 5922) = 3,208, p < 0.001 | Program gaps hold after the controls (see the next table) |

**Key Takeaways**

- **Program type explains most of the difference in project size.** Every program differs from every other one, so the programs really build different kinds of projects.
- **Multifamily Finance builds the biggest projects** (median 104 affordable units). **Homeowner Assistance projects are almost always 1 unit**, because they help individual homeowners instead of building apartments.
- **Multifamily Incentives has a small median (9 units) but a very wide spread.** Most of its projects are small, but some have thousands of units.
- **Small Homes has only 46 projects**, so its results are less certain than the other programs'.
- The gaps between programs barely change after controlling for start year and extended affordability. Program, not timing, drives project size.
- Start year has no effect: projects in the same program are about the same size now as in 2014. Extended-affordability-only projects are about 48% larger, possibly because these projects extend affordability in larger existing buildings.
