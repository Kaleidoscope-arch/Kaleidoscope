# KaleidoScope: A Co-processor for Neural-network-driven Intelligent Data Plane

## Overview
This repository releases the source code for the paper: "KaleidoScope: A Co-processor for Neural-network-driven Intelligent Data Plane".

The repository consists four sections: 

* Hardware-friendly Fix8 Quantization utilized in KaleidoScope  
* The Verilog source code of Inference engine in KaleidoScope  
* The implementation of integrating KaleidoScope in open-source Corundum NIC. 
* Toolchain for KaleidoScope

The work of KaleidoScope raises no ethic issue.

Corundum NIC is available at: <https://github.com/corundum/corundum>.


## Fix8 Quantization
We allocate 1 bit for the sign flag, 2 bits for the integer part, and 5 bits for the fractional part.
The representation range of our format is $[-4.0, 3.9675]$ with the smallest value increment being 0.03125.
A floating-point data can be transformed into Fix-8 format via dividing $2^{k}$, where the fractional part occupies $k$-bit.
Fix-8 quantization also needs to cope with the data overflow, and we set all data exceeding the range of 3.9675 and -4.0.

Quantize-aware training (QAT) is a significant process in the quantization workflow to recover the accuracy loss, hence it is necessary to implement differentiable Fix-8 quantization.
The key for QAT is to handle the overflow using differentiable functions rather than simple truncation.
**Unfortunately, there is a lack of an open-source Fix-8 QAT library, so we develop the code from scratch.**
We propose to use the differentiable ReLU function of PyTorch which filters out negative values and retains positive ones to manage Fix-8 overflow.
The detailed operations can be seen in the folder:

```
Fixed_Quant/1.1
```

The resulting data is quantized in Fix-8 format while preserving differentiable gradients.

### Using Fix8 Quantization of KaleidoScope
* Requirements
  
```
PyTorch >= 1.12.1
```

* Main files and functions for forwarding

```
fully_fix_linear.py:

    def fix_x(x)
    # quantizing a input fp32 tensor (x) into fix-8 format

    def fully_fix_linear(torch.nn.Module)
    # a fully fix-8 quantized linear layer, whose matrix-multiplication is implemented by fix-8 format

```

```
fully_fix_MLP.py:
    This file fully_fix_MLP.py showcases how to develop a fix-8 quantized MLP model.

    class NonBN_MLP_Fullfix: 
        def fp_forward(self, x)
        # forwarding the NN with fp32 format

        def load_fullfix_model(self, param_path)
        # load parameters for a NN and transformed parameters into fix-8 format

        def fixed_model(self)
        # transforming a fp32 NN model into fix-8 format    

        def fixed_fwd(self, x):
        # forwarding the NN with fix-8 format
```


* QAT

```
train_MLP_fix.py:
    
    def fixed_fwd_op(
        model: nn.Module,
        data_loader: DataLoader,
        device: str = 'cuda',
        num_class: int = 2,
        overflow = False
    ) -> List[Tuple[float, Any, Any, Any, Any]]
    # evaluation operations with fix-8 format


    def fix_train_op(
        model: nn.Module,
        batch_size: int = 512,
        n_epochs: int = 16,
        device: str = 'cuda',
        task_weights: Tuple[int, int] = (1, 1),
        use_wandb: bool = False,
        overflow: bool = False
    )
    # train operations with fix-8 format
```

## KaleidoScope RTC Accelerator (FPE)

At the core of the Fast Inference Path (FIP) are multiple fast process engines (FPE). FPE is a programmable RTC accelerator designed for GEMV computation, which is suitable for cases requiring lightweight and low-latency traffic analysis. 
FPE is implemented by Verilog HDL and validated on FPGA the platform.  
Current open-source version of KaleidoScope comprises 1$\times$FPE unit.

### Code Organization
Codes related to FPE implementation is in the **FPE** folder.

```
VPE_top // the top of FPE, in VPE_top.v
    |----   VPE_Params_Loader // the interface to load NNs parameters 
    |----   VPE_Ctrl // the controler of FPE, decoding and issuing instructions, in VPE_Ctrler.v
    |----   VPE_TF_Fetcher // fetcher for mirrored traffic, in TF_fetcher.v
    |----   Vector_Regfile // regfile for FPE, in Vector_Regfile.v
    |----   SIMD_in_Reg // the input data regfile for SIMD, in SIMD_in_Reg.v
    |----   VPE_Weights_ROM // the on-chip memory for NNs parameter, in VPE_Weights_ROM.v
    |           |----   the specific memory component is decided by hardware platforms, on FPGA we utilize BRAM
    |----   SIMD // core computing unit, in SIMD.v
    |           |---- SIMD_LANE // sub-computing unit, in Lane.v
    |                       |----   Dot_PE // the basic computing unit for dor-product between two vectors, in Dot_PE.v
    |----   VPE_Vector_Adder // inline accumulator of FPE, in VPE_Vector_Adder.v
    |----   VPE_ReLU // ReLU activation module of FPE, in VPE_ReLU.v
```
