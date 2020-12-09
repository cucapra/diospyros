"""

  Matrix multiply generator. Generates an Eigen matrix multiply override kernel.

"""


def generator(kernel_name, params, spec_file):
    input_rows = params["input_rows"]
    input_cols = params["input_cols"]
    output_cols = params["output_cols"]

    # inject specification template with arguments
    spec = """/*!

  Specification file of the target kernel to be consumed by the Diosypros tool

*/

#define A_ROWS {}
#define A_COLS {}
#define B_COLS {}

void {}(
    float a_in[A_ROWS * A_COLS],
    float b_in[A_COLS * B_COLS],
    float c_out[A_ROWS * B_COLS]) {{
  for (int i = 0; i < A_ROWS; i++) {{
    for (int j = 0; j < B_COLS; j++) {{
      c_out[j * A_ROWS + i] = 0;

      for (int k = 0; k < A_COLS; k++) {{
        c_out[j * A_ROWS + i] += a_in[k * A_ROWS + i] * b_in[j * A_COLS + k];
      }}
    }}
  }}
}}""".format(input_rows, input_cols, output_cols, kernel_name)

    handle = open(spec_file, "w")
    handle.write(spec)
    handle.close()

    # return a dictionary of the inputs and outputs of this function definition
    # and type signatures
    manifest_shard = {
        "inputs": {
            "a": "Eigen::Matrix<float, {}, {}>".format(input_rows, input_cols),
            "b": "Eigen::Matrix<float, {}, {}>".format(input_cols, output_cols)
        },
        "outputs": {
            "c": "Eigen::Matrix<float, {}, {}>".format(input_rows, output_cols)
        },
        "test": "c = a * b"
    }
    return manifest_shard
