<h1 align="center">⚕️Komplexpraktikum Medizinische Informatik⚕️</h1>

This is the code repository for the project "Limitations of Naiive Feature Aggregation in Predicting Sepsis Onset: A Study Using the MIMIC-IV Database" by Jonas Höpner and Claas de Boer.

The project was carried out as part of the "Komplexpraktikum Medizinische Informatik" (practical course in medical computer science) at the [Institute for Medical Informatics and Biometry](https://tu-dresden.de/med/mf/imb?set_language=en) of the [TU Dresden](https://tu-dresden.de/).
The project was directed by Dr. Markus Wolfien and implemented by Jonas Höpner and Claas de Boer under the supervision of Ian-Christopher Jung, Waldemar Hahn, and Katharina Schuler.
The project's code has been made public following the project's conclusion in accordance with Section 9 of the [PhysioNet Credentialed Health Data Use Agreement 1.5.0](https://physionet.org/content/mimiciv/view-dua/2.2/).

Find out more about our study's design, methodology, and findings, by reading our [report](report/report.pdf).

## 📁 Project Structure 

The project is structured as follows:
- [`/eda`](eda): Contains the notebook used for exploratory data analysis.
  - [`/sql`](eda/sql): SQL queries used to extract data from the MIMIC-IV database.
  - [`/plots`](eda/plots): Plots generated during the exploratory data analysis.
  - [`eda.ipynb`](eda/eda.ipynb): Notebook containing the exploratory data analysis.
  - [`config.toml`](eda/config.toml): Configuration file for the database connection. (Not provided in this repository.)
- [`/ml`](ml): Contains the notebook used for model training and evaluation.
  - [`ml.ipynb`](ml/ml.ipynb): Notebook containing the model training and evaluation.
  - [`/sql`](ml/sql): SQL queries used to extract data from the MIMIC-IV database.
  - [`config.toml`](eda/config.toml): Configuration file for the database connection. (Not provided in this repository.)
- [`/report`](report): Contains the report describing the study's design, methodology, and findings.
  - [`/figures`](report/figures): Figures used in the report.
  - [`report.pdf`](report/report.pdf): The report in PDF format.

## Reproducing the Results

To reproduce the results of our study, follow these steps:
- Set up a PostgreSQL database with the MIMIC-IV database. (Version 2.2 of the MIMIC-IV database was used for this project.)
- Execute the MIMIC-Code concepts found in the [MIMIC-Code repository](https://github.com/MIT-LCP/mimic-code/tree/v2.4.0/mimic-iv/concepts_postgres) to create the necessary `mimiciv_derived` schema with its associated tables.
- Set up a `config.toml` file in both the [`/eda`](eda) and [`/ml`](models) directories. The `config.toml` file should contain the following information:
```toml
[database]
dbname = "..."   # Database name
user = "..."     # Database user
password = "..." # Database user password
host = "..."     # Host IP address
port = 5432      # Host port
```
- [Optionally]: Install project dependencies by running `pip install -r requirements.txt` in the project's root directory. Not required as the notebooks contain their own dependency lists and install the dependencies automatically.
- Execute the [`/eda/eda.ipynb`](eda/eda.ipynb) and [`/ml/ml.ipynb`](ml/ml.ipynb) notebooks.
That's it! You're good to go! 🚀

### 📜 Dependencies
The collective dependencies of this project are listed in [`requirements.txt`](requirements.txt).  
Each notebook has its own set of dependencies, which are listed in the notebook's first cell.

## 📝 License 

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
