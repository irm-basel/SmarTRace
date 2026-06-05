# SmarTRace
Assisted STR consensus profile generation and profile comparison

For automated and reproducible consensus profile generation based on independent STR profiles and comparison with reference profiles, we present the user-friendly and efficient software, SmarTRace.

## Requirements and Installation
1. R and R Studio need to be available
2. Download the most recent SmarTRace repository ZIP file<br>
 <img src="tutorial/images/download_zip.png" width="800"/>
3. Unzip downloaded folder "SmarTRace" and navigate to folder that contains .R Scripts<br>
4. Install the required R libraries by doubleclicking and then sourcing "setup.R" as shown here:<br>
 <img src="tutorial/images/setup.png" width="800"/>

## Start SmarTRace
1. Double-click "smartrace_app.R" to open in RStudio<br>
2. Run entire "smartrace_app.R", e.g., by marking all and Clicking "Run App"<br>
 <img src="tutorial/images/start_app.png" width="800"/>
3. A window opens up in the default explorer. <br>
 <img src="tutorial/images/smartrace_gui.png" width="800"/>
4. First upload the trace profile using the standard GeneMapper export file (1) or manual input (2)<br>
&nbsp;&nbsp;&nbsp;&nbsp; 4.1 The GeneMapper (GM) <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   4.1.1 The GM export file should contain a case code, the used systems/loci and at least the alleles observed per system. This is an example GM file:<br>
 <img src="tutorial/images/GM_export.png" width="800"/>
   4.1.2 The user needs to select the GM export table as input and then define the path to the folder, where the users' GM export files are located. When picking "check path", first the validity of the path will be checked and then this path will be saved for future uses as the location with GM export files. But this location can be changed anytime. Then the "Case ID" or sample name needs to be entered. In the above example that would be "Case X" and helps to find the right DNA profiles across GM export files. Finally, the user selects "Search files". Depending on the number of files located in the defined path, this step may take some time, as visualized by a progress bar (not shown). The user should wait for this process to be done, before continuing. 
 <img src="tutorial/images/genemapper_upload.png" width="800"/>
   
5. When the traces have been found, the user can select "Persons" to select the reference persons.
 <img src="tutorial/images/ref_persons.png" width="800"/>
6. 
7. 
8. 



 

