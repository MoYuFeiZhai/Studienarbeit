# SA_arithmetic_coding

### Tasks description:
State-of-the-art neural implants record from a few to hundreds of electrodes from inside the brain. Transmitting raw data (recorded signals) outside is very power-inefficient for a large number of electrodes. Therefore, an on-chip compression hardware accelerator is required to save power when transmitting the raw data. 

In our previous works, we have implemented fully adaptive arithmetic coding (AAC) and pseudo-adaptive Golomb coding (PAGC). The AAC achieves a higher space saving ratio (SSR) compared to the PAGC, but it is computationally complex. The previous work (PAGC) shows that the 2nd-order DPCM and unique introduced data map provide a suitable algorithm choice for implementing the AC in a non-adaptive fashion, resulting in power-efficient hardware.

In this project, arithmetic coding (AC) shall be studied, implemented by Software/Hardware and evaluated according to its compression performance as well as hardware efforts. 

The project consists of the following tasks:
- Literature study on one-dimensional signal compression algorithm: Arithmetic coding, Golomb coding
- Software implementation of the Arithmetic coding and analysis of its compression performance on neural signals 
   with help of the existing framework of compression engine, compared to the existing AAC and PAGC and possibly Huffman coding
- Synthesizable Hardware implementation of the arithmetic coding in RTL and the wrapper module for the constant data rate
- Verification of the hardware implementation against a software reference.
- Power analysis
- **Neat and organized documentation on Github -> suggested hints:**
     - Put all Matlab Codes in one folder
	 - Use the meaningful name for the variable, functions and file name
	 - Don't create several versions of a single code just by adding _ver1, _ver2 or so to the name of the file.
	 - If any code is obsolete, remove it from the folder.
	 - For the Matlab code, use the relative path to make it easier to be run on each machine
	 - For the Matlab code, add all the necessary paths at the begining of your code
	 - Briefly explain the code in one line at the begining of the code as comments
	 - Define function inputs/outputs clearly at the begining of the code as comments
	 - Support your codes with comments to make it easier for all to follow.
	 - The simulated results should be always reproducable so when you report the results mention all the settings/initialization resulting in those results.
	   - Clearly mentioned which code is used to generate the results.
	 - Report the simulation results in separate folder in github

Requirements:
- Good Verilog skills
- Familiar with the synthesis tool
- Good at Matlab and signal processing



