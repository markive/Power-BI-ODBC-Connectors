## Power-BI-ODBC-Connectors

This repository contains connectors for Power BI for various data sources which will **enable DirectQuery** for any Progress DataDirect ODBC Connectors. 

### Pre-requisite
You need to install Progress DataDirect ODBC driver on your machine before you can use the connector. 

### Using the Connectors

1. To Download the Power BI Connectors, Go to [Releases](https://github.com/saiteja09/Power-BI-ODBC-Connectors/releases) and download the connector(.mez file) you need.  

2. On your Windows machine, Go to Documents and create a folder called `Power BI Desktop`.

3. Inside the folder `Power BI Desktop`, create another folder called `Custom Connectors`.

4. Copy the .mez file to Custom Connectors.

5. Open Power BI, Go to `File` -> `Options and Settings` -> `Security` -> `Data Extensions` -> Choose `Allow any extension to load without validation or warning`.

6. Click on `OK` and Restart Power BI.

7. You should now find the connector in the Other tab. Choose the connector, configure your connection and enable DirectQuery to query your data in real-time. 

### Troubleshooting

1. If you encounter an error, Go to `File` -> `Options and Settings` -> `Diagnostics` and click on `Open crash dump/traces` folder.

2. This should open the Traces folder of Power BI. Zip it and create an issue on the repo or share it with your contact at Progress allowing me to troubleshoot and fix the issue.

### I can't find the datasource I am looking for

If you cannot find the datasource you are looking for, please create a new issue.

##### Disclaimer: These connectors are not official and should be treated as experimental.
