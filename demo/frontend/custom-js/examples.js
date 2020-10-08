const md = require('markdown-it')();
const examples = [
  {
    name: "Affine Memory",
    code: `
let a: float[10];
a[0];
a[0] := 1.0;
    `,
    explanation: `
    In FPGA programming, memories are implemented using physical resources
    which can service a finite number of reads and writes every cycle. In
    Dahlia, memories are affine, i.e., they can only be used up to one time
    in every *logical time step*. The first read to \`a[0]\` consumes the
    affine memory.
    `,
  },
  {
    name: "Logical Time Steps",
    code: `
let a: float[10];
a[0];
---
a[1];
    `,
    explanation: `
    A \`---\` in Dahlia creates a *logical time step*. Resources can be
    reused across time steps. Since a[0] and a[1] are in different time steps,
    the program is accepeted.
    `,
  },
  {
    name: "Capabilities (1)",
    code:`
let a: float[10];
let x = a[0];
let y = a[0]; // Allowed: Reads from same location.
`,
    explanation: `
    Reads from the same memory address locations can be *fanned-out* in hardware.
    Dahlia acquires a *read capability* for every memory read in a logical time
    step and does not consume affine memories after the first read. However,
    reads from different memory locations are only permitted with the availability of
    ports.
  `
  },
  {
    name: "Capabilities (2)",
    code:`
let a: float[10];
a[0] := 1.0;
a[0] := 2.0; // Disallowed: Writes to same location
`,
    explanation: `Writes to the same memory address cannot occur in hardware.
    *Write capabilities* in Dahlia are affine--writing to a location consumes
    the capability.`
  },
  {
    name: "Memory Ports",
    code:`
let a: float{2}[10];
a[0];
a[1] := 1.0;`,
    explanation: `
    FPGA memories can also support multiple *ports* in order to service multiple
    reads and writes every cycle. Dahlia supports reasoning about multi-ported
    memories. Since in this program the resource \`a\` is given 2 ports, it
    can read the two addresses in the same logical time steps.`
  },
  {
    name: "Memory Banking (1)",
    code:`
let a: float[10 bank 2];
a[0];
a[1] := 1.0;`,
    explanation: `
    FPGA memories can *banked*, i.e., a logical memory can be represented using
    several physical memories containing disjoint elements. This allows parallel
    access to *disjoint elements*. A banked memory stores elements in a striped
    pattern. In this example, it allows for parallel access to two adjacent elements.`
  },
  {
    name: "Memory Banking (2)",
    code:`
let a: float[10 bank 2];
a[0];
a[0] := 1.0;`,
    explanation: `
    Unlike ports, memory banks *do not allow* for access to the same element in
    a single time step.`
  },
  {
    name: "Parallel Loops (1)",
    code:`
let a: float[10 bank 2];
let b: float[10 bank 2];
for (let i = 0 .. 10) unroll 2 {
  a[i] := b[i] * 2.0; // fails on changing a[i] to b[i+1]
}`,
    explanation: `
    In Dahlia, \`for\` loops can be used to parallelize computation. These
    loops support *DOALL* parallelism and therefore disallow any interloop
    dependencies in the parallel part of the computation. The program creates
    two processing elements (PEs) that execute on disjoint parts of \`a\` and
    \`b\`.
    `
  },
  {
    name: "Parallel Loops (2)",
    code:`
let a: float[10];
let b: float[10 bank 2];
for (let i = 0 .. 10) unroll 2 {
  a[i] := b[i] * 2.0;
}`,
    explanation: `
    Unrolled \`for\` loops require parallel access to elements of a memory. If a
    memory does not provide sufficient banks, the FPGA design will multiplex
    access to memory--the design will require more area without improving
    latency. Dahlia rejects such programs.
    `
  },
  {
    name: "Combine blocks",
    code:`
let a: float[10 bank 2];
let sum = 0.0;
for (let i = 0 .. 10) unroll 2 {
  let x = a[i] * 2.0;
} combine {
  sum += x;
}`,
    explanation: `
    Accelerators often need to reduce the results of parallel loop iterations.
    Unrolled \`for\` loops can optionally specify a \`combine\` block to
    perform reductions across parallel iterations. Variables bound within
    the parallel parts of the loop are available within the \`combine\` block.
    `
  },
  {
    name: "Views: Shrink",
    code:`
let a: float[8 bank 4];
view a_sh = a[_: bank 2]; // Type is: float[8 bank 2]
for (let i = 0 .. 8) unroll 2 {
  let x = a_sh[i]; // Ok: Banking factor == unrolling.
  ---
  let y = a[i] * 2.0; // Disallowed since it requires transformations.
}`,
    explanation: `Memory views are Dahlia's mechanism to reason about disjoint
    accesses with complex memory access patterns. A core design philosophy with
    Dahlia is that complexity in the generated hardware should be evident in
    the source program. A *shrink* view represents the hardware cost of
    multiplexing multiple banks to act as one logical unit.
    `
  },
  {
    name: "Views: Aligned Suffix",
    code:`
let a: float[8 bank 2];
for (let i = 0..4) {
  view a_su = a[2*i:];
  for (let j = 0..2) unroll 2 {
    let x = a_su[j]; // Same as a[2*i + j]
  }
}`,
    explanation: `Aligned views in Dahlia represent access pattern that aligned
    on *bank boundaries*, i.e., if the original array has *k* banks, elements
    are accesses from *0*-*k*, then *k+1*-*2k* and so on. This restriction allows
    Dahlia to prove that there is no additional hardware required to implement
    the access pattern.`
  },
  {
    name: "Views: Rotation Suffix",
    code:`
let a: float[8 bank 2];
for (let i = 0..4) {
  view a_su = a[i*i!:];
  for (let j = 0..2) unroll 2 {
    let x = a_su[j]; // Same as a[i*i + j]
  }
}`,
    explanation: `Rotation suffixes represent access patterns that don't access
    elements at *bank boundaries* but still guarantee that no bank conflicts
    occur in the same cycle. For example, this program will read *4* indices
    starting from *i*\**i*, each of which is guaranteed to be in a different bank.`
  },
  {
    name: "Views: Split",
    code:`
let a: float[8 bank 4];
split a_sp = a[by 2]; // 2 blocks of a
for (let i = 0..2) unroll 2 {
  for (let j = 0 .. 4) unroll 2 {
    let x = a_sp[i][j] * 2.0;
  }
}`,
    explanation: `Split views represent memory access patterns that can be parallelized
    at multiple levels. A common case is *block-based* parallelization where
    a memory is partitioned into several blocks, each of which can perform their
    computation independently (*inter-block* parallelization) while also
    allowing parallelism within the computation of each block (*intra-block*
    parallelization).`
  }
]


