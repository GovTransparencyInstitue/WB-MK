# WB MK  Overview

## Project Description:
This project focuses on analyzing the public procurement data  for the MK (North Macedonia) data. The script performs data preprocessing, matching, and analysis to process these entities efficiently. The process also handles  specific calculations such as corruption risks (CRI) and Loss due to corruption risk. It also creates the files used for Network analysis

## Data Availability Statement:

The public procurement contracts data is publicly available from **[https://e-nabavki.gov.mk](https://e-nabavki.gov.mk)**. GTI collects the procurement data bi-annually, and the version used in this project was scraped in December 2022. GTI compiled and mastered the publicly available data. For this project, we utilized the cleaned and mastered version of the North Macedonian public procurement contracts data.

The publicly accessible links for each contract is stored in the following columns:
- **`notice_url`**: Refers to the tender notice.
- **`tender_publications_lastcontract`**: Refers to the contract award notice.

To access the data folder, please reach out to **info@govtransparency.eu**. Once received, place the data in the `data/processed` folder to ensure all scripts function correctly.

You will receive 2 datasets
1) MK_202212_processed.dta: This is the main dataset used for analysis. It is a mastered version of the North Macedonian public procurement contract level data.  
2) MK_202212_processed_network_exploration.csv.gz: Same data as above in csv.gz format filtered for variables used in network exploration. We use this version for the Network exploration codes.   
2) TED_yearly_CRI_w_MK_update.dta: This dataset is used to plot the CRI/single bidding country averages.

