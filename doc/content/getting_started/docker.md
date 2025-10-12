# Docker Installation Instructions

## Installing Docker Desktop

### MacOS Installation Instructions

1. Download and install Docker Desktop from [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
1. Open the "Docker" application once installed.
1. Follow the remaining instructions in "Instructions for All Platforms" below.

### Linux Installation Instructions

1. Download and install Docker Desktop from [https://docs.docker.com/desktop/setup/install/linux/](https://docs.docker.com/desktop/setup/install/linux/)

   - The instructions for each flavor of Linux are found at the bottom of the page.

1. Follow the remaining instructions in "Instructions for All Platforms" below.

### Windows Installation Instructions

1. Install WSL (Windows Subsystem for Linux) with the instructions at [https://learn.microsoft.com/en-us/windows/wsl/install](https://learn.microsoft.com/en-us/windows/wsl/install).
1. Download and install Docker Desktop from [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

   - When promoted during the install process, ensure that "Use WSL-2 instead of Hyper-V" is selected if it is seen as an option (it might not)

1. Open Command Line and run `wsl`  to open a WSL window

   - From here on, all commands that are ran in a terminal window should be ran in a WSL window (opened with “wsl” in Command Line as above)

1. Follow the remaining instructions in "Instructions For All Platforms" below.

## Instructions for All Platforms

1. Download and install ParaView from [https://www.paraview.org/download](https://www.paraview.org/download).

!alert! tip title=What is ParaView used for?
ParaView is a visualization software from [Kitware](https://www.kitware.com) that will help you visualize TMAP8's results. Placing the input files you
plan to run into an external working directory (as in Step 3 below) will enable output to be placed there as well. Then, ParaView can be used in the
base operating system to view and visualize that output.
!alert-end!

!alert! warning
The remaining commands should be run within the WSL window on Windows and within a normal terminal window if on Linux or Mac!
!alert-end!

2. Run the following command to pull the container:

   ```bash
   docker pull idaholab/tmap8:2025.10.07-999a9a7
   ```

3. Run the following command to a create a directory that will be used within the environment:

   ```bash
   mkdir -p ~/tmap8-workdir
   ```

4. Run the following command to start the environment:

   ```bash
   docker run --rm -p 8080:8080 --mount type=bind,source=$HOME/tmap8-workdir,target=/tmap8-workdir idaholab/tmap8:2025.10.07-999a9a7 code-server-start
   ```
5. In the Terminal window where you ran the command in step 4, there will be text that states "Connect to the instance at [http://localhost:8080](http://localhost:8080) with password <PASSWORD>". Copy this password, open any web browser and navigate to [https://localhost:8080](http://localhost:8080), pasting in the password copied from the text (example below in the red box; your password will be different!)

!!!
This block adds some vertical spacing between the text and the image
!!!

!media getting_started/media/docker_pw.png style=width:80%;display:block;margin-left:auto;margin-right:auto;

6. Within the web browser window from step 5, click on the three bars in the top left corner and click on Terminal -> New Terminal:

!!!
This block adds some vertical spacing between the text and the image
!!!

!media getting_started/media/terminal.png style=width:80%;display:block;margin-left:auto;margin-right:auto;

7. In the terminal window within the web browser, type the following commands to download the TMAP8 tests, which include the input files for TMAP8's [V&V cases](verification_and_validation/index.md), [example cases](examples/index.md), and the cases highlighted in the TMAP8 [tutorial](workshops/tutorial/index.md):

   ```bash
   cd /tmap8-workdir
   ```

   ```bash
   tmap8-opt --copy-inputs tests
   ```

   Which should complete with a success message:

!!!
This block adds some vertical spacing between the text and the image
!!!

!media getting_started/media/copy_tests.png style=width:80%;display:block;margin-left:auto;margin-right:auto;

## Entering the Environment

Once the setup instructions are followed above, you may re-create and enter the environment at any time using Steps 4 and 5 in "Instructions For All Platforms".

!alert! tip title=Run into any issues?
If you run into any issues with this installation procedure, please consider posting a question to [TMAP8's GitHub Discussion Forum](https://github.com/idaholab/TMAP8/discussions).
!alert-end!

!! Uncomment this section to add information about how to overcome known issues with the installation
!! ## Known Issues