// Make sure all required fields of an example are defined.
function validateExample(example) {
  const exampleKeys = ['name', 'code', 'explanation'];
  let isValid = true;
  for (let k of exampleKeys) {
    if (typeof example[k] !== 'string') {
      console.warn("Not a valid example:" + JSON.stringify(example))
      isValid = false;
    }
  }
  return isValid;
}

// Setup button for an example. Update function cleans up the UI for the new
// example.
function addExample(example, updateFunc) {
  const buttonClasses = ["btn", "btn-default", "btn-block"];
  // The document element for the button:
  const el = document.createElement('BUTTON')
  for (let cls of buttonClasses) {
    el.classList.add(cls);
  }
  el.type = "button"
  el.innerHTML = example.name;
  // On clicking the button, update the editor and the explanation box.
  el.onclick = function () {
    updateFunc(example.code.trim());
    document.getElementById('explain').innerHTML =
      md.render(example.explanation.trim());
    document.getElementById('example-name').innerHTML =
      example.name;
  }

  const td = document.createElement('TD');
  td.appendChild(el);
  return td;
}

// Create a new horizontal button group
function newGroup() {
  let el = document.createElement('TR');
  return el;
}

function setupAll(updateFunc) {
  let fragment = document.createDocumentFragment();
  let curGroup = newGroup();
  let groupSize = 0;
  for (let i = 0; i < examples.length; i++) {
    const ex = examples[i];
    if (validateExample(ex)) {
      curGroup.appendChild(addExample(ex, updateFunc));
      groupSize += 1;
    }
    if (groupSize === 2 || i === examples.length - 1) {
      fragment.appendChild(curGroup);
      curGroup = newGroup();
      groupSize = 0;
    }
  }
  document.getElementById('examples').appendChild(fragment);
}

exports.setupAll = setupAll;
