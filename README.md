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


### Meeting logs

#### Meeting on 04/11/2021:
 - signal processing 
   - frequency domain transformations:
     - FFT (DFT)
     - DCT
   - decorrelation
     - DPCM 
     - Freq-domain Trans
 - for the next week:
   - high-order DPCM
   - modification of the code
#### Meeting on 11.11.2021
  - 9-bit AC re-implementation based on the original algorithm.
    - the output in ht ecurrent implementation is saturated becuase it is not converted to binary
  - higher order DPCM study
  - for the next week:
    - change the output to binary mode and study more on AC with eqaul probability for all symbols
    - draw the data distribution at the input and the output of DPCM and compare them. the entropy should be also calculated.
#### Meeting on 18.11.2021
  - 9-bit AC re-implementation, decimal output encoder design
    - practical algorithm (division & expansion, output bit by bit)
    - hardware implementation preview (VALID_sig)
  - relationship between DPCM & goal of entropy coding
  - for the next week:
    - realization of practical AC algorithm 
    - draw the data distribution at the input and the output of DPCM and compare them. the entropy should be also calculated.
#### Meeting on 25.11.2021
  - change the code to bit-wise compression and use three regions to do the coding (with the equal probability)
  - working on the implementation with unequal probability of symbols
    - the larger probability needs less bits
    - decoding is **not working**: probelm is the implementation of the middle region
  - To do:
    - debugging the decoding stage and fix itand try to understand the ideah behind the implementation
    - documenting codes preoperly from now on in the folder "Matlab code"
    - Next meeting: 
      - 2-Dec: only with Liyuan, 16-Dec: Liyuan and Ali , 6-Jan-2022: regular meeting

### Meeting on 02.12.2021:
  - understood the encoding concepts
  - modified the encoder
  - decoder still has a problem (in processing)
  - To do:
    - to fix the decoder
    - @Liyuan: datasets upload
    - store the encoding results (bit by bit) to a *.txt* file and try to use this *.txt* file as the input of the decoder
    - quantization and distribution of the data
    - compress the real data with AC encoder
    - implementation of dpcm1, dpcm2, and dpcm3
    - compress the real data, which is pre-processed by dpcm(x), with AC encoder

### Meeting on 06.01.2022:
   - drawing the distribuation of the data and also using dpcm_1 and dpcm_2 and draw the distribution
   - fixed the decoder issue
   - to do: 
     - run dpcm_3 on data
     - add work-log folder and the results in PPT there 
     - add readme file in folder MATLAB_code and explain what each is doing
     - calculate the compression ratio (CR) and express the noise level as well.
       - try it for noisy dataset too and real datasets started with "d5".
      - store the encoding results (bit by bit) to a *.txt* file and try to use this *.txt* file as the input of the decoder
      - draw a block diagram for AC with main arithmetic detials
      - investigation on the dpcm output distribution to define some pre-defined range to make the hardware easier at the price of small CR drop
     
### Meeting on 06.01.2022 (with Ali on the matlab code):
 - add the comments to code
 - specify the inputs and outputs of each code in details on the top of the code
 - cretae functions as much as possible
 - use the relative path 
 ```
 currentFile = mfilename( 'fullpath' );
 [pathstr, name, ~] = fileparts( currentFile );
 cd(pathstr);
 addpath( fullfile( pathstr ) );
 ```
 - try to skip for-loop as much as possible in MATLAB
 - remove all unused parts of the code
 - print information with meaningful message

### Meeting on 13.01.2022:
 - slides for arithmetic coding
 - problems at storing the encoding stream to file
 - re-organized the code
   - configuration of the mode:
     - semi-adaptive way (1)
     - pre-defined distribution way (0)
   - blocks for the AC encoder and decoder
   - comments on the Matlab code
 - research on the DPCM3
   - similar to DPCM2, almost overlapped with DPCM2
 - to do:
   - how to store the encoding stream
     - bit by bit without *enter*
     - bit by bit with *enter*
     - several bits (for example, 8) with *enter*
   - change the calculation of CR%
     - and try not to use semi-adaptive way
   - @Liyuan: check the CR% of AGC
   - find out the min. lenth of decoder

### Meeting on 27.01.2022:
 - stored the output of encoder to a file
 - min. input stream length of decoder has a problem (52 bits)
   - low priority
   - the decoder side is not on-chip
 - tried to simplified the encoding process for symbols with special probabilities
   - this topic should be removed from this SA
   - it only works for certain sub-interval
   - @Liyuan: think to introduce the AHC for rare symbols
 - TODO:
   - pre-define a distribution for all potential symbols
   - and use NAC with this kind of distribution over all datasets
   - and try to use NAC in NLL mode, namely only to compress spikes in datasets starting with the character "C"

### Meeting on 10.02.2022:
 - add a mode (*spikes_mode*) to the matlab code for NLL and LL.
   - spiokes_mode=1 : NLL
 - matlab new function *preset_cal_C.m* to pre-define the distribution
 - TODO:
   - add the *spike_mode* to function *preset_cal_C.m* to calculate the parameters w.r.t to NLL or LL
   - modify the code to calculate the dpcm in NLL mode.
   - and use NAC with this kind of distribution over all datasets
   - and try to use NAC in NLL mode, namely only to compress spikes in datasets starting with the character "C"

### Meeting on 17.02.2022:
- Matlab code:
  - preset function
    - input_mode:
      - raw data, dpcm1, dpcm2
    - spikes_mode:
      - LL mode (0), NLL mode (1)
  - quantization function
