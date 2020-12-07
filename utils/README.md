# Utility Tool for Generating C++ Builds

This utility tool is a wrapper around the primary Diospyros engine which generates the kernel code. It tries to automate the generation of all the infrastructure that is necessary to provide a self-contained build around the generated kernels. The scaffolding should produce both benchmarking and test definitions demonstrating marginal functionality. The wrapper expects a number of metadata fields contained in a manifest file that define necessary fields consumed by the tool to accomplish this.

Manifest fields currently are:
- name: kernel name
- inputs: defines inputs of kernel and type signature
- outputs: defines outputs of kernel and type signature
- specification: defines the relative location of the specification with respect to the manifest file
- specification_kernel: the name of the function in the specification definition

Source files are divided into roughly one generator per component of the build.

An example command to run:
```
python diospyros.py --manifest sample/diospyros.json
```