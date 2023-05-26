<h1 align="center">⚕️Komplexpraktikum Medizinische Informatik 1⚕️</h1>

This is the code repository for the project "Predicting Sepsis Onset in ICU Patients" by Jonas Höpner and Claas de Boer.

The project was carried out as part of the "Komplexpraktikum Medizinische Informatik 1" (practical course in medical computer science) at the [Institute for Medical Informatics and Biometry](https://tu-dresden.de/med/mf/imb?set_language=en) of the [TU Dresden](https://tu-dresden.de/).
The project was directed by Dr. Markus Wolfien and implemented by Jonas Höpner and Claas de Boer under the supervision of Ian-Christopher Jung, Waldemar Hahn, and Katharina Schuler.
The project's code has been made public following the project's conclusion in accordance with Section 9 of the [PhysioNet Credentialed Health Data Use Agreement 1.5.0](https://physionet.org/content/mimiciv/view-dua/2.2/).

Find out more about our study's design, methodology, and findings, by reading our paper.

## 📁 Project Structure 

The project is structured as follows:
- [`/eda`](eda): Contains the notebooks used for exploratory data analysis.
  - [/sql](eda/sql): SQL queries used to extract data from the MIMIC-IV database.
  - [/plots](eda/plots): Plots generated during the exploratory data analysis.

## ⚡ Getting Started
  
### Prerequisites
This repository uses a set of [pre-commit hooks](https://git-scm.com/docs/githooks) to ensure code quality and consistency.  
To install these hooks, run the following command in the repository's root directory:
```bash
pip install -r requirements-dev.txt
pre-commit install
```
## 📜 Dependencies
The collective dependencies of this project are listed in [`requirements.txt`](requirements.txt).  
Each notebook has its own set of dependencies, which are listed in the notebook's first cell.

## 📝 License 

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
