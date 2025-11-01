# SQL Query Results & Analysis

## Query 1: Overall Default Statistics
- Total: 30,000 | Defaults: 6,636 | **Rate: 22.12%**

<img width="436" height="124" alt="image" src="https://github.com/user-attachments/assets/978f1d1e-1e23-4d1a-915d-767ce9d8626f" />

---

## Query 2: Default by Gender
- Male: **24.17%** (Higher Risk)
- Female: 20.78%

<img width="470" height="162" alt="image" src="https://github.com/user-attachments/assets/c3ce6215-8e00-461d-a93e-cad8a8f63559" />

---

## Query 3: Default by Education
- High School: **25.16%** (Highest) 
- University: 23.73%
- Graduate: **19.23%** (Lowest) 
- Others: 7.05%

<img width="452" height="187" alt="image" src="https://github.com/user-attachments/assets/8c4b687a-1965-4fe6-9329-1fd5c69fa282" />

**Insight**: Education inversely correlates with risk

---

## Query 4: Default by Age
- <25: **27.19%** (HIGHEST RISK)
- 46-55: 24.94%
- >55: 26.54%
- 36-45: 21.84%
- 25-35: **20.31%** (Lowest) 

<img width="456" height="196" alt="image" src="https://github.com/user-attachments/assets/d00753f7-834b-4501-8572-0d0239bec0bb" />


**Insight**: Young customers critical risk segment

---

## Query 6: Payment Delay Frequency
- 0 delays: 11.71% (Safe)
- 1 delay: 29.82%
- 2 delays: 38.76%
- 3 delays: 50.87%
- 4 delays: 57.31%
- 5 delays: 57.38%
- 6 delays: **70.32%** (CRITICAL)

<img width="500" height="234" alt="image" src="https://github.com/user-attachments/assets/4de33a78-bdf2-47cc-a3dd-e362410a564c" />

**Insight**: EXPONENTIAL RISK - Payment delays = strongest predictor!

---

## Top Risk Factors (Ranked)

| Rank | Factor | Impact |
|---|---|---|
| 1 | **Payment Delays** | +58.61% (0→6) |
| 2 | **Age (<25)** | +27.19% vs 20.31% |
| 3 | **Gender (Male)** | +3.39% vs Female |
| 4 | **Education** | 25.16% vs 19.23% |

---

## Business Recommendations

### Immediate Actions:
1. **BLOCK** customers with 3+ payment delays
2. **Reduce limits** for age <25 segment
3. **Enhanced monitoring** for males
4. **Incentivize education verification**

### Portfolio Actions:
1. Shift mix toward graduate/university + female segment
2. Tighten approval for multiple risk factors combined
3. Early intervention for 1-2 delays (prevent escalation)

---

*Analysis Date: November 2, 2025*