- NLL has a little lower CR% compared to LL
  - LL has a CR% around 60-70%
  - NLL has a CR% around 40-50% (I have a doubt on the value so I would like to have the distribution information)
- TODO:
  - change the arugument format of input dataset index
    - include dataset information in the input
  - tables for the compression ratio
    - comments on the distribution in both LL/NLL modes
    - better to have example figures as well
  - try to reconstruct all the datasets
  - @Liyuan: official tasks description
  - HW starting point to be discussed
    - physical meeting next Thursday

### Meeting on 24.02.2022:
- problems on the decoder side
- slides for CR% are not prepared because of the decoder problem
  - firstly address the problems in the decoder
- TODO:
  - debugging the decoder
    - use an existing C/CPP decoder as a ref
    - use Matlab decoder but bit by bit
    - upload the codes to our git repository
  - slides

### Meeting on 03.03.2022:
- block-wise decoder:
  - still problems with reconstruction of 3 datasets
  - *-256* for example
- bit-wise decoder:
  - do not work
- TODO:
  - current decoder: 
    - try to change some very small raw data 
  - try to find a C code for arithmetic coding
    - compare its results with the Matlab
    - reconstruct the data with its C-decoder

### Meeting on 17.03.2022:
- decoder works at least (except -256)
  - Liyuan: the concept is like to change the interval [0,1] to [0,1)
  - better to have [0,2^16-1] instead of [0,1)
- TODO:
  - modification of the matlab encoder/decoder
  - try to understand the C code for the arithmetic coding encoder
  - try to calculate the distribution
  - could start with the thesis SW part
  - @Liyuan: prepare for the HW

### Meeting on 24.03.2022:
- modification of matlab encoder/decoder
  - change the range from [0,1) to [0, 2^16-1]
    - due to the precision problem, 2^32 might be better
    - but on the mem side, the 2^16 is better
      - set the probability of rare symbol as 1/(2^16), which makes the CR% a little lower
      - or combine some rare symbols together: lossy but the MSE should be quite small
        - TODO: maybe a SHK: add-up of probabilities of some rare symbols
- C-algorithm is the same to the matlab code
  - decoder result is also correct
    - see the slides in the repo
  - LL compression: the result is similar to the Golomb coding
  - NLL compression: the calculation has a problem
    - should using the output bitstream and the raw bitstream
    - update the compression ratio of NLL mode
- EOF needed for encoder and decoder (implemented in C encoder/decoder now)
- Overview of thesis SW part
- TODO:
  - preset of probabilities of symbols (at least 1/(2^16))
    - compress the dataset
  - find out the average probabilities over datasets and then compress them
  - start the HW

### Meeting on 31.03.2022:
- compress ratio table:
  - probability: all symbols at least (1/(2^16))
    - average probability over 8 datasets
    - then change the probability of some *rare* symbols to 1/(2^16)
    - to summary the algorithm for probability calculation
  - LL: DPCM2 in general is the best
    - 53.04% to 60.22%
  - NLL: DPCM2 is better then DPCM1
    - 91.00% to 91.88%
    - to add DPCM3 to the NLL mode
  - 16-ch => 2kB?
- A short overview of SW
  - try to write it on overleaf
- the HPSN works now:
  - but the access to the project /p_eval/s_compress doesn't work
- TODO:
  - to summary the algorithm for probability calculation
  - to change the probability of some *rare* symbols to 1/(2^32)
    - show the table
  - to add DPCM3 to the NLL mode
  - @Liyuan: create an overleaf for the student
  - HW implementation
    - ports definition
    - try with the HPSN cluster
      - coding and simulation

### Meeting on 07.04.2022:
- for both LL and NLL:
  - the DPCM2 is the best
- datasets reconstructed correctly with the decoder
- range of DPCM
  - for 9 bits => plus/minus 512 to keep the output of DPCM (or inverse DPCM on the decoder side) between 0 to 511
- don't need to consider the local-buffer in this work
- in HW implementation:
  - DPCM order configurable
  - single clk freq
  - multiplication
- TODO:
  - hw implementation
  - memory size for preset values

### Meeting on 28.04.2022:
- HW implementation:
  - uploaded to the HPSN cluster
  - DPCM and normal AC
  - memory size: 2kByte/ch (or per multi-ch, which are close to each other)
    - 32bit * 512 (symbols)
    - compared to 16 bits (probabilities of samples)
      - the improvement of CR% is not very obvious
      - change it to the bit-width of probabilities to 16
  - start and end signal from the core
- TODO:
  - continue with HW implementation
  - and thesis

### Meeting on 05.05.2022:
- doing the simulation now
  - locally with vivado (modelsim)
- try to remove the divider
  - by changing the *cum_freq[0]* to 2^16
- TODO:
  - copy the code to the HPSN cluster
  - thesis

### Meeting on 12.05.2022:
- HW implementation:
  - synthesized locally
    - not successful
    - try to use the HPSN cluster and hal-check
  - AC, DPCM, MUL are done
  - debugging: Wrapper
- TODO: 
  - top-level
  - thesis
    - introduction
    - decorrelation + compression + SW (?) (and CR% etc)
    - HW, verification, analysis, comparison
    - conclusion

### Meeting on 19.05.2022:
- local implementation and simulation done
- copy the HW code to the hpsn cluster
- wrapper done with the last packet means the *vld_cnt*
- TODO:
  - @Liyuan: tc
  - hal check
