## mSMV
 Maximum Spherical Mean Value for Shadow Reduction

Here, an algorithm based on the maximum corollary of Green’s theorem is proposed to remove shadows in quantitative susceptibility mapping while preserving the edge of the brain. This method is referred to as maximum Spherical Mean Value, or `mSMV`.
<p align="center">
<img width="500" src=https://github.com/agr78/mSMV/assets/69256818/3d619d71-2fae-48cc-b7ad-8bdd4d78024f>
</p>

## Installation
Clone the repository with:
`git clone https://github.com/agr78/mSMV.git`

## Function arguments
For ease of use with the [`MEDI Toolbox`](https://github.com/pascalspincemaille/MEDI_toolbox) (included in `mSMV/code/dependencies/MEDI_functions/`), the function `mSMV` accepts the following arguments: \
`in_file` Input file containing the field map after background field removal (by [`PDF`](https://sepia-documentation.readthedocs.io/en/latest/method/bfr/PDF.html), [`VSHARP`](https://sepia-documentation.readthedocs.io/en/latest/method/bfr/VSHARP_STISuite.html), [`LBV`](https://sepia-documentation.readthedocs.io/en/latest/method/bfr/LBV.html), etc.) \
`out_file` Output file containing [`mSMV`](#mSMV) filtered field map \
`radius` Prefilter radius (default 5mm) \
`maxk` Maximum number of iterations with minimum kernel radius (default 5) \
`vr` Frangi filter vessel radius, see MATLAB's [`fibermetric()`](https://www.mathworks.com/help/images/ref/fibermetric.html) function for further details \
`pf` Optional disabling of the prefilter step (typically used with [`SHARP`](https://sepia-documentation.readthedocs.io/en/latest/method/bfr/SHARP.html), [`RESHARP`](https://sepia-documentation.readthedocs.io/en/latest/method/bfr/RESHARP.html), [`VSHARP`](https://sepia-documentation.readthedocs.io/en/latest/method/bfr/VSHARP_STISuite.html), etc.)

## Prerequisites
All necessary toolboxes are included in `mSMV/code/dependencies/`. If these toolboxes are already installed, `mSMV/code/mSMV_functions/` can be added to the MATLAB path.

## Examples
The `run_simulation.m` file can be used to generate the numerical phantom from the [`paper`](https://arxiv.org/abs/2304.11476).

## Notes
The vessel mask requires an $R_2^*$ map for generation, if this variable is missing in `in_file`, this step will be skipped.

## Publications
If this code is used, please cite the following: \
[Preprint](https://arxiv.org/abs/2304.11476): A. G. Roberts et al., "Maximum Spherical Mean Value (mSMV) Filtering for Whole Brain Quantitative Susceptibility Mapping," arXiv pre-print server, 2023-04-22 2023, arxiv:2304.11476.
