const md = require('markdown-it')();
const examples = [
  {
    name: "Matrix Matrix add",
    code: `
let a: float[10];
a[0];
a[0] := 1.0;
    `,
    explanation: `
    Words words words
    `,
  },
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