### Important Notes:
- **Raw Data**: We are unable to provide the raw data and code used to generate the files. However, the process of compiling the North Macedonian and the Tenders Electronic Daily TED datasets (used for CRI comparisons) is detailed in the following publication:
  > Fazekas, M., Tóth, B., Abdou, A., & Al-Shaibani, A. (2024). Global Contract-level Public Procurement Dataset. *Data in Brief, 54*, 110412. [https://www.sciencedirect.com/science/article/pii/S2352340924003810#sec0004](https://www.sciencedirect.com/science/article/pii/S2352340924003810#sec0004)

---

## Main processes:

### **Folder Structure**
   This script creates the folder structure required for this project:
    ```stata
    do "./codes/utility/config_macros.do"
     ```
### 1. **Data Exploration**
   - These scripts restructure the date variables, create controls and explores the data to create CRI distribution figures in the manuscript:
     ```stata
     do "./codes/date_var_restructure.do"
     do "./codes/gen_controls.do"
     do "./codes/descriptives.do"
     do "./codes/figures_paper.do"
     do "./codes/figures_corruption_risks.do"
     ```
### 2. **Cost of Corruption Risk (CoC) Calculation**
   - A script to calculate the cost of corruption risks and exports tables/figures:
     ```stata
     do "${codes}/coc_calculations.do"
     ```
### 3. **Network Analysis**
- This section explores the MK data as a network between buyers and suppliers. The following scripts are available for this purpose:  
 **Python Notebook:** `Graph Exploration.ipynb`  
  This notebook uses the MK dataset to generate graph descriptive statistics, Annex 2 network figures and edge lists.  
**Python Notebook:** `Create_gephi_edgelist.ipynb`  
This notebook uses the edge lists listed below created in `Graph Exploration.ipynb` and prepares node lists and edge lists to be loaded in Gephi.  
- edgelist_global  
- edgelist_before_long
- edgelist_after_long
- edgelist_large_45_*  

Note: Copy *MK_202212_processed_network_exploration.csv.gz* to *./codes/Network_Analysis/data/* - all folder structures are defined in the jupyter notebooks.
## Exhibits Map

###### Tables in `main.do`
**[Line 45] Table 1** : Validation of corruption risk indicators using Single bidding as the main corruption risk proxy in an binary logistic regression framework- North Macedonia 2011-2022
Detailed validation for each indicator can be found in `MK_cri_validation.do`

 ###### Figures in `figures_paper.do`
 **Figure 1: Distribution of public contracts over time**
 **[Line 37] Panel A:** Number of tenders and awarded contracts in North Macedonia, 2011-2022  
 **[Line 78] Panel B:** Total monthly spending in North Macedonia, 2011-2022  

 **Figure 2: Distributions of awarded contracts by contract type**
 **[Line 100] Panel A:** Yearly distribution of public contracts in North Macedonia, 2011-2022  
 **[Line 115] Panel B:** Yearly spending by contract type in North Macedonia, 2011-2022  

 **Figure 3: Distributions of awarded contracts across geographical regions**
 **[Line 144] Panel A:** Yearly distribution of public contracts in North Macedonia, 2011-2022  
 **[Line 156] Panel B:** Yearly spending by contract type in North Macedonia, 2011-2022  

 **Figure 4:** **[Line 180]** Yearly distribution of procurement organizations in North Macedonia, 2011-2022  
 Figures in `ted_cri_figure_export.do`
  **Figure 14:**   Average single bidding rate in North Macedonia and the EU (TED data)

 Figures in `figures_corruption_risks.do`  
 **Figure 5:** **[Line 72]** Distribution of awarded contracts by their average CRI , North Macedonia, 2011-2022  
 **Figure 6:** **[Line 89]** Distribution of procurement authorities by their average CRI , North Macedonia, 2011-2022  
 **Figure 7:** **[Line 115]** Distribution of awarded firms by their average CRI, North Macedonia, 2011-2022.  
 **Figure 8:** **[Line 140]** Average CRI by year, North Macedonia, 2011-2022  
 **Figure 9:** **[Line 152]** Average CRI per contract trends across regions, North Macedonia, 2011-2022  
 **Figure 10:** **[Line 179]** CRI by industry, (number of contracts>1000)  
 **Figure 11:** **[Line 184]** CRI trends for the construction sector compared to the other sectors, 2011-2022.  
 **Figure 12:** **[Line 202]** CRI trends for the health sector compared to the other sectors, 2011-2022  
 **Figure 13:** **[Line 226]** Annual trends for individual red flags

 **Figure 15: Distribution and spending of multi-lot and single-lot tenders**
 **[Line 220] Panel A:** Annual distribution of tenders across multi-lot and single-lot tenders in North Macedonia, 2011-2022  
 **[Line 235] Panel B:** Annual total spending in multi-lot and single-lot tenders in North Macedonia, 2011-2022  

 **Figure 16:**
 **[Line 261]** The distribution of the logarithm of relative contract value in single-lot tenders  

 **Figure 17: Potential savings after eliminating procurement corruption risks (CRI), North Macedonia, 20122-2022**
 **[Line 291] Panel A:** Half Yearly potential savings rate by eliminating CRI and other selected corruption risk indicators  
 **[Line 315] Panel B:** Half Yearly potential savings in million MDK by eliminating CRI and other selected corruption risk indicators  

 **Figure 18:**
 **[Line 342]** Distribution of potential savings (million MKD) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia, 2011-2022  

 **Figure 19:**
 **[Line 487]** Distribution of potential savings (percentage points) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia, 2011-2022  

 **Figure 20:**
 **[Line 425]** Distribution of potential savings (percentage points) by eliminating single bidding corruption risk across regions in North Macedonia, 2011-2022  

 **Figure 21:**
 **[Line 584]** Distribution of potential savings (% of total spending) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia, 2011-2022 – Top 10 CPV divisions by highest saving potential  


 Figures in `coc_calculations.do`

 **Figure 17:**
 **[Line 291] Panel A:** Half Yearly potential savings rate by eliminating CRI and other selected corruption risk indicators  
 **[Line 315] Panel B:** Half Yearly potential savings in million MDK by eliminating CRI and other selected corruption risk indicators  

 **Figure 18:**
 **[Line 342]** Distribution of potential savings (million MKD) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia, 2011-2022  

 **Figure 19:**
 **[Line 487]** Distribution of potential savings (percentage points) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia, 2011-2022  

 **Figure 20:**
 **[Line 425]** Distribution of potential savings (percentage points) by eliminating single bidding corruption risk across regions in North Macedonia, 2011-2022  

 **Figure 21:**
 **[Line 584]** Distribution of potential savings (% of total spending) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia, 2011-2022 – Top 10 CPV divisions by highest saving potential  

## Network Analysis: Creation of Node and Edge Lists

In this project, we use the MK procurement data to create a network of organizations, including both buyers and suppliers. The aim is to represent relationships between these entities via contracts, which are modeled as edges connecting the nodes (organizations). This network is useful for analyzing the structure of procurement processes and evaluating corruption risks (CRI) across entities.

### Node and Edge List Creation

The first step in the network analysis process involves constructing the node and edge lists from the MK dataset. The node list consists of organizations—both buyers and suppliers—while the edge list represents contracts awarded between buyers and suppliers. These two lists are fundamental for building the graph that will be analyzed and visualized.

The process of creating the network tables is done by transforming and merging various datasets. Each organization is assigned a unique identifier, and we distinguish between buyers and suppliers based on the role they play in each contract. The edge list contains the contract relationships between these entities, with additional attributes such as contract values and CRI scores, which will be used to color the edges in the visualization.

### Loading Data into Gephi

Once the node and edge lists are generated, they are exported and loaded into Gephi, a powerful open-source network visualization tool. Gephi allows us to explore the structure of the network interactively and perform various network metrics analysis, such as centrality, modularity, and clustering.
Scripts used: *Create_gephi_edgelist.ipynb* and *Graph Exploration.ipynb*

Network Figures come from data prepared in `Graph Exploration.ipynb` and `Create_gephi_edgelist.ipynb`

*Gephi Figures*  

Gephi version: 0.10.1  

The following data files are required for reproducing Figures 23-27. These are exported in **Graph Exploration.ipynb**:

- `edgelist_global.csv`
- `edgelist_before_long.csv`
- `edgelist_after_long.csv`
- `edgelist_45_full.csv`
- `edgelist_45_before.csv`
- `edgelist_45_after.csv`
- `edgelist_large_45_2_buyer_full.csv`
- `edgelist_large_45_2_buyer_before.csv`
- `edgelist_large_45_2_buyer_after.csv`

Exporting Data  
All `edgelists_*` and `nodelists_*` should be exported using **Create_gephi_edgelist.ipynb**.


**Figure 23:**  Network Communities in the Public Procurement Network of North Macedonia (2011-2022)  
    **Data:** `edgelist_edgelist_global.csv` and `nodelist_edgelist__global.csv`

    1. Load both files into Gephi using the **Import Spreadsheet** option.
    2. Append both sheets to the same workspace and rename it to `Full`.
    3. Click on **Statistics** → Run **Average Degree** to calculate degrees.
    4. Apply **Topology-Giant Component** filter and rename the output as `Complete Network`.
    5. Set Edge Appearance:
      - **Ranking:** `edge_cri` from **green** to **red**, with **white midpoint**.
    6. Set Node Appearance:
      - **Size:** `1` (to hide nodes).
    7. Apply **Force Atlas 2 Layout** with parameters:
      - Scaling: `10`
      - Gravity: `1`
      - Edge Weight Influence: `1.5`
    8. In the **Overview** tab, increase the **edge weight scale** to the maximum.
    9. In the **Preview** tab, set **Color Option** to **Original**.
    10. Note: The figure may not be identical to the original but should yield the same conclusions.

**Figure 24:**  Community Split Based on Edge CRI Percentile in North Macedonia's Procurement Network (2011-2022)  
    **Data:** `edgelist_edgelist_global.csv` and `nodelist_edgelist_global.csv` (using the `Full` workspace)

    1. Run **Network Diameter Statistics** to obtain **betweenness centrality**.
    2. Run **Modularity Statistics** with **resolution set to 1**.
    3. Adjust Node Appearance:
      - **Size:** Based on **betweenness centrality**, ranging from **35 to 100**.
      - **Color:** Based on **Modularity Class**.
    4. Reapply **Force Atlas 2 Layout** until the network stabilizes.
    5. Duplicate the **Complete Network** within the workspace and create sub-networks:
      - **Bottom 25th percentile:** Filter edges with weight **≤ 0.304715**.
      - **Top 25th percentile:** Filter edges with weight **≥ 0.586473**.
    6. Toggle between top and bottom filters to visualize figures in the **Preview** tab.

**Figure 25:**  Procurement network representation before and after the government change in North Macedonia  
    **Data:**
    - **Left Panel:** `edgelist_edgelist_before_long.csv`, `nodelist_edgelist_before_long.csv` → Rename workspace to `Full - Before Long`
    - **Right Panel:** `edgelist_edgelist_after_long.csv`, `nodelist_edgelist_after_long.csv` → Rename workspace to `Full - After Long`

    For both workspaces:
    1. Apply **Topology-Giant Component** filter.
    2. Adjust Edge Appearance:
      - **Ranking:** `edge_cri` from **green** to **red**, with **white midpoint**.
    3. Set Node Appearance:
      - **Size:** `1` (to hide nodes).
    4. Apply **Force Atlas 2 Layout** with parameters:
      - Scaling: `10`
      - Gravity: `1`
      - Edge Weight Influence: `1.5`
    5. In the **Overview** tab, maximize the **edge weight scale**.
    6. In the **Preview** tab, set **Color Option** to **Original**.

**Figure 26:**  Construction Procurement network representation before and after the government change in North Macedonia, 2011-2022  
    **Data:**
    Gephi - **Left Panel:** `edgelist_edgelist_45_before.csv`, `nodelist_edgelist_45_before.csv` → Rename workspace to `45 Before`
    - **Right Panel:** `edgelist_edgelist_45_after.csv`, `nodelist_edgelist_45_after.csv` → Rename workspace to `45 After`

    For both workspaces:
    1. Apply **Topology-Giant Component** filter.
    2. Adjust Edge Appearance:
      - **Ranking:** `edge_cri` from **green** to **red**, with **white midpoint**.
    3. Set Node Appearance:
      - **Size:** `10`
      - **Color:** Black
    4. Apply **Force Atlas 2 Layout** with parameters:
      - Scaling: `10`
      - Gravity: `1`
      - Edge Weight Influence: `1.5`
    5. In the **Overview** tab, set the **edge weight scale** to **50%**.
    6. In the **Preview** tab, set **Color Option** to **Original**.

   **Note:** Figures may not be identical but should support the same conclusions.

**Figure 27:**  Ego network of the largest procurement authority in the construction sector before and after the government change in North Macedonia, 2011-2022  
    **Data:**
    - `edgelist_edgelist_large_45_2_buyer_before.csv`, `nodelist_edgelist_large_45_2_buyer_before.csv` → Rename workspace to `Largest 45 Before`
    - `edgelist_edgelist_large_45_2_buyer_after.csv`, `nodelist_edgelist_large_45_2_buyer_after.csv` → Rename workspace to `Largest 45 After`

    For both workspaces:
    1. Adjust Edge Appearance:
      - **Ranking:** `edge_cri` from **green** to **red**, with **white midpoint**.
    2. Set Node Appearance:
      - **Size:** Based on `cri`, ranging from **10 to 20**.
      - **Color:** Black.
    3. Apply **Force Atlas 2 Layout** with parameters:
      - Scaling: `10`
      - Gravity: `1`
      - Edge Weight Influence: `1.5`
      - If needed, use **Expansion Layout** to better visualize ties.
    4. In the **Overview** tab, set the **edge weight scale** to **25%**.
    5. In the **Preview** tab, set **Color Option** to **Original**.

    **Note:** Figures may not be identical but should lead to the same conclusions.


*Annex 2 Figures in `Graph Exploration.ipynb`*  
**Figure A2.a:** Regional Network Metrics Trend Analysis for North Macedonia: 2011-2022  
**Figure A2.b:** Change in the number of nodes before and after the 2017 government change in North Macedonia  
**Figure A2.c:** Change in the number of distinct ties before and after the 2017 government change in North Macedonia  
**Figure A2.d:** Change in the average node degree before and after the 2017 government change in North Macedonia  
**Figure A2.e:** Change in assortativity before and after the 2017 government change in North Macedonia  
**Figure A2.f:** Change in the average betweenness centrality before and after the 2017 government change in North Macedonia  
**Figure A2.g:** Change in the Modularity score (Louvain algorithm) before and after the 2017 government change in North Macedonia
