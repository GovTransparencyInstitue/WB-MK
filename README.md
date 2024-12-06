# WB MK  Overview


## Project Description:
This project focuses on analyzing the public procurement data  for the MK (North Macedonia) data. The script performs data preprocessing, matching, and analysis to process these entities efficiently. The process also handles  specific calculations such as corruption risks (CRI) and Loss due to corruption risk. It also creates the files used for Network analysis

---

## Steps Involved in the Process:

### 1. **Project Initialization**
   - Set up project directories and load necessary macros:
     ```stata
     init_project "C:/Ourfolders/Aly" "MK_WB"
     ```

### 2. **Load Global Macros**
   - Loads configuration macros from a separate file:
     ```stata
     do "./codes/utility/config_macros.do"
     macro list
     ```

### 3. **Import and Preprocess Raw Data**
   - The script loads data from different dates (e.g., 7th October 2022, 10th November 2022, 25th November 2022) and imports CSV files containing MK data.
   - Example of data import:
     ```stata
     import delimited using "${data_raw}/MK_202211_20221125/MK_data_202211.csv", encoding(UTF-8) clear
     ```

### 4. **Data Cleaning and Transformation**
   - Several data frames are created for buyers and bidders:
     ```stata
     frame put buyer_masterid buyer_name buyer_city buyer_country buyer_postcode, into(buyer)
     frame put bidder_masterid bidder_name bidder_city bidder_country, into(bidder)
     ```
   - Missing values for `buyer_masterid` and `bidder_masterid` are dropped and data saved:
     ```stata
     drop if missing(`frame'_masterid)
     save "${data_processed}/MK_`frame'_raw.dta", replace
     ```

### 5. **City Standardization**
   - Standardizes city names using API services to ensure consistency:
     ```stata
     do "${codes}/city_standardization.do"
     ```

### 6. **Buyer and Bidder Matching **
   - Matches buyer and bidder entities based on predefined rules to standardize their ids:
     ```stata
     do "${codes}/buyer_matching.do"
     do "${codes}/bidder_matching.do"
     ```

### 7. **Merging Data**
   - Merges buyer and bidder IDs with the main dataset:
     ```stata
     merge m:1 buyer_masterid using "${data_processed}/MK_buyer_id_match.dta", nogen keep(1 3) keepusing(buyer_id_assigned buyer_country_api...)
     ```

### 8. **Randomly Assign Bidder IDs for Missing Names**
   - For records missing bidder names, random names and IDs are generated:
     ```stata
     replace bidder_name = "bidder_"+string(x) if y==2
     ```

### 9. **CRI Calculation**
   - CRI (Corruption Risk Index) calculations are performed by generating new variables and applying transformations:
     ```stata
     do "${codes}/gen_cri.do" "MK"
     ```

### 10. **Export Processed Data**
   - The processed data is exported for further use:
     ```stata
     save "${data}/processed/MK_202211_processed.dta", replace
     ```

### 11. **Improve CPV Codes**
   - A separate script is used to enhance CPV codes, involving the matchit algorithm:
     ```stata
     do "${codes}/cpv_matchit_mk.do"
     ```

### 12. **Cost of Corruption Risk (CoC) Calculation**
   - A script to calculate the cost of corruption risks is executed:
     ```stata
     do "${codes}/coc_calculations.do"
     ```

## Network Analysis: Creation of Node and Edge Lists

In this project, we use the MK procurement data to create a network of organizations, including both buyers and suppliers. The aim is to represent relationships between these entities via contracts, which are modeled as edges connecting the nodes (organizations). This network is useful for analyzing the structure of procurement processes and evaluating corruption risks (CRI) across entities.

### Node and Edge List Creation

The first step in the network analysis process involves constructing the node and edge lists from the MK dataset. The node list consists of organizations—both buyers and suppliers—while the edge list represents contracts awarded between buyers and suppliers. These two lists are fundamental for building the graph that will be analyzed and visualized.

The process of creating the network tables is done by transforming and merging various datasets. Each organization is assigned a unique identifier, and we distinguish between buyers and suppliers based on the role they play in each contract. The edge list contains the contract relationships between these entities, with additional attributes such as contract values and CRI scores, which will be used to color the edges in the visualization.

### Loading Data into Gephi

Once the node and edge lists are generated, they are exported and loaded into Gephi, a powerful open-source network visualization tool. Gephi allows us to explore the structure of the network interactively and perform various network metrics analysis, such as centrality, modularity, and clustering.
Scripts used: *Create_gephi_edgelist.ipynb* and *Graph Exploration.ipynb*

The steps to prepare and visualize the network in Gephi include:

1. **Edge Coloring Based on CRI Value**: In Gephi, edges are colored based on the Corruption Risk Index (CRI), which is derived from the MK data. The CRI value is an important measure of potential procurement corruption risks associated with each contract, and the edge color provides an intuitive way to visualize these risks within the network.

2. **Node Representation of Organizations**: Nodes in the network represent organizations (buyers and suppliers). Each node is labeled with the organization’s name or ID, and nodes are sized based on metrics such as centrality or contract volume. This sizing helps us identify key players in the procurement network, such as the most active buyers or suppliers.

3. **Layout and Graph Exploration**: Gephi provides several layout algorithms to organize the network in an aesthetically meaningful way. The **Fruchterman-Reingold** layout is used to arrange the nodes in a way that minimizes edge crossings and maximizes node visibility. This layout helps in understanding the relationships and structure of the network more clearly, with clusters of nodes that may represent groups of organizations frequently interacting with one another.

4. **Visual Exploration**: Once the network is loaded into Gephi, it can be explored interactively to uncover insights about the structure of the procurement relationships. For example, we can identify clusters of closely connected buyers and suppliers, or detect potential isolated organizations.

### Network Metrics Analysis

After visualizing the network in Gephi, the Python Jupyter notebook is used to perform more in-depth analysis of the network metrics. The notebook loads the node and edge lists and calculates various network properties such as:

- **Centrality**: Measures how central or important a node is within the network. Nodes with high centrality play a crucial role in connecting different parts of the network.
- **Modularity**: Identifies communities or clusters within the network, where nodes are more connected to each other than to nodes in other communities.
- **Clustering**: Quantifies the degree to which nodes tend to cluster together.

These network metrics provide insights into the structure and functioning of the procurement network, highlighting key organizations and potential areas of risk.

---