fully_fix_MLP.py:
The example of model define, implementation and loading
    The forwarding implementation of Fix-8
    The Fix-8 quantization on model parameters and feature
    The export of model parameters and feature for validation
    Training and inference

fully_fix_linear.py:
The Fix-8 quantization library, includes
    All Fix-8-based GEMM, which are decomposed into element-wise multiplication, accmulation
    All operations above are Fix-8-based
    The data quantization process, consisting Fix-8 transform and overflow.

train_MLP.py:
The example of Fix-8 QAT